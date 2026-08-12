#!/bin/bash
DEST="$HOME/Library/LaunchAgents/com.t440p.remap-question.plist"
launchctl unload "$DEST" 2>/dev/null || true
rm -f "$DEST"
echo "Remapper removed and disabled."