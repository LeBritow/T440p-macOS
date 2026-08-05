#!/bin/bash
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/Library/LaunchAgents/com.gustavo.remap-question.plist"

mkdir -p "$HOME/Library/LaunchAgents"
chmod +x "$SRC/remap-question"
cp "$SRC/com.gustavo.remap-question.plist" "$DEST"
plutil -replace ProgramArguments.0 -string "$SRC/remap-question" "$DEST"
launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"
echo "Instalado. Remapeador ativo (inicia no login automaticamente)."
echo "Se a '?' nao funcionar: adicione o binario em Acessibilidade:"
echo "  System Settings > Privacidade e Seguranca > Acessibilidade"
echo "  $SRC/remap-question"
