#!/bin/bash
# Author: Rohtash Lakra
# Shows Docker disk usage: which images take space, which container/compose service
# uses each image, and how to remove them safely (with the side effects explained).
# Usage:
#   ~/diskDockerUsage [options]
#   ~/diskDockerUsage --help

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Show Docker disk usage, the service each image belongs to, and how to remove images.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}~/diskDockerUsage [options]${NC}"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo -e "  ${INDIGO}-n, --top N${NC}             Show only the N largest images (default: all, 0 = all)"
    echo -e "  ${INDIGO}-o, --order ORDER${NC}       Sort by size: desc | asc (default: desc)"
    echo -e "  ${INDIGO}-u, --unused${NC}            Only images not used by any container (safe removal candidates)"
    echo -e "  ${INDIGO}-d, --dangling${NC}          Only dangling images (<none>:<none>)"
    echo -e "  ${INDIGO}-r, --remove IMAGE${NC}      Remove one image (ID or name:tag) after showing side effects and asking"
    echo -e "  ${INDIGO}-p, --prune${NC}             Remove all dangling images (asks first)"
    echo -e "  ${INDIGO}-P, --prune-unused${NC}      Remove ALL images not used by any container (asks first)"
    echo -e "  ${INDIGO}-g, --guide${NC}             Show all removal commands and their side effects"
    echo -e "  ${INDIGO}-h, --help${NC}              Show this help message"
    echo
    echo -e "${BROWN}Status column:${NC}"
    echo -e "  ${AQUA}IN-USE${NC}      used by at least one running container"
    echo -e "  ${AQUA}STOPPED${NC}     used only by stopped containers (image cannot be removed until they are)"
    echo -e "  ${AQUA}UNUSED${NC}      tagged image no container uses"
    echo -e "  ${AQUA}DANGLING${NC}    untagged (<none>) image no container uses, usually a leftover of a rebuild"
    echo
    echo -e "${BROWN}Service column:${NC} docker-compose 'project/service' when available, otherwise the container name."
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}~/diskDockerUsage${NC}                        # All images, largest first, with owning service"
    echo -e "  ${AQUA}~/diskDockerUsage -n 5${NC}                   # 5 largest images"
    echo -e "  ${AQUA}~/diskDockerUsage -u${NC}                     # What can be removed without breaking a container"
    echo -e "  ${AQUA}~/diskDockerUsage -r myapp:latest${NC}        # Remove one image (with confirmation)"
    echo -e "  ${AQUA}~/diskDockerUsage -p${NC}                     # Remove dangling images"
    echo
}

