#!/bin/bash
#set -x 

# Shows you the largest objects in your repo's pack file.
# Written for osx.
#
# @see http://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
# @author Antony Stubbs

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# set the internal field spereator to line break, so that we can iterate easily over the verify-pack output
IFS=$'\n';

print_header "Git Large Size Files"

# list all objects including their size, sort by size, take top 10
objects=`git verify-pack -v .git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head`

echo -e "${BROWN}All sizes are in kB's. The pack column is the size of the object, compressed, inside the pack file.${NC}"
echo

output="size,pack,SHA,location"
for y in $objects
do
	# extract the size in bytes
	size=$((`echo $y | cut -f 5 -d ' '`/1024))
	# extract the compressed size in bytes
	compressedSize=$((`echo $y | cut -f 6 -d ' '`/1024))
	# extract the SHA
	sha=`echo $y | cut -f 1 -d ' '`
	# find the objects location in the repository tree
	other=`git rev-list --all --objects | grep $sha`
	#lineBreak=`echo -e "\n"`
	output="${output}\n${size},${compressedSize},${other}"
done

echo -e $output | column -t -s ', '
echo
