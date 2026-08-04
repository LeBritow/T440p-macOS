#!/bin/bash
set -e
SRC="/Users/gustavobrito/Documents/Default Project/remap-teclado/05-remap-usuario"
DEST="$HOME/Library/LaunchAgents/com.gustavo.remap-question.plist"

chmod +x "$SRC/remap-question.py"
cp "$SRC/com.gustavo.remap-question.plist" "$DEST"
launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"
echo "Instalado. Remapeador ativo (inicia no login automaticamente)."
echo "Se a '?' nao funcionar: verifique Acessibilidade em"
echo "  System Settings > Privacidade e Seguranca > Acessibilidade"
echo "  e adicione: /usr/bin/python3"
