#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { printf "\n\033[1;34m>>> %s\033[0m\n" "$*"; }

# Confirm App Store sign-in — `mas` needs it to install App Store apps and
# can't sign in itself on modern macOS (Apple killed CLI auth).
read -rp "Are you signed in to the App Store? [y/N] " ans
case "$ans" in
  [yY]|[yY][eE][sS]) ;;
  *) echo "Sign in via the App Store app, then re-run." >&2; exit 1 ;;
esac

# 1. Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  say "installing Xcode Command Line Tools"
  xcode-select --install
  echo "wait for the CLT install to finish, then re-run this script"
  exit 0
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  say "installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Brew packages
say "installing brew packages"
brew bundle --file="$DIR/Brewfile"

# 4. chezmoi
if [[ ! -d "$HOME/.local/share/chezmoi" ]]; then
  say "initializing chezmoi from github.com/ruggi/dotfiles"
  chezmoi init --apply ruggi
else
  say "applying chezmoi"
  chezmoi apply
fi

# 5. LazyVim — only if chezmoi didn't drop an nvim config
if [[ ! -e "$HOME/.config/nvim/init.lua" ]]; then
  say "installing LazyVim starter"
  mkdir -p "$HOME/.config"
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi

# 6. 1Password SSH agent + git SSH signing
say "configuring 1Password SSH agent and git signing"

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

# Prompt for git identity if missing — without these, git falls back to
# whoami@hostname, which on a Tailscale machine becomes <host>.ts.net.
if ! git config --global --get user.name >/dev/null; then
  read -rp "Git user.name: " git_name
  [[ -n "$git_name" ]] && git config --global user.name "$git_name"
fi
if ! git config --global --get user.email >/dev/null; then
  read -rp "Git user.email: " git_email
  [[ -n "$git_email" ]] && git config --global user.email "$git_email"
fi

# Always talk to GitHub over SSH, even when the remote URL is HTTPS.
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Route git's SSH commit signing through 1Password's helper.
# user.signingkey + commit.gpgsign are left for the user to set per-key.
git config --global gpg.format ssh
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

# 7. macOS preferences
say "applying macOS preferences"
bash "$DIR/macos.sh"

say "done"
cat <<EOF

manual steps remaining:
  - sign in to 1Password, then enable "Use the SSH agent" in Settings → Developer
  - after adding an SSH key to 1Password, enable commit signing:
      git config --global user.signingkey "ssh-ed25519 AAAA..."   # your pubkey
      git config --global commit.gpgsign true
  - run 'claude' to authenticate Claude Code
  - sign in to AdGuard
  - open Rectangle and import $DIR/rectangle/RectangleConfig.json
  - log out and back in for some prefs to take effect
EOF
