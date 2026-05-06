#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
  BLUE=$'\033[34m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; CYAN=$'\033[36m'
else
  BOLD=''; DIM=''; RESET=''
  BLUE=''; GREEN=''; YELLOW=''; RED=''; CYAN=''
fi

STEP=0
step() { STEP=$((STEP+1)); printf '\n%s%s━━ [%d] %s%s\n' "$BOLD" "$CYAN" "$STEP" "$1" "$RESET"; }
ok()   { printf '  %s✓%s %s\n' "$GREEN"  "$RESET" "$*"; }
run()  { printf '  %s→%s %s\n' "$BLUE"   "$RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
fail() { printf '  %s✗%s %s\n' "$RED"    "$RESET" "$*" >&2; }

confirm() {
  local ans
  read -rp "  $1 [y/N] " ans
  [[ "$ans" =~ ^[yY]([eE][sS])?$ ]]
}

ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

printf '\n%s%smacOS bootstrap%s\n' "$BOLD" "$BLUE" "$RESET"
printf '%sa few prompts up front, then this runs unattended.%s\n' "$DIM" "$RESET"

# ── prerequisite: iCloud Drive ────────────────────────────────────────────────
# The Cryptomator vault used for AI agent sessions lives in iCloud Drive, so
# bail out early if iCloud isn't set up before any changes are made.
if [[ ! -d "$ICLOUD_DIR" ]]; then
  fail "iCloud Drive not found ($ICLOUD_DIR)."
  fail "Sign in to iCloud and enable iCloud Drive, then re-run."
  exit 1
fi
ok "iCloud Drive active"

# ── prompts ──────────────────────────────────────────────────────────────────
# `mas` can't sign in to the App Store on modern macOS — Apple killed CLI auth.
if ! confirm "signed in to the App Store?"; then
  fail 'sign in via the App Store app, then re-run.'
  exit 1
fi

# Xcode Command Line Tools
# Done first because git (needed for the next prompt) ships with CLT.
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "already installed"
else
  run "installing — a system dialog will pop"
  xcode-select --install
  warn "wait for the installer to finish, then re-run this script"
  exit 0
fi

# Collect git identity now so the unattended steps don't have to prompt. Without these,
# git falls back to whoami@hostname, which on a Tailscale machine becomes
# <host>.ts.net.
GIT_NAME=$(git config --global --get user.name  2>/dev/null || true)
GIT_EMAIL=$(git config --global --get user.email 2>/dev/null || true)
[[ -z "$GIT_NAME"  ]] && read -rp "  git user.name: "  GIT_NAME
[[ -z "$GIT_EMAIL" ]] && read -rp "  git user.email: " GIT_EMAIL

# Homebrew
step "Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "already installed"
else
  run "installing"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Brew packages
step "Homebrew packages"
run "brew bundle"
brew bundle --file="$DIR/Brewfile"

# dotfiles via stow
# Cloned over HTTPS because the SSH agent + insteadOf rewrite aren't set up
# until the 1Password step. Re-stow on every run so partial states heal idempotently.
step "dotfiles (stow)"
DOTFILES_DIR="$HOME/dotfiles"
if [[ ! -d "$DOTFILES_DIR" ]]; then
  run "cloning ruggi/dotfiles"
  git clone https://github.com/ruggi/dotfiles.git "$DOTFILES_DIR"
else
  ok "dotfiles already cloned"
fi
run "stow common"
stow -d "$DOTFILES_DIR" -t "$HOME" -R common

# rtk — Claude Code hook for token-optimized CLI output.
# Runs after stow so the symlinked settings.json exists before rtk patches it.
step "rtk (Claude Code hook)"
run "init"
rtk init -g --auto-patch

# npm global packages (Npmfile)
step "npm global packages"
NPM_PACKAGES=$(grep -vE '^[[:space:]]*(#|$)' "$DIR/Npmfile" | tr '\n' ' ' || true)
if [[ -n "$NPM_PACKAGES" ]]; then
  run "npm install -g $NPM_PACKAGES"
  npm install -g $NPM_PACKAGES
else
  ok "Npmfile is empty"
fi

# LazyVim — only if stow didn't drop an nvim config
step "LazyVim"
if [[ -e "$HOME/.config/nvim/init.lua" ]]; then
  ok "nvim config already present, skipping"
else
  run "installing starter"
  mkdir -p "$HOME/.config"
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi

# 1Password SSH agent + git SSH signing
step "1Password SSH agent + git signing"

SSH_CFG="$HOME/.ssh/config"
SSH_BEGIN="# >>> 1Password SSH agent >>>"
SSH_END="# <<< 1Password SSH agent <<<"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
[[ -e "$SSH_CFG" ]] || touch "$SSH_CFG"

# Strip any prior block with our markers, then re-append. Idempotent.
awk -v begin="$SSH_BEGIN" -v end="$SSH_END" '
  $0 == begin {skip=1; next}
  skip && $0 == end {skip=0; next}
  !skip
' "$SSH_CFG" > "$SSH_CFG.tmp"

{
  cat "$SSH_CFG.tmp"
  printf '\n%s\nHost *\n  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"\n%s\n' \
    "$SSH_BEGIN" "$SSH_END"
} > "$SSH_CFG"
rm -f "$SSH_CFG.tmp"
chmod 600 "$SSH_CFG"
ok "ssh config updated"

[[ -n "$GIT_NAME"  ]] && git config --global user.name  "$GIT_NAME"
[[ -n "$GIT_EMAIL" ]] && git config --global user.email "$GIT_EMAIL"

# Always talk to GitHub over SSH, even when the remote URL is HTTPS.
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Route git's SSH commit signing through 1Password's helper.
# user.signingkey + commit.gpgsign are left for the user to set per-key.
git config --global gpg.format ssh
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
ok "git configured"

# git config — general options not tied to SSH/signing.
step "git config"
git config --global core.pager "hunk pager"
ok "git options set"

# macOS preferences
step "macOS preferences"
run "applying"
bash "$DIR/macos.sh"

# Cryptomator — vault on iCloud Drive holds the AI agent sessions.
# Launch it so the user can unlock the vault now (everything else is done).
step "Cryptomator"
if confirm "launch Cryptomator now to unlock your vault?"; then
  run "opening Cryptomator"
  open -a Cryptomator
  ok "Cryptomator launched"
else
  ok "skipped — launch it later from /Applications"
fi

printf '\n%s%s━━ done%s\n\n' "$BOLD" "$GREEN" "$RESET"

cat <<EOF
${BOLD}manual steps remaining${RESET}

  ${CYAN}1Password${RESET}
    • sign in, then enable "Use the SSH agent" in Settings → Developer
    • after adding an SSH key, enable commit signing:
        git config --global user.signingkey "ssh-ed25519 AAAA..."
        git config --global commit.gpgsign true

  ${CYAN}apps${RESET}
    • run 'claude' to authenticate Claude Code
    • sign in to AdGuard
    • open Rectangle and import $DIR/rectangle/RectangleConfig.json

  ${CYAN}finally${RESET}
    • log out and back in for some prefs to take effect

EOF