# Prints removal commands and their side effects
show_guide() {
    print_header "Docker Cleanup Guide"
    echo -e "${BROWN}Remove one image${NC}                 ${AQUA}docker rmi <image>${NC}"
    echo "  - Frees only the layers no other image shares (shared layers stay, so freed space can be less than listed)."
    echo "  - Fails if any container (even stopped) uses the image; remove the container first (docker rm)."
    echo "  - If the image has several tags, only the tag you name is removed."
    echo "  - Next 'docker run' / 'compose up' must pull again (time, bandwidth, registry rate limits) or rebuild."
    echo "  - A locally built image whose Dockerfile/sources are gone cannot be recreated."
    echo
    echo -e "${BROWN}Force remove${NC}                     ${AQUA}docker rmi -f <image>${NC}"
    echo "  - Untags the image even if containers use it. Running containers keep running, but they can no"
    echo "    longer be recreated from that image and 'docker ps' shows the bare image ID."
    echo
    echo -e "${BROWN}Dangling images${NC}                  ${AQUA}docker image prune${NC}"
    echo "  - Removes untagged leftovers of rebuilds. Lowest risk."
    echo "  - Side effect: you lose the previous build of a tag, so you cannot roll back to it."
    echo
    echo -e "${BROWN}All unused images${NC}                ${AQUA}docker image prune -a${NC}"
    echo "  - Removes every image no container uses. Stopped containers still count as 'using' an image."
    echo "  - Side effect: everything not currently in a container is pulled/built again when needed."
    echo
    echo -e "${BROWN}Stopped containers${NC}               ${AQUA}docker container prune${NC}"
    echo "  - Deletes stopped containers and their writable layer. Data written inside the container"
    echo "    (not in a volume) is lost. This also lets their images become removable."
    echo
    echo -e "${BROWN}Build cache${NC}                      ${AQUA}docker builder prune${NC}"
    echo "  - Side effect: the next builds are slower because all layers are rebuilt."
    echo
    echo -e "${RED}Volumes (DATA LOSS)${NC}              ${AQUA}docker volume prune${NC}"
    echo "  - Deletes volumes no container references: databases, uploads, etc. cannot be recovered."
    echo
    echo -e "${RED}Everything${NC}                       ${AQUA}docker system prune -a --volumes${NC}"
    echo "  - Combines all of the above, including volumes. Avoid unless you really want a clean slate."
    echo
    echo -e "${BROWN}Docker Desktop (macOS)${NC}"
    echo "  - Docker stores everything in one disk file (Docker.raw). Removing images frees space inside it;"
    echo "    the file on your Mac may shrink only after Docker Desktop reclaims space or is restarted."
    echo "  - Check: Docker Desktop > Settings > Resources > Disk image size."
    echo
}

