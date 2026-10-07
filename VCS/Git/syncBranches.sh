#!/bin/bash
# Author: Rohtash Lakra
# Sync Git branches across multiple projects in a workspace

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Purpose:${NC} Sync Git branches across multiple projects in a workspace."
    echo -e "${INDIGO}This script synchronizes specified Git branches across multiple projects by checking out each branch, resetting to match the remote, and pulling latest changes.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./syncBranches.sh [options]${NC}"
    echo -e "  ${AQUA}./syncBranches.sh --help${NC}  # Show this help"
    echo
    echo -e "${BROWN}All Available Options:${NC}"
    echo
    echo -e "  ${INDIGO}--help, -h${NC}"
    echo -e "    Show this help message and exit."
    echo
    echo -e "  ${INDIGO}--projects <proj1> <proj2> ...${NC}"
    echo -e "    Specify one or more project names as command-line arguments."
    echo -e "    Projects should be directory names within the workspace."
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--projects project1 project2 project3${NC}"
    echo
    echo -e "  ${INDIGO}--sync <projects.txt> [excludes.txt]${NC}"
    echo -e "    Shorthand option to sync projects from a file and optionally exclude projects from another file."
    echo -e "    First file contains projects to sync, second file (optional) contains projects to exclude."
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--sync projects.txt excludes.txt${NC}"
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--sync projects.txt${NC}  ${INDIGO}# Exclude file is optional${NC}"
    echo
    echo -e "  ${INDIGO}--clean${NC}"
    echo -e "    Remove untracked files and directories after syncing each branch."
    echo -e "    This performs ${AQUA}git clean -f -d${NC} to ensure a completely clean working directory."
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--clean --projects proj1 proj2${NC}"
    echo
    echo -e "${BROWN}Default Values:${NC}"
    echo -e "  ${INDIGO}Workspace:${NC} ${AQUA}Current directory${NC} (where the script is executed)"
    echo -e "  ${INDIGO}Branches:${NC} ${AQUA}staging develop${NC} + default branch (${INDIGO}detected from remote HEAD${NC})"
    echo -e "  ${INDIGO}Projects:${NC} ${AQUA}All directories in current directory${NC} (if no options provided)"
    echo
    echo -e "${BROWN}Auto-Detection:${NC}"
    echo -e "  ${INDIGO}If no options are provided, the script automatically looks for:${NC}"
    echo -e "    ${AQUA}projects.txt${NC}  ${INDIGO}- Contains list of projects to sync${NC}"
    echo -e "    ${AQUA}excludes.txt${NC}  ${INDIGO}- Contains list of projects to exclude (optional)${NC}"
    echo -e "  ${INDIGO}These files should be in the current directory where the script is executed.${NC}"
    echo
    echo -e "${BROWN}How It Works:${NC}"
    echo -e "  1. For each project, the script checks out each specified branch"
    echo -e "  2. Fetches latest refs from ${AQUA}origin${NC}"
    echo -e "  3. Resets each branch to match ${AQUA}origin/branch${NC}"
    echo -e "  4. ${INDIGO}(Optional)${NC} Removes untracked files and directories if ${AQUA}--clean${NC} is specified"
    echo -e "  5. Syncs the default branch last and leaves the repo checked out on it"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./syncBranches.sh${NC}"
    echo -e "    ${INDIGO}# Auto-detect projects.txt and excludes.txt in current directory, or sync all projects${NC}"
    echo
    echo -e "  ${AQUA}./syncBranches.sh${NC}  ${INDIGO}# (with projects.txt and excludes.txt in current directory)${NC}"
    echo -e "    ${INDIGO}# Automatically uses projects.txt and excludes.txt from current directory${NC}"
    echo
    echo -e "  ${AQUA}./syncBranches.sh --projects proj1 proj2 proj3${NC}"
    echo -e "    ${INDIGO}# Sync only proj1, proj2, and proj3${NC}"
    echo
    echo -e "  ${AQUA}./syncBranches.sh --sync projects.txt excludes.txt${NC}"
    echo -e "    ${INDIGO}# Shorthand: sync projects.txt excluding excludes.txt${NC}"
    echo
    echo -e "  ${AQUA}cd ~/Workspace && ~/syncBranches${NC}"
    echo -e "    ${INDIGO}# Change to workspace directory and sync all projects${NC}"
    echo
    echo -e "${BROWN}Notes:${NC}"
    echo -e "  ${INDIGO}• Projects must be Git repositories (contain ${AQUA}.git${NC} directory)${NC}"
    echo -e "  ${INDIGO}• Non-existent branches are skipped with a warning${NC}"
    echo -e "  ${INDIGO}• Local branches are created from remote if they don't exist locally${NC}"
    echo -e "  ${INDIGO}• Options can be combined in any order${NC}"
    echo
}

