#!/bin/bash
# Installs the remap so it applies at every login (persists across reboots).
# The hidutil command needs no sudo, so a user LaunchAgent is enough.

set -e

SRC="$(cd "$(dirname "$0")" && pwd)/com.t440p.remap-keyboard.plist"
DST="$HOME/Library/LaunchAgents/com.t440p.remap-keyboard.plist"

cp "$SRC" "$DST"
launchctl unload "$DST" 2>/dev/null || true
launchctl load "$DST"

echo "Installed at $DST"
echo "Applies at every login. To remove:"
echo "  launchctl unload $DST && rm $DST"