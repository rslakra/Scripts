#!/bin/bash
vStr="Version:"
bStr="Build:"
#echo "$vStr"
#echo ${#vStr}
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == "$vStr"* ]]; then
        #echo "$line"
        sVer=${line:8}
    elif [[ $line == "$bStr"* ]]; then
        sVer+="."${line:6}
    fi
    #echo "$line"
done < "$1"
echo $sVer