# Function to read text file and populate an array
# Usage: read_txt_file <file_path> <array_name> <description>
read_txt_file() {
    local file_path="$1"
    local array_name="$2"
    local description="$3"
    
    # Expand tilde in file path
    file_path="${file_path/#\~/$HOME}"
    
    # Validate file exists
    if [ ! -f "${file_path}" ]; then
        print_error "${description} file not found: ${file_path}"
        exit 1
    fi
    
    echo -e "${INDIGO}Reading ${description} from file: ${AQUA}${file_path}${NC}"
    
    # Read file and populate array
    local temp_array=()
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        if [ -n "$line" ]; then
            temp_array+=("$line")
        fi
    done < "${file_path}"
    
    # Assign to the named array variable
    eval "${array_name}=(\"\${temp_array[@]}\")"
}

# Detect the repository default branch from the remote (not stale local origin/HEAD)
detect_default_branch() {
    local default_branch

    # Authoritative: ask the remote which branch HEAD points to
    default_branch="$(git ls-remote --symref origin HEAD 2>/dev/null \
        | sed -n 's/^ref: refs\/heads\/\([^[:space:]]*\).*/\1/p' | head -1)"
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
        return 0
    fi

    # Refresh local origin/HEAD from remote, then read it
    git remote set-head origin -a > /dev/null 2>&1
    default_branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
    if [ -n "$default_branch" ]; then
        echo "$default_branch"
        return 0
    fi

    default_branch="$(git remote show origin 2>/dev/null | awk '/HEAD branch/ { print $NF; exit }')"
    if [ -n "$default_branch" ] && [ "$default_branch" != "(unknown)" ]; then
        echo "$default_branch"
        return 0
    fi

    if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
        echo "main"
    else
        echo "master"
    fi
}

# Sync a local branch to match origin/<branch>
sync_branch_to_origin() {
    local branch="$1"

    if [ "$CLEAN_UNTRACKED" = true ]; then
        echo -e "${INDIGO}    Cleaning untracked files and directories...${NC}"
        git clean -f -d > /dev/null 2>&1
        echo -e "${GREEN}    ✓ Cleaned untracked files${NC}"
    fi

    if ! git checkout "$branch" 2>/dev/null; then
        if git checkout -b "$branch" "origin/$branch" 2>/dev/null; then
            echo -e "${INDIGO}    Created local branch ${AQUA}${branch}${INDIGO} from origin${NC}"
        else
            print_warning "    Branch ${branch} does not exist locally or remotely, skipping..."
            return 1
        fi
    fi

    if ! git rev-parse --verify "origin/$branch" > /dev/null 2>&1; then
        print_warning "    Remote branch origin/${branch} not found, skipping..."
        return 1
    fi

    # Fast-forward like `git pull` (prints the per-file diffstat). The fetch was
    # already done, so merging origin/<branch> is equivalent to a pull.
    # If it can't fast-forward (diverged or local changes in the way), force-match origin.
    if ! git merge --ff-only "origin/$branch"; then
        print_warning "    Cannot fast-forward ${branch}, resetting to origin/${branch}..."
        git reset --hard "origin/$branch"
    fi
    echo -e "${GREEN}    ✓ Synced ${branch}${NC}"
    return 0
}

