#!/bin/bash
# Applies the live remap: right Ctrl (?) -> slash (/)
# Note: lasts until reboot. To persist, install the LaunchAgent.
#
# How the numbers were found:
#   Right Ctrl HID usage (ADB/legacy)       = 62  (0x3E)
#   "/" key HID usage                       = 44  (0x2C)
# Confirmed by test: the "?" key sends kc=62 (right Ctrl).

hidutil property --set '{"UserKeyMapping":[{"HIDUsagePage":7,"HIDUsage":62,"UserDefinedUsagePage":7,"UserDefinedUsage":44}]}'

echo "Applied. Current state:"
hidutil property --get "UserKeyMapping"
echo
echo "Test: press the '?' key -> it should type /"
echo "      Shift+'?'       -> it should type ?"
echo "      Backspace       -> still deletes"