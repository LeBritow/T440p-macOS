#!/bin/bash
# Collects the full current keyboard state for diagnosis.
# Run with:  bash collect.sh   (output is written to the same folder)

BASE="$(cd "$(dirname "$0")" && pwd)"
OUT="$BASE"

echo "Collecting keyboard state into $OUT ..."

{
  echo "=================================================="
  echo "DATE: $(date)"
  echo "=================================================="
  echo
  echo "== 1. hidutil UserKeyMapping (built-in macOS remap) =="
  hidutil property --get "UserKeyMapping" 2>&1
  echo
  echo "== 2. kextstat (loaded PS2 kexts) =="
  kextstat 2>/dev/null | grep -i ps2
  echo
  echo "== 3. board-id / product (SMBIOS) =="
  ioreg -rd1 -c IOPlatformExpertDevice 2>/dev/null | grep -E '"board-id"|"product-name"|"manufacturer"'
  echo
  echo "== 4. ApplePS2Keyboard tree (loaded plist + Platform Profile) =="
  ioreg -r -c ApplePS2Keyboard -w0 2>/dev/null
  echo
  echo "== 5. VoodooPS2 copies on disk =="
  find /Library/Extensions /System/Library/Extensions /Volumes/EFI -maxdepth 8 -name "VoodooPS2Controller.kext" 2>/dev/null
  echo
  echo "== 6. Kext Info.plist content (current state) =="
  PL="/Volumes/EFI/EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext/Contents/Info.plist"
  plutil -p "$PL" 2>&1
  echo
  echo "== 7. OpenCore config.plist (keyboard keys) =="
  OC="/Volumes/EFI/EFI/OC/config.plist"
  plutil -p "$OC" 2>&1 | grep -iA6 "voodoops2" | head -20
} > "$OUT/keyboard-state.txt" 2>&1

echo "Done. Open: $OUT/keyboard-state.txt"