# Check for help option
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
fi

# Initialize variables
WORKSPACE_DIR="${PWD}"  # Use current directory where script is executed
BRANCHES="staging develop"
PROJECTS_FILE=""
PROJECTS_LIST=()
EXCLUDE_FILE=""
EXCLUDE_LIST=()
PROJECTS_TO_SYNC=()
CLEAN_UNTRACKED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --file)
            if [ -z "$2" ]; then
                print_error "File path required after --file"
                usage
                exit 1
            fi
            PROJECTS_FILE="$2"
            shift 2
            ;;
        --projects)
            shift  # Skip --projects
            # Collect all project names until next option
            while [[ $# -gt 0 ]] && [[ ! "$1" =~ ^-- ]]; do
                PROJECTS_LIST+=("$1")
                shift
            done
            ;;
        --exclude)
            if [ -z "$2" ]; then
                print_error "File path required after --exclude"
                usage
                exit 1
            fi
            EXCLUDE_FILE="$2"
            shift 2
            ;;
        --sync)
            if [ -z "$2" ]; then
                print_error "Projects file path required after --sync"
                usage
                exit 1
            fi
            PROJECTS_FILE="$2"
            # Second file (exclude) is optional
            if [ -n "$3" ] && [[ ! "$3" =~ ^-- ]]; then
                EXCLUDE_FILE="$3"
                shift 3
            else
                shift 2
            fi
            ;;
        --clean)
            CLEAN_UNTRACKED=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# If no options provided, check for default files in current directory
