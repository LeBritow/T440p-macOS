#!/bin/bash
# Coleta todo o estado atual do teclado para diagnostico.
# Rode com:  bash coleta.sh   (o resultado vai para a mesma pasta)

BASE="$(cd "$(dirname "$0")" && pwd)"
OUT="$BASE"

echo "Coletando estado do teclado em $OUT ..."

{
  echo "=================================================="
  echo "DATA: $(date)"
  echo "=================================================="
  echo
  echo "== 1. hidutil UserKeyMapping (remap macOS embutido) =="
  hidutil property --get "UserKeyMapping" 2>&1
  echo
  echo "== 2. kextstat (kexts PS2 carregados) =="
  kextstat 2>/dev/null | grep -i ps2
  echo
  echo "== 3. board-id / product (SMBIOS) =="
  ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | grep -E '"board-id"|"product-name"|"manufacturer"'
  echo
  echo "== 4. Arvore ApplePS2Keyboard (plist carregado + Platform Profile) =="
  ioreg -r -c ApplePS2Keyboard -w0 2>/dev/null
  echo
  echo "== 5. Copias de VoodooPS2 no disco =="
  find /Library/Extensions /System/Library/Extensions /Volumes/EFI -maxdepth 8 -name "VoodooPS2Controller.kext" 2>/dev/null
  echo
  echo "== 6. Conteudo do Info.plist do kext (estado atual) =="
  PL="/Volumes/EFI/EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext/Contents/Info.plist"
  plutil -p "$PL" 2>&1
  echo
  echo "== 7. config.plist do OpenCore (chaves de teclado) =="
  OC="/Volumes/EFI/EFI/OC/config.plist"
  plutil -p "$OC" 2>&1 | grep -iA6 "voodoops2" | head -20
} > "$OUT/estado-completo.txt" 2>&1

echo "Pronto. Abra: $OUT/estado-completo.txt"
