#!/bin/bash
# Author: Rohtash Lakra
# JBoss server management utility
# Usage:
#   ./jboss.sh start [--profile profilename]    # Start JBoss with profile (default: default)
#   ./jboss.sh stop                             # Stop JBoss server
#   ./jboss.sh clean                            # Clean temp, logs, and failed deployments
#   ./jboss.sh delete-deployments               # Delete failed deployments and clean directories
#   ./jboss.sh delete-folders                   # Delete tmp, work, log folders
#   ./jboss.sh copy-jars [target]               # Copy JARs/EARs/WARs to remote server
#   ./jboss.sh --help                           # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default JBoss paths and configurations
JBOSS_423GA="/Applications/jboss-4.2.3.GA"
JBOSS_423GA_BLACKROCK="/Applications/JBoss-4.2.3.GA_BlackRock"
JBOSS_423GA_SHAREX="/Applications/JBoss-4.2.3.GA"

# Default copy target
DEFAULT_TARGET_SERVER="rsingh@hc1012.devwest.rslakra.com"
DEFAULT_TARGET_FOLDER="/home/rsingh/Temp"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./jboss.sh start [--profile profilename]${NC} # Start JBoss with profile (default: default)"
    echo -e "  ${AQUA}./jboss.sh stop${NC}                          # Stop JBoss server"
    echo -e "  ${AQUA}./jboss.sh clean${NC}                         # Clean temp, logs, and failed deployments"
    echo -e "  ${AQUA}./jboss.sh delete-deployments${NC}            # Delete failed deployments and clean directories"
    echo -e "  ${AQUA}./jboss.sh delete-folders${NC}                # Delete tmp, work, log folders"
    echo -e "  ${AQUA}./jboss.sh copy-jars [target]${NC}            # Copy JARs/EARs/WARs to remote server"
    echo -e "  ${AQUA}./jboss.sh --help${NC}                        # Show this help"
    echo
    echo -e "${INDIGO}Available profiles:${NC}"
    echo -e "  ${BROWN}default${NC}         - JBoss 4.2.3.GA (default)"
    echo -e "  ${BROWN}423GA${NC}           - JBoss 4.2.3.GA"
    echo -e "  ${BROWN}profile1${NC}        - JBoss 4.2.3.GA custom variant"
    echo -e "  ${BROWN}EAP64GA${NC}         - JBoss EAP 6.4.GA (standalone)"
    echo -e "  ${BROWN}profile2${NC}        - JBoss with custom config"
    echo -e "  ${BROWN}profile2-local${NC}  - JBoss with custom local config"
    echo -e "  ${BROWN}profile3${NC}        - JBoss custom variant"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./jboss.sh start${NC}                         # Start with default profile"
    echo -e "  ${AQUA}./jboss.sh start --profile profile1${NC}      # Start with profile1"
    echo -e "  ${AQUA}./jboss.sh start --profile EAP64GA${NC}       # Start with EAP64GA profile"
    echo -e "  ${AQUA}./jboss.sh stop${NC}"
    echo -e "  ${AQUA}./jboss.sh clean${NC}"
    echo -e "  ${AQUA}./jboss.sh copy-jars${NC}"
    echo
}

