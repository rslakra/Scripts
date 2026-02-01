#!/bin/bash
# Author: Rohtash Lakra
# Build: Ant, Android (Ant release/sign/zipalign), or OS X framework.
# Usage:
#   ./build.sh --ant-file <build.xml>           # Ant build with given build file
#   ./build.sh android <project> [version]      # Android Ant release (requires ANDROID_HOME)
#   ./build.sh osx-framework                    # Create OS X framework (requires Xcode env vars)
#   ./build.sh dmg-sign <file.dmg> [identity]   # Sign DMG with codesign
#   ./build.sh dmg-verify <file.dmg>            # Verify signed DMG (codesign -v)
#   ./build.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Android build target folder
ANDROID_RELEASE_FOLDER="${ANDROID_RELEASE_FOLDER:-/Users/$(logname)/Releases/Android}"

usage() {
    echo
    echo -e "${DARKBLUE}Build: Ant, Android (Ant release), OS X framework, or DMG sign/verify.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./build.sh --ant-file <build.xml>${NC}            # Ant build with given build file"
    echo -e "  ${AQUA}./build.sh android <project> [version]${NC}       # Android Ant release, sign, zipalign, copy"
    echo -e "  ${AQUA}./build.sh osx-framework${NC}                     # Create OS X framework (Xcode env vars)"
    echo -e "  ${AQUA}./build.sh dmg-sign <file.dmg> [identity]${NC}    # Sign DMG (codesign -s)"
    echo -e "  ${AQUA}./build.sh dmg-verify <file.dmg>${NC}             # Verify signed DMG (codesign -v)"
    echo -e "  ${AQUA}./build.sh --help${NC}                            # Show this help"
    echo
    echo -e "${BROWN}Requirements:${NC}"
    echo -e "  ${INDIGO}--ant-file:${NC}    Path to build.xml (e.g. path/to/build.xml)"
    echo -e "  ${INDIGO}android:${NC}       ANDROID_HOME set; run from project with build.xml; optional meetxandroid.keystore"
    echo -e "  ${INDIGO}osx-framework:${NC} BUILT_PRODUCTS_DIR, PRODUCT_NAME, TARGET_BUILD_DIR, PUBLIC_HEADERS_FOLDER_PATH (Xcode)"
    echo -e "  ${INDIGO}dmg-sign:${NC}      Path to .dmg; optional identity (e.g. \"Developer ID Application: Name (ID)\")"
    echo -e "  ${INDIGO}dmg-verify:${NC}    Path to signed .dmg"
    echo
}

do_ant() {
    local build_file="$1"
    if [ -z "$build_file" ]; then
        print_error "Build file path required. Usage: ./build.sh --ant-file <path-to-build.xml>"
        exit 1
    fi
    if [ ! -f "$build_file" ]; then
        print_error "Build file not found: $build_file"
        exit 1
    fi
    print_header "Ant Build"
    echo -e "${INDIGO}Building with ant -file ${build_file}${NC}"
    echo
    ant -file "$build_file"
    if [ $? -eq 0 ]; then
        print_success "Ant build completed!"
    else
        print_error "Ant build failed"
        exit 1
    fi
}

do_android() {
    local project="$1"
    local version="$2"
    if [ -z "${ANDROID_HOME}" ]; then
        print_error "ANDROID_HOME is not set. Set it in your profile (e.g. .zprofile)."
        exit 1
    fi
    if [ -z "$project" ]; then
        print_error "Android project name required. Usage: ./build.sh android <project_name> [version]"
        exit 1
    fi
    if [ ! -f build.xml ]; then
        print_error "build.xml not found in current directory. Run from Android project root."
        exit 1
    fi
    print_header "Android Release Build"
    echo -e "${INDIGO}Project: ${AQUA}${project}${NC}"
    echo -e "${INDIGO}ANDROID_HOME: ${AQUA}${ANDROID_HOME}${NC}"
    echo
    echo -e "${BROWN}Cleaning and building release...${NC}"
    ant -f build.xml clean release -Dsdk.dir="$ANDROID_HOME"
    if [ $? -ne 0 ]; then
        print_error "Ant build failed"
        exit 1
    fi
    echo
    echo -e "${BROWN}Signing release...${NC}"
    if [ -f meetxandroid.keystore ]; then
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore meetxandroid.keystore -storepass bvbv134 "bin/${project}-Release-unsigned.apk" meetxandroid
        jarsigner -verify -verbose -certs "bin/${project}-Release-unsigned.apk"
    else
        print_warning "meetxandroid.keystore not found; skipping signing. Sign and zipalign manually if needed."
    fi
    echo
    echo -e "${BROWN}Aligning...${NC}"
    BUILD_TOOLS_DIR=$(find "$ANDROID_HOME/build-tools" -maxdepth 1 -type d -name "[0-9]*" 2>/dev/null | sort -V | tail -1)
    if [ -n "$BUILD_TOOLS_DIR" ]; then
        if [ -f "bin/${project}-Release-unaligned.apk" ]; then
            "$BUILD_TOOLS_DIR/zipalign" -v 4 "bin/${project}-Release-unaligned.apk" "bin/${project}_Release.apk"
        elif [ -f "bin/${project}-Release-unsigned.apk" ]; then
            "$BUILD_TOOLS_DIR/zipalign" -v 4 "bin/${project}-Release-unsigned.apk" "bin/${project}_Release.apk"
        fi
    fi
    if [ -f "bin/${project}_Release.apk" ]; then
        mkdir -p "$ANDROID_RELEASE_FOLDER"
        if [ -n "$version" ]; then
            cp -f "bin/${project}_Release.apk" "$ANDROID_RELEASE_FOLDER/${project}_Release_${version}.apk"
            echo -e "${GREEN}Copied to ${ANDROID_RELEASE_FOLDER}/${project}_Release_${version}.apk${NC}"
        else
            cp -f "bin/${project}_Release.apk" "$ANDROID_RELEASE_FOLDER/${project}_Release.apk"
            echo -e "${GREEN}Copied to ${ANDROID_RELEASE_FOLDER}/${project}_Release.apk${NC}"
        fi
        print_success "Android build completed!"
    fi
}

