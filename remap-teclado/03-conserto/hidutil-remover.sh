#!/bin/bash
# REMOVE o remap do hidutil (volta ao normal).
hidutil property --set '{"UserKeyMapping":[]}'
echo "Removido. Estado atual:"
hidutil property --get "UserKeyMapping"
