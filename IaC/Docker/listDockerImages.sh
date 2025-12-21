#!/bin/bash

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "Docker Images"
# Custom format with fields in order: IMAGE ID, SIZE, CREATED, TAG, DIGEST, REPOSITORY
# Docker's table format automatically makes headers bold
DOCKER_IMAGES_FORMAT="table {{.ID}}\t{{.Size}}\t{{.CreatedAt}}\t{{.Digest}}\t{{.Tag}}\t{{.Repository}}"
DOCKER_IMAGES_FORMAT_SHORT="table {{.ID}}\t{{.Size}}\t{{.CreatedAt}}\t{{.Tag}}"

# Check for --short flag
if [ "$1" == "--short" ]; then
    # Short format with minimal columns: ID, Size, Created, Tag
    docker images --format "$DOCKER_IMAGES_FORMAT_SHORT"
else
    # Full format with all columns
    # Try with all fields first
    output=$(docker images --format "$DOCKER_IMAGES_FORMAT" 2>&1)
    if [ $? -eq 0 ]; then
        # All fields are supported - use the custom format with bold headers
        docker images --format "$DOCKER_IMAGES_FORMAT"
    else
        # Fallback - try without Digest if it's not available
        docker images --format "table {{.ID}}\t{{.Size}}\t{{.CreatedAt}}\t{{.Tag}}\t{{.Repository}}"
    fi
fi
echo

