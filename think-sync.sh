#!/usr/bin/env bash
# think-sync — bidirectional sync between ~/think and iCloud Drive.
# Runs as a LaunchAgent; fswatch uses macOS FSEvents to trigger syncs so
# there is no polling and battery impact is negligible when files are idle.
set -uo pipefail

# LaunchAgents run with a minimal PATH; make sure Homebrew binaries are reachable.
if [[ -x /opt/homebrew/bin/brew ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ -x /usr/local/bin/brew ]]; then
  export PATH="/usr/local/bin:$PATH"
fi

LOCAL="$HOME/think"
ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs/think"
LOCK="/tmp/think-sync.lock"

# Pin the hostname used by unison for its archive files so that renaming the
# machine (e.g. via Tailscale) doesn't cause unison to treat everything as a
# conflict and re-sync from scratch.
export UNISONLOCALHOSTNAME="think-sync"

log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$*"; }

do_sync() {
  # Skip if a sync is already in progress (stale lock = previous crash, ignore it)
  if [[ -f "$LOCK" ]] && kill -0 "$(cat "$LOCK")" 2>/dev/null; then
    return 0
  fi
  echo $$ > "$LOCK"
  log "syncing"
  unison "$LOCAL" "$ICLOUD" \
    -batch \
    -auto \
    -prefer newer \
    -terse \
    -ignore 'Name .DS_Store' \
    -ignore 'Name *.tmp' \
    -ignore 'Name .~lock.*' \
    || log "unison exited with error $?"
  rm -f "$LOCK"
  log "done"
}

mkdir -p "$LOCAL" "$ICLOUD"

log "think-sync starting"
do_sync

# -o   emit one line per event batch (not per changed file)
# -l 3 coalesce events within a 3-second window — acts as debounce
fswatch -o -l 3 "$LOCAL" "$ICLOUD" | while read -r; do
  do_sync
done
