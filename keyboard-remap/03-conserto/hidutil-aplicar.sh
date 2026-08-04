#!/bin/bash
# APLICA o remap ao vivo: Ctrl direito (?) -> slash (/)
# Obs.: vale ate o reboot. Para persistir, instale o LaunchAgent.
#
# Como descobrir o numero:
#   HID usage do Ctrl direito (ADB/legacy) = 62  (0x3E)
#   HID usage da tecla "/"               = 44  (0x2C)
# Confirmado no teste: a tecla "?" envia kc=62 (Ctrl direito).

hidutil property --set '{"UserKeyMapping":[{"HIDUsagePage":7,"HIDUsage":62,"UserDefinedUsagePage":7,"UserDefinedUsage":44}]}'

echo "Aplicado. Estado atual:"
hidutil property --get "UserKeyMapping"
echo
echo "Teste: aperte a tecla '?' -> deve digitar /"
echo "       '?'+Shift        -> deve digitar ?"
echo "       Backspace        -> continua apagando"