# Asks a yes/no question, default no
confirm() {
    local answer
    read -r -p "$1 [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

# Shows the Docker Desktop disk file (macOS), if present
show_desktop_disk() {
    local base="$HOME/Library/Containers/com.docker.docker/Data/vms/0/data"
    local f
    for f in "$base/Docker.raw" "$base/Docker.qcow2"; do
        if [ -f "$f" ]; then
            echo -e "${AQUA}Docker Desktop disk file:${NC} ${f}"
            echo "  Actual size on disk: $(du -h "$f" 2>/dev/null | cut -f1)    Max (apparent) size: $(ls -lh "$f" | awk '{print $5}')"
            echo
        fi
    done
}

# Removes a single image after showing details and asking for confirmation
remove_image() {
    local ref="$1"
    local id tags size users running

    id=$(docker image inspect --format '{{.Id}}' "$ref" 2>/dev/null)
    if [ -z "$id" ]; then
        print_error "Image not found: ${ref}"
        exit 1
    fi
    tags=$(docker image inspect --format '{{join .RepoTags ", "}}' "$ref" 2>/dev/null)
    size=$(docker image inspect --format '{{.Size}}' "$ref" 2>/dev/null)
    users=$(docker ps -a --no-trunc --filter "ancestor=${id}" --format '  - {{.Names}} ({{.Status}})')
    running=$(docker ps --no-trunc --filter "ancestor=${id}" -q)

    print_header "Remove Docker Image"
    echo -e "${AQUA}Image:${NC} ${ref}"
    echo -e "${AQUA}ID:${NC}    ${id#sha256:}"
    echo -e "${AQUA}Tags:${NC}  ${tags:-<none>}"
    echo -e "${AQUA}Size:${NC}  $(echo "$size" | awk '{ printf "%.1f MB", $1/1000000 }') (shared layers are kept if other images use them)"
    echo

    if [ -n "$users" ]; then
        echo -e "${BROWN}Containers using this image:${NC}"
        echo "$users"
        echo
        if [ -n "$running" ]; then
            print_error "Image is used by a running container. Stop it first: docker stop <name>"
        else
            print_error "Image is used by stopped containers. Remove them first: docker rm <name>"
        fi
        echo "Then run this command again."
        exit 1
    fi

    echo -e "${BROWN}Side effects:${NC}"
    echo "  - Next run/compose up of this image must pull again or rebuild."
    echo "  - If it was built locally and the sources are gone, it cannot be recreated."
    echo "  - Other tags of the same image (if any) are not removed when you name only one tag."
    echo
    if confirm "Remove image '${ref}'?"; then
        if docker rmi "$ref"; then
            print_success "Removed: ${ref}"
        else
            print_failed "Could not remove: ${ref}"
            exit 1
        fi
    else
        print_warning "Cancelled. Nothing was removed."
    fi
    echo
}

# Prunes dangling (or all unused) images after asking
prune_images() {
    local all="$1"
    if [ "$all" = true ]; then
        print_header "Remove All Unused Images"
        echo -e "${BROWN}Images that would be removed (not used by any container):${NC}"
        "$0" --unused 2>/dev/null | sed -n '/^ *SIZE/,$p'
        echo
        echo -e "${BROWN}Side effects:${NC}"
        echo "  - Every image not used by a container is deleted, including tagged ones."
        echo "  - They are pulled or rebuilt again when needed. Locally built images may be unrecoverable."
        echo
        if confirm "Run 'docker image prune -a'?"; then
            docker image prune -a -f
            print_success "Done!"
        else
            print_warning "Cancelled. Nothing was removed."
        fi
    else
        print_header "Remove Dangling Images"
        docker image ls --filter dangling=true
        echo
        echo -e "${BROWN}Side effects:${NC}"
        echo "  - Untagged leftovers of rebuilds are deleted; you cannot roll back to those builds."
        echo
        if confirm "Run 'docker image prune'?"; then
            docker image prune -f
            print_success "Done!"
        else
            print_warning "Cancelled. Nothing was removed."
        fi
    fi
    echo
}

# Defaults
TOP_N=0
ORDER="desc"
FILTER="all"        # all | unused | dangling
ACTION="list"       # list | remove | prune | prune_all | guide
REMOVE_REF=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -n|--top)
            TOP_N="$2"
            shift 2 || { print_error "Missing value for $1"; usage; exit 1; }
            ;;
        -o|--order)
            ORDER="$2"
            shift 2 || { print_error "Missing value for $1"; usage; exit 1; }
            ;;
        -u|--unused)
            FILTER="unused"
            shift
            ;;
        -d|--dangling)
            FILTER="dangling"
            shift
            ;;
        -r|--remove)
            ACTION="remove"
            REMOVE_REF="$2"
            if [ -z "$REMOVE_REF" ]; then print_error "Missing image for $1"; usage; exit 1; fi
            shift 2
            ;;
        -p|--prune)
            ACTION="prune"
            shift
            ;;
        -P|--prune-unused)
            ACTION="prune_all"
            shift
            ;;
        -g|--guide)
            ACTION="guide"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate arguments
case "$ORDER" in desc|asc) ;; *) print_error "Invalid order: $ORDER (use desc|asc)"; exit 1 ;; esac
if ! [[ "$TOP_N" =~ ^[0-9]+$ ]]; then print_error "Invalid --top value: $TOP_N"; exit 1; fi

# The guide needs no docker daemon
if [ "$ACTION" = "guide" ]; then
    show_guide
    exit 0
fi

# Check docker
if ! command -v docker >/dev/null 2>&1; then
    print_error "docker is not installed or not in PATH"
    exit 1
fi
if ! docker info >/dev/null 2>&1; then
    print_error "Cannot connect to the Docker daemon. Is Docker running?"
    exit 1
fi

case "$ACTION" in
    remove)    remove_image "$REMOVE_REF"; exit 0 ;;
    prune)     prune_images false; exit 0 ;;
    prune_all) prune_images true; exit 0 ;;
esac

print_header "Docker Disk Usage"

# Overall usage by type (Images, Containers, Local Volumes, Build Cache) with reclaimable space
echo -e "${AQUA}Overall Docker usage:${NC}"
docker system df
echo
show_desktop_disk

# Collect image and container data into temp files
IMG_FILE=$(mktemp)
CTR_FILE=$(mktemp)
trap 'rm -f "$IMG_FILE" "$CTR_FILE"' EXIT

