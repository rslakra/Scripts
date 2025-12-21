#!/bin/bash
# Author: Rohtash Lakra
# SSH on AWS EC2 Instance

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

HOME_DIR=$HOME
AWS_DIR="Documents/AWS"
ENV=${1:-"dev"}
AWS_EC2_INSTANCE_IP=${2:-"10.100.7.30"}
AWS_CERT_PATH="${HOME_DIR}/${AWS_DIR}/bastion-${ENV}.pem"
echo -e "${INDIGO}Accessing [${AQUA}${AWS_EC2_INSTANCE_IP}${INDIGO}] Instance via SSH${NC}"
#ssh -i ~/$AWS_DIR/bastion-dev.pem ec2-user@10.100.7.30
echo

# Usage
usage() {
   echo
   echo -e "${DARKBLUE}Usage:${NC} ~/sshInstance <ENV> <AWS_EC2_INSTANCE_IP>"
   echo -e "${BROWN}Options:${NC}"
   echo -e "  ${AQUA}ENV${NC}                  - One of (dev, stg, prod) Environments"
   echo -e "  ${AQUA}AWS_EC2_INSTANCE_IP${NC}  - IP of EC2 Instance"
   echo
   echo -e "${BROWN}Example:${NC} ~/sshInstance dev 10.100.7.30"
   echo -e "${BROWN}OR${NC}"
   echo -e "${BROWN}Example:${NC} ~/sshInstance"
   echo
}

SSH_CMD="ssh -i ${AWS_CERT_PATH} ec2-user@${AWS_EC2_INSTANCE_IP}"
echo -e "${AQUA}${SSH_CMD}${NC}"
exec $SSH_CMD
echo
