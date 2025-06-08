#!/bin/bash
echo
docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.VirtualSize}}\t{{.CreatedSince}}\t{{.Digest}}"
echo