IMAGE_IDS=$(docker image ls -aq --no-trunc | sort -u)
if [ -z "$IMAGE_IDS" ]; then
    print_warning "No docker images found"
    echo
    exit 0
fi

# <image id>|<size bytes>|<tags>
docker image inspect --format '{{.Id}}|{{.Size}}|{{join .RepoTags ","}}' $IMAGE_IDS > "$IMG_FILE" 2>/dev/null

# <image id>|<container name>|<state>|<compose project>|<compose service>
CONTAINER_IDS=$(docker ps -aq --no-trunc)
if [ -n "$CONTAINER_IDS" ]; then
    docker inspect --type container --format '{{.Image}}|{{.Name}}|{{.State.Status}}|{{index .Config.Labels "com.docker.compose.project"}}|{{index .Config.Labels "com.docker.compose.service"}}' $CONTAINER_IDS > "$CTR_FILE" 2>/dev/null
fi

SORT_FLAGS="-nr"
[ "$ORDER" = "asc" ] && SORT_FLAGS="-n"

echo -e "${AQUA}Images:${NC} filter=${FILTER}, order=${ORDER}$([ "$TOP_N" -gt 0 ] && echo ", top ${TOP_N}")"
echo

# Join images with the containers that use them, emit tab separated rows
# bytes <TAB> short id <TAB> tags <TAB> status <TAB> service(s)
join_rows() {
    awk -F'|' -v filter="$FILTER" '
        FILENAME == ARGV[1] {
            name = $2; sub(/^\//, "", name)
            label = ($4 != "" && $5 != "") ? $4 "/" $5 : name
            entry = label " [" $3 "]"
            users[$1] = (users[$1] == "") ? entry : users[$1] ", " entry
            count[$1]++
            if ($3 == "running") running[$1] = 1
            next
        }
        {
            key = $1
            id = $1; sub(/^sha256:/, "", id)
            tags = $3
            dangling = (tags == "")
            if (dangling) tags = "<none>"
            gsub(/,/, ", ", tags)
            if (running[key])        status = "IN-USE"
            else if (count[key] > 0) status = "STOPPED"
            else if (dangling)       status = "DANGLING"
            else                     status = "UNUSED"
            if (filter == "unused"   && status != "UNUSED" && status != "DANGLING") next
            if (filter == "dangling" && status != "DANGLING") next
            service = (users[key] == "") ? "-" : users[key]
            printf "%d\t%s\t%s\t%s\t%s\n", $2, substr(id, 1, 12), tags, status, service
        }
    ' "$CTR_FILE" "$IMG_FILE"
}

# Formats the byte column as human readable and prints a header
format_rows() {
    awk -F'\t' '
        BEGIN { printf "%10s  %-12s  %-9s  %-40s  %s\n", "SIZE", "IMAGE ID", "STATUS", "TAG", "SERVICE / CONTAINER" }
        {
            b = $1 + 0
            split("B KB MB GB TB", unit, " ")
            i = 1
            while (b >= 1000 && i < 5) { b /= 1000; i++ }
            printf "%8.1f%-2s  %-12s  %-9s  %-40s  %s\n", b, unit[i], $2, $4, $3, $5
            n++
        }
        END { if (n == 0) print "(no matching images)" }
    '
}

if [ "$TOP_N" -gt 0 ]; then
    join_rows | sort -t "$(printf '\t')" -k1,1 $SORT_FLAGS | head -n "$TOP_N" | format_rows
else
    join_rows | sort -t "$(printf '\t')" -k1,1 $SORT_FLAGS | format_rows
fi

echo
echo -e "${BROWN}Note:${NC} image sizes include layers shared with other images, so they do not add up to the real total (see 'docker system df')."
echo -e "${BROWN}To remove:${NC} ~/diskDockerUsage --remove <image> | --prune | --prune-unused | --guide (side effects)"
echo
print_success "Done!"
echo
