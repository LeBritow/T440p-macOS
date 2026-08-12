#!/bin/bash
# FINAL TEST: press the '?' key 3x and the physical Backspace 3x.
# Double-click this file -> opens Terminal and runs the test.
cd "$(dirname "$0")"
clear
echo "================================================================"
echo " FINAL TEST - '?' vs Backspace"
echo "================================================================"
echo "When READY appears, press IN ORDER, 3x each:"
echo "  1) the '?' key  (the one at the right Ctrl position)"
echo "  2) the physical Backspace key (large, above Enter)"
echo "  DO NOT type anything else while the test runs."
echo "================================================================"
echo
python3 "$(dirname "$0")/kbtest2.py" 60
echo
echo "Done! If hidutil is working, the '?' should show kc=44"
echo "(slash). If it shows kc=62 (ctrl), hidutil did NOT match the keyboard."
echo
read -p "Press ENTER to close..."