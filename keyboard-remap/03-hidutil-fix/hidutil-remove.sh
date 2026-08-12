#!/bin/bash
# Removes the hidutil remap (restores normal behavior).
hidutil property --set '{"UserKeyMapping":[]}'
echo "Removed. Current state:"
hidutil property --get "UserKeyMapping"