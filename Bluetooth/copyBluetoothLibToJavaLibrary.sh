#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
print_header "Copy Bluetooth Library"
echo -e "${INDIGO}Copying Bluetooth library to Java library directory...${NC}"
sudo cp /Users/singhr/Library/Developer/Xcode/DerivedData/BVBluetoothLib-fhetstcxqzszaufestsnhwhvczyq/Build/Products/Debug/libBVBluetoothLib.dylib /usr/lib/java
ls -la /usr/lib/java
cp /usr/lib/java/libBVBluetoothLib.dylib ~/Documents/workspace/OSX/BVBluetoothLib/Java/lib
print_success "Bluetooth library copied successfully!"
echo

