#!/bin/bash
# Author: Rohtash Lakra
# SSH on AWS EC2 Instance

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

print_header "AWS EC2 Instance SSH"
AWS_REGION=${1:-"us-east-1"}
AWS_AVAIL_ZONE=${2:-"us-east-1"}
AWS_INSTANCE_ID=${3:-"AWS_INSTANCE_ID"}
AWS_PUB_CERT_PATH=${4:-"file://aws-rsl-dev.pub"}
echo -e "${INDIGO}Accessing AWS Region: ${AQUA}${AWS_REGION}${INDIGO} via SSH${NC}"
echo
aws ec2-instance-connect send-ssh-public-key \
    --region ${AWS_REGION} \
    --availability-zone ${AWS_AVAIL_ZONE}  \
    --instance-id ${AWS_INSTANCE_ID} \
    --instance-os-user ec2-user \
    --ssh-public-key ${AWS_PUB_CERT_PATH}
echo
