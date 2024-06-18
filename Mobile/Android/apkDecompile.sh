#!/bin/bash
clear
apkFilePath=$1
# Steps to decompile .apk file.
#Check the .apk file name is provided
if [ -n "$apkFilePath" ]; then
	# Steps to decompile .apk file.
	echo
	echo "Decompiling [${apkFilePath}] ..."
	# Steps to decompile .apk file.
	echo "Preparing Folder Structure  ..."
	apkFileName=`basename ${apkFilePath##*/}`
	echo "apkFileName: ${apkFileName}"
	apkPath=`dirname ${apkFilePath}`
	echo "apkPath: ${apkPath}"
	unZipFilePath="${apkFilePath}.zip"
	echo "unZipFilePath: ${unZipFilePath}"
	rm -rf $unZipFilePath
	mkdir $unZipFilePath
	cp $apkFilePath $unZipFilePath/.
	echo "Unzip: ${unZipFilePath}/${apkFileName}"
	unzip ${apkFilePath} -d ${unZipFilePath}
	echo
	echo "Convert .dex file to .class files (zipped as jar)"
	cd ${unZipFilePath}
	echo "Folder:`pwd`"
	${DEX2JAR_HOME}/d2j-dex2jar.sh -f $apkFileName
	echo
else
	echo
	echo "Please, provide the .apk file with path to decompile"
	echo "Syntax:"
    	echo "./apkDecompile.sh APK_FILE_PATH"
	echo
	echo "<APK_FILE_PATH> is mandatory."
	echo
fi
