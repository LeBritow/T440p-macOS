#!/bin/bash
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/LaunchAgents/com.t440p.remap-question.plist"

mkdir -p "$HOME/Library/LaunchAgents"
chmod +x "$SRC/remap-question"
cp "$SRC/com.t440p.remap-question.plist" "$DEST"
plutil -replace ProgramArguments.0 -string "$SRC/remap-question" "$DEST"
launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"
echo "Installed. Remapper active (starts automatically at login)."
echo "If '?' still does not work, grant Accessibility to the binary:"
echo "  System Settings > Privacy & Security > Accessibility"
echo "  $SRC/remap-question"