# Function to clean JBoss directories
clean_jboss() {
    local jboss_home="${1:-$JBOSS_HOME}"
    
    if [ -z "$jboss_home" ]; then
        print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable."
        exit 1
    fi
    
    print_header "Clean JBoss Directories"
    echo -e "${INDIGO}Cleaning JBoss at: ${AQUA}${jboss_home}${NC}"
    echo
    
    # Check if standalone or server/default structure
    if [ -d "${jboss_home}/standalone" ]; then
        # EAP 6.x structure
        local standalone="${jboss_home}/standalone"
        local deploy_dir="${standalone}/deployments"
        local log_dir="${standalone}/log"
        local tmp_dir="${standalone}/tmp"
        
        echo -e "${INDIGO}Deleting failed deployments...${NC}"
        rm -rf ${deploy_dir}/*.failed 2>/dev/null
        print_success "Failed deployments deleted"
        echo
        
        echo -e "${INDIGO}Deleting temp directory...${NC}"
        rm -rf ${tmp_dir}/*.* 2>/dev/null
        print_success "Temp directory cleaned"
        echo
        
        echo -e "${INDIGO}Deleting log directory...${NC}"
        rm -rf ${log_dir}/*.* 2>/dev/null
        print_success "Log directory cleaned"
        echo
    else
        # JBoss 4.x structure
        local default_dir="${jboss_home}/server/default"
        
        if [ -d "$default_dir" ]; then
            echo -e "${INDIGO}Deleting log directory...${NC}"
            rm -rf ${default_dir}/log 2>/dev/null
            print_success "Log directory deleted"
            echo
            
            echo -e "${INDIGO}Deleting tmp directory...${NC}"
            rm -rf ${default_dir}/tmp 2>/dev/null
            print_success "Tmp directory deleted"
            echo
            
            echo -e "${INDIGO}Deleting work directory...${NC}"
            rm -rf ${default_dir}/work 2>/dev/null
            print_success "Work directory deleted"
            echo
        fi
    fi
    
    print_success "JBoss cleanup completed!"
    echo
}

# Function to delete deployments
delete_deployments() {
    if [ -z "$JBOSS_HOME" ]; then
        print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable."
        exit 1
    fi
    
    print_header "Delete JBoss Deployments"
    
    local standalone="${JBOSS_HOME}/standalone"
    local deploy_dir="${standalone}/deployments"
    local log_dir="${standalone}/log"
    local tmp_dir="${standalone}/tmp"
    
    echo -e "${INDIGO}Deleting failed deployments...${NC}"
    echo -e "${BROWN}rm -rf ${deploy_dir}/*.failed${NC}"
    rm -rf ${deploy_dir}/*.failed
    echo
    
    echo -e "${INDIGO}Deleting Thristle deployments...${NC}"
    echo -e "${BROWN}rm -rf ${deploy_dir}/Thristle*.*${NC}"
    rm -rf ${deploy_dir}/Thristle*.*
    ls -la ${deploy_dir}
    echo
    
    echo -e "${INDIGO}Deleting log directory...${NC}"
    echo -e "${BROWN}rm -rf ${log_dir}/*.*${NC}"
    rm -rf ${log_dir}/*.*
    ls -la ${log_dir}
    echo
    
    echo -e "${INDIGO}Deleting tmp directory...${NC}"
    echo -e "${BROWN}rm -rf ${tmp_dir}/*.*${NC}"
    rm -rf ${tmp_dir}/*.*
    ls -la ${tmp_dir}
    echo
    
    print_success "Deployments deleted successfully!"
    echo
}

# Function to delete folders (JBoss 4.x style)
delete_folders() {
    if [ -z "$JBOSS_HOME" ]; then
        print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable."
        exit 1
    fi
    
    print_header "Delete JBoss Folders"
    
    local default_dir="${JBOSS_HOME}/server/default"
    
    echo -e "${INDIGO}Deleting tmp folder...${NC}"
    echo -e "${BROWN}rm -rf ${default_dir}/tmp${NC}"
    rm -rf ${default_dir}/tmp
    echo
    
    echo -e "${INDIGO}Deleting work folder...${NC}"
    echo -e "${BROWN}rm -rf ${default_dir}/work${NC}"
    rm -rf ${default_dir}/work
    echo
    
    echo -e "${INDIGO}Deleting log folder...${NC}"
    echo -e "${BROWN}rm -rf ${default_dir}/log${NC}"
    rm -rf ${default_dir}/log
    echo
    
    echo -e "${INDIGO}Deleting ShareX.ear...${NC}"
    echo -e "${BROWN}rm -rf ${default_dir}/deploy/ShareX.ear${NC}"
    rm -rf ${default_dir}/deploy/ShareX.ear
    echo
    
    echo -e "${INDIGO}Listing ${default_dir}...${NC}"
    ls -l ${default_dir}
    echo
    
    print_success "Folders deleted successfully!"
    echo
}

# Function to copy JARs to remote server
copy_jars() {
    if [ -z "$JBOSS_HOME" ]; then
        print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable."
        exit 1
    fi
    
    print_header "Copy JBoss JARs to Remote Server"
    
    local target="${1:-${DEFAULT_TARGET_SERVER}:${DEFAULT_TARGET_FOLDER}}"
    local deploy_dir="${JBOSS_HOME}/standalone/deployments"
    
    # Check if deployments directory exists
    if [ ! -d "$deploy_dir" ]; then
        print_error "Deployments directory not found: ${deploy_dir}"
        exit 1
    fi
    
    local dadvantage_ear="DVantage.ear"
    local dvclient_war="dvclient.war"
    local meetxclient_war="MeetXClient.war"
    
    echo -e "${INDIGO}Target: ${AQUA}${target}${NC}"
    echo
    
    # Copy DVantage.ear
    if [ -d "${deploy_dir}/${dadvantage_ear}" ]; then
        echo -e "${INDIGO}Copying [${AQUA}${dadvantage_ear}${INDIGO}]...${NC}"
        echo -e "${BROWN}scp -r ${deploy_dir}/${dadvantage_ear} ${target}/.${NC}"
        scp -r ${deploy_dir}/${dadvantage_ear} ${target}/.
        if [ $? -eq 0 ]; then
            print_success "[${dadvantage_ear}] copied successfully!"
        else
            print_error "Failed to copy [${dadvantage_ear}]"
        fi
        echo
    else
        print_warning "[${dadvantage_ear}] not found, skipping..."
        echo
    fi
    
    # Copy dvclient.war
    if [ -d "${deploy_dir}/${dvclient_war}" ]; then
        echo -e "${INDIGO}Copying [${AQUA}${dvclient_war}${INDIGO}]...${NC}"
        echo -e "${BROWN}scp -r ${deploy_dir}/${dvclient_war} ${target}/.${NC}"
        scp -r ${deploy_dir}/${dvclient_war} ${target}/.
        if [ $? -eq 0 ]; then
            print_success "[${dvclient_war}] copied successfully!"
        else
            print_error "Failed to copy [${dvclient_war}]"
        fi
        echo
    else
        print_warning "[${dvclient_war}] not found, skipping..."
        echo
    fi
    
    # Copy MeetXClient.war
    if [ -d "${deploy_dir}/${meetxclient_war}" ]; then
        echo -e "${INDIGO}Copying [${AQUA}${meetxclient_war}${INDIGO}]...${NC}"
        echo -e "${BROWN}scp -r ${deploy_dir}/${meetxclient_war} ${target}/.${NC}"
        scp -r ${deploy_dir}/${meetxclient_war} ${target}/.
        if [ $? -eq 0 ]; then
            print_success "[${meetxclient_war}] copied successfully!"
        else
            print_error "Failed to copy [${meetxclient_war}]"
        fi
        echo
    else
        print_warning "[${meetxclient_war}] not found, skipping..."
        echo
    fi
    
    print_success "Copy operation completed!"
    echo
}

# Function to start JBoss with different profiles
start_jboss() {
    local profile="${1:-default}"
    
    print_header "Start JBoss Server"
    
    case "$profile" in
        default|423GA)
            export JBOSS_HOME="$JBOSS_423GA"
            echo -e "${INDIGO}Starting JBoss 4.2.3.GA...${NC}"
            echo -e "${AQUA}JBOSS_HOME=${JBOSS_HOME}${NC}"
            echo
            
            clean_jboss "$JBOSS_HOME"
            
            # Clear output log
            > ~/out.log
            
            echo -e "${INDIGO}Starting JBoss in background...${NC}"
            echo -e "${BROWN}nohup ${JBOSS_HOME}/bin/run.sh -b 0.0.0.0 > ~/out.log &${NC}"
            nohup ${JBOSS_HOME}/bin/run.sh -b 0.0.0.0 > ~/out.log &
            print_success "JBoss started in background! (Check ~/out.log for output)"
            ;;
            
        profile1)
            export JBOSS_HOME="$JBOSS_423GA_BLACKROCK"
            echo -e "${INDIGO}Starting JBoss 4.2.3.GA (profile1)...${NC}"
            echo -e "${AQUA}JBOSS_HOME=${JBOSS_HOME}${NC}"
            echo
            
            clean_jboss "$JBOSS_HOME"
            
            # Clear output log
            > ~/out.log
            
            echo -e "${INDIGO}Starting JBoss in background...${NC}"
            echo -e "${BROWN}nohup ${JBOSS_HOME}/bin/run.sh -b 0.0.0.0 > ~/out.log &${NC}"
            nohup ${JBOSS_HOME}/bin/run.sh -b 0.0.0.0 > ~/out.log &
            print_success "JBoss started in background! (Check ~/out.log for output)"
            ;;
            
        EAP64GA)
            if [ -z "$JBOSS_HOME" ]; then
                print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable for EAP 6.4.GA."
                exit 1
            fi
            
            echo -e "${INDIGO}Starting JBoss EAP 6.4.GA...${NC}"
            echo -e "${AQUA}JBOSS_HOME=${JBOSS_HOME}${NC}"
            echo
            
            clean_jboss "$JBOSS_HOME"
            
            echo -e "${INDIGO}Starting JBoss standalone...${NC}"
            echo -e "${BROWN}${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -server-config=standalone-full-dev.xml${NC}"
            echo
            ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -server-config=standalone-full-dev.xml
            ;;
            
        profile2)
            if [ -z "$JBOSS_HOME" ]; then
                print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable."
                exit 1
            fi
            
            echo -e "${INDIGO}Starting JBoss with profile2 config...${NC}"
            echo -e "${AQUA}JBOSS_HOME=${JBOSS_HOME}${NC}"
            echo
            
            clean_jboss "$JBOSS_HOME"
            
            echo -e "${INDIGO}Starting JBoss standalone...${NC}"
            echo -e "${BROWN}${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -server-config=standalone-full-dev.xml${NC}"
            echo
            ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -server-config=standalone-full-dev.xml
            ;;
            
        profile2-local)
            if [ -z "$JBOSS_HOME" ]; then
                print_error "JBOSS_HOME is not set. Please set JBOSS_HOME environment variable."
                exit 1
            fi
            
            echo -e "${INDIGO}Starting JBoss with profile2-local config...${NC}"
            echo -e "${AQUA}JBOSS_HOME=${JBOSS_HOME}${NC}"
            echo
            
            echo -e "${INDIGO}Starting JBoss standalone...${NC}"
            echo -e "${BROWN}${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -server-config=standalone-full-dev-local.xml${NC}"
            echo
            ${JBOSS_HOME}/bin/standalone.sh -b 0.0.0.0 -server-config=standalone-full-dev-local.xml
            ;;
            
        profile3)
            export JBOSS_HOME="$JBOSS_423GA_SHAREX"
            echo -e "${INDIGO}Starting JBoss profile3...${NC}"
            echo -e "${AQUA}JBOSS_HOME=${JBOSS_HOME}${NC}"
            echo
            
            clean_jboss "$JBOSS_HOME"
            
            # Clear output log
            > ~/out.log
            
            echo -e "${INDIGO}Starting JBoss in background...${NC}"
            echo -e "${BROWN}nohup ${JBOSS_HOME}/bin/run.sh -b 0.0.0.0 > ~/out.log &${NC}"
            nohup ${JBOSS_HOME}/bin/run.sh -b 0.0.0.0 > ~/out.log &
            print_success "JBoss started in background! (Check ~/out.log for output)"
            ;;
            
        *)
            print_error "Unknown profile: $profile"
            echo
            echo -e "${INDIGO}Available profiles:${NC} default, 423GA, profile1, EAP64GA, profile2, profile2-local, profile3"
            exit 1
            ;;
    esac
    
    echo
}

# Function to stop JBoss
stop_jboss() {
    print_header "Stop JBoss Server"
    
    echo -e "${INDIGO}Stopping all JBoss processes...${NC}"
    echo -e "${BROWN}ps -ef | grep org.jboss | grep -v grep | awk '{print \$2}' | xargs kill -9${NC}"
    echo
    
    ps -ef | grep org.jboss | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "JBoss processes stopped successfully!"
    else
        print_warning "No JBoss processes found or already stopped"
    fi
    echo
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

case "$1" in
    start)
        # Parse profile option
        PROFILE="default"
        shift  # Remove "start" from arguments
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                --profile)
                    if [ -z "$2" ]; then
                        print_error "Please provide a profile name after --profile"
                        usage
                        exit 1
                    fi
                    PROFILE="$2"
                    shift 2
                    ;;
                *)
                    print_error "Unknown option for start: $1"
                    usage
                    exit 1
                    ;;
            esac
        done
        
        start_jboss "$PROFILE"
        ;;
    stop)
        stop_jboss
        ;;
    clean)
        clean_jboss
        ;;
    delete-deployments)
        delete_deployments
        ;;
    delete-folders)
        delete_folders
        ;;
    copy-jars)
        copy_jars "$2"
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        print_error "Unknown action: $1"
        usage
        exit 1
        ;;
esac
