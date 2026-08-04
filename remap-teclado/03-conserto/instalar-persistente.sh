#!/bin/bash
# INSTALA o remap para valer em todo login (persistente apos reboot).
# O comando do hidutil nao precisa de sudo, entao um LaunchAgent de usuario resolve.

set -e

SRC="$(cd "$(dirname "$0")" && pwd)/com.gustavo.remap-teclado.plist"
DST="$HOME/Library/LaunchAgents/com.gustavo.remap-teclado.plist"

cp "$SRC" "$DST"
launchctl unload "$DST" 2>/dev/null || true
launchctl load "$DST"

echo "Instalado em $DST"
echo "Vai valer a cada login. Para remover:"
echo "  launchctl unload $DST && rm $DST"
