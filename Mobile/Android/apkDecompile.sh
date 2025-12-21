#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

clear
apkFilePath=$1
# Steps to decompile .apk file.
#Check the .apk file name is provided
if [ -n "$apkFilePath" ]; then
	print_header "APK Decompiler"
	# Steps to decompile .apk file.
	echo -e "${INDIGO}Decompiling [${AQUA}${apkFilePath}${INDIGO}] ...${NC}"
	# Steps to decompile .apk file.
	echo -e "${INDIGO}Preparing Folder Structure ...${NC}"
	apkFileName=`basename ${apkFilePath##*/}`
	echo -e "${AQUA}apkFileName:${NC} ${apkFileName}"
	apkPath=`dirname ${apkFilePath}`
	echo -e "${AQUA}apkPath:${NC} ${apkPath}"
	unZipFilePath="${apkFilePath}.zip"
	echo -e "${AQUA}unZipFilePath:${NC} ${unZipFilePath}"
	rm -rf $unZipFilePath
	mkdir $unZipFilePath
	cp $apkFilePath $unZipFilePath/.
	echo -e "${INDIGO}Unzip: ${AQUA}${unZipFilePath}/${apkFileName}${NC}"
	unzip ${apkFilePath} -d ${unZipFilePath}
	echo
	echo -e "${INDIGO}Convert .dex file to .class files (zipped as jar)${NC}"
	cd ${unZipFilePath}
	echo -e "${AQUA}Folder:${NC} `pwd`"
	${DEX2JAR_HOME}/d2j-dex2jar.sh -f $apkFileName
	print_success "APK decompiled successfully!"
	echo
else
	print_error "Please, provide the .apk file with path to decompile"
	echo
	echo -e "${DARKBLUE}Syntax:${NC}"
    	echo -e "./apkDecompile.sh APK_FILE_PATH"
	echo
	echo -e "${BROWN}<APK_FILE_PATH> is mandatory.${NC}"
	echo
fi
