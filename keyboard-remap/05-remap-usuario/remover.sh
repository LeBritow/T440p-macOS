#!/bin/bash
DEST="$HOME/Library/LaunchAgents/com.gustavo.remap-question.plist"
launchctl unload "$DEST" 2>/dev/null || true
rm -f "$DEST"
echo "Remapeador removido e desativado."
