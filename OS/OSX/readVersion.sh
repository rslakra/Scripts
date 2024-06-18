#!/bin/bash
vStr="Version:"
bStr="Build:"
filePath="assets/AppSupport.info"
#Define Function Here
BuildVersion() {
    vStr="Version:"
    bStr="Build:"
    #read file
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == "$vStr"* ]]; then
            #echo "$line"
            sVer=${line:8}
        elif [[ $line == "$bStr"* ]]; then
            sVer+="."${line:6}
        fi
        #echo "$line"
    done < ${filePath}
    echo $sVer
    #return $sVer
}

#Calling Function
BuildVersion
echo "Build Version:".${sVer}