do_framework() {
    if [ -z "${BUILT_PRODUCTS_DIR}" ] || [ -z "${PRODUCT_NAME}" ]; then
        print_error "Xcode env vars required: BUILT_PRODUCTS_DIR, PRODUCT_NAME, TARGET_BUILD_DIR, PUBLIC_HEADERS_FOLDER_PATH"
        exit 1
    fi
    set -e
    export FRAMEWORK_LOCN="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework"
    mkdir -p "${FRAMEWORK_LOCN}/Versions/A/Headers"
    /bin/ln -sfh A "${FRAMEWORK_LOCN}/Versions/Current"
    /bin/ln -sfh Versions/Current/Headers "${FRAMEWORK_LOCN}/Headers"
    /bin/ln -sfh "Versions/Current/${PRODUCT_NAME}" "${FRAMEWORK_LOCN}/${PRODUCT_NAME}"
    /bin/cp -a "${TARGET_BUILD_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}/" "${FRAMEWORK_LOCN}/Versions/A/Headers"
    print_success "Framework created: ${FRAMEWORK_LOCN}"
}

# DMG: verify signed DMG (codesign -v)
do_dmg_verify() {
    local dmg="$1"
    if [ -z "$dmg" ]; then
        print_error "DMG file path required. Usage: ./build.sh dmg-verify <file.dmg>"
        exit 1
    fi
    if [ ! -f "$dmg" ]; then
        print_error "File not found: $dmg"
        exit 1
    fi
    print_header "Verify DMG Signature"
    echo -e "${INDIGO}Verifying signed DMG: ${AQUA}${dmg}${NC}"
    echo
    codesign -v "$dmg"
    if [ $? -eq 0 ]; then
        print_success "DMG signature is valid!"
    else
        print_error "DMG verification failed"
        exit 1
    fi
}

# DMG: sign DMG (codesign -s)
do_dmg_sign() {
    local dmg="$1"
    local identity="${2:-Developer ID Application: Boardvantage Inc (D2WMJ9F3EU)}"
    if [ -z "$dmg" ]; then
        print_error "DMG file path required. Usage: ./build.sh dmg-sign <file.dmg> [identity]"
        exit 1
    fi
    if [ ! -f "$dmg" ]; then
        print_error "File not found: $dmg"
        exit 1
    fi
    print_header "Sign DMG"
    echo -e "${INDIGO}Signing DMG: ${AQUA}${dmg}${NC}"
    echo -e "${INDIGO}Identity: ${AQUA}${identity}${NC}"
    echo
    codesign -s "$identity" "$dmg"
    if [ $? -eq 0 ]; then
        print_success "DMG signed successfully!"
    else
        print_error "DMG signing failed"
        exit 1
    fi
}

# Parse
if [ $# -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

case "$1" in
    --ant-file)
        do_ant "$2"
        ;;
    android)
        do_android "$2" "$3"
        ;;
    osx-framework|framework)
        do_framework
        ;;
    dmg-verify)
        do_dmg_verify "$2"
        ;;
    dmg-sign)
        do_dmg_sign "$2" "$3"
        ;;
    *)
        print_error "Unknown action: $1"
        usage
        exit 1
        ;;
esac
echo