if [ -z "${PROJECTS_FILE}" ] && [ ${#PROJECTS_LIST[@]} -eq 0 ] && [ -z "${EXCLUDE_FILE}" ]; then
    # Check for projects.txt in current directory
    if [ -f "${WORKSPACE_DIR}/projects.txt" ]; then
        PROJECTS_FILE="${WORKSPACE_DIR}/projects.txt"
        echo -e "${INDIGO}Found ${AQUA}projects.txt${INDIGO} in current directory${NC}"
    fi
    
    # Check for excludes.txt in current directory
    if [ -f "${WORKSPACE_DIR}/excludes.txt" ]; then
        EXCLUDE_FILE="${WORKSPACE_DIR}/excludes.txt"
        echo -e "${INDIGO}Found ${AQUA}excludes.txt${INDIGO} in current directory${NC}"
    fi
fi

# Validate workspace directory
if [ ! -d "${WORKSPACE_DIR}" ]; then
    print_error "Workspace directory does not exist: ${WORKSPACE_DIR}"
    exit 1
fi

# Collect projects to sync
if [ -n "${PROJECTS_FILE}" ]; then
    # Read from file using modular function
    read_txt_file "${PROJECTS_FILE}" "PROJECTS_TO_SYNC" "projects"
elif [ ${#PROJECTS_LIST[@]} -gt 0 ]; then
    # Use provided project list
    PROJECTS_TO_SYNC=("${PROJECTS_LIST[@]}")
else
    # Default: sync all directories in workspace
    echo -e "${INDIGO}No projects specified, syncing all directories in workspace...${NC}"
    for entry in "${WORKSPACE_DIR}"/*; do
        if [ -d "${entry}" ]; then
            PROJECTS_TO_SYNC+=("$(basename "${entry}")")
        fi
    done
fi

# Read excluded projects from file if provided
if [ -n "${EXCLUDE_FILE}" ]; then
    # Read from file using modular function
    read_txt_file "${EXCLUDE_FILE}" "EXCLUDE_LIST" "excluded projects"
fi

# Filter out excluded projects
if [ ${#EXCLUDE_LIST[@]} -gt 0 ]; then
    echo -e "${INDIGO}Excluding projects: ${AQUA}${EXCLUDE_LIST[*]}${NC}"
    FILTERED_PROJECTS=()
    for project in "${PROJECTS_TO_SYNC[@]}"; do
        exclude=false
        for exclude_item in "${EXCLUDE_LIST[@]}"; do
            if [ "$project" == "$exclude_item" ]; then
                exclude=true
                break
            fi
        done
        if [ "$exclude" = false ]; then
            FILTERED_PROJECTS+=("$project")
        fi
    done
    PROJECTS_TO_SYNC=("${FILTERED_PROJECTS[@]}")
fi

# Validate we have projects to sync
if [ ${#PROJECTS_TO_SYNC[@]} -eq 0 ]; then
    print_warning "No projects to sync"
    exit 0
fi

# Print summary
print_header "Sync Branches"
echo -e "${INDIGO}Workspace: ${AQUA}${WORKSPACE_DIR}${NC}"
echo -e "${INDIGO}Branches: ${AQUA}${BRANCHES} + default branch${NC}"
echo -e "${INDIGO}Projects to sync: ${AQUA}${#PROJECTS_TO_SYNC[@]}${NC}"
if [ ${#PROJECTS_TO_SYNC[@]} -le 10 ]; then
    echo -e "${INDIGO}Project list: ${AQUA}${PROJECTS_TO_SYNC[*]}${NC}"
fi
if [ "$CLEAN_UNTRACKED" = true ]; then
    echo -e "${INDIGO}Clean mode: ${AQUA}Enabled${NC} ${INDIGO}(will remove untracked files)${NC}"
fi
echo

# Save current directory
CURR_DIR=$PWD

# Sync each project
SYNCED_COUNT=0
FAILED_COUNT=0
FAILED_PROJECTS=()

for project in "${PROJECTS_TO_SYNC[@]}"; do
    pathEntry="${WORKSPACE_DIR}/${project}"
    
    if [[ ! -d "${pathEntry}" ]]; then
        print_warning "${pathEntry} is not a directory, skipping..."
        continue
    fi
    
    # Check if it's a git repository
    if [[ ! -d "${pathEntry}/.git" ]]; then
        print_warning "${project} is not a Git repository, skipping..."
        continue
    fi
    
    echo
    echo -e "${INDIGO}Syncing [${AQUA}${project}${INDIGO}] ...${NC}"
    echo
    
    cd "${pathEntry}" || {
        print_error "Failed to change directory to ${pathEntry}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_PROJECTS+=("$project")
        continue
    }
    
    if ! git fetch origin --prune > /dev/null 2>&1; then
        print_warning "Failed to fetch from origin for ${project}. Continuing with local remote refs..."
    fi

    DEFAULT_BRANCH=$(detect_default_branch)
    echo -e "${INDIGO}  Default branch: ${AQUA}${DEFAULT_BRANCH}${NC}"

    for branch in $BRANCHES; do
        if [ "$branch" = "$DEFAULT_BRANCH" ]; then
            continue
        fi

        echo -e "${INDIGO}  Checking out [${AQUA}${branch}${INDIGO}] ...${NC}"
        sync_branch_to_origin "$branch"
        echo
    done

    echo -e "${INDIGO}  Checking out [${AQUA}${DEFAULT_BRANCH}${INDIGO}] (default) ...${NC}"
    if ! sync_branch_to_origin "$DEFAULT_BRANCH"; then
        print_warning "  Could not sync default branch ${DEFAULT_BRANCH} for ${project}"
    fi
    echo
    
    SYNCED_COUNT=$((SYNCED_COUNT + 1))
done

# Return to original directory
cd "$CURR_DIR" || true

# Print summary
echo
if [ $FAILED_COUNT -eq 0 ]; then
    print_success "Sync completed! Synced ${SYNCED_COUNT} project(s)."
else
    print_warning "Sync completed with errors. Synced ${SYNCED_COUNT} project(s), failed ${FAILED_COUNT} project(s)."
    if [ ${#FAILED_PROJECTS[@]} -gt 0 ]; then
        echo -e "${INDIGO}Failed projects: ${AQUA}${FAILED_PROJECTS[*]}${NC}"
    fi
fi
echo
