#!/bin/bash
# Author: Rohtash Lakra
# List pull requests for a GitHub repository using git

# Bootstrap: Find and source script_utils.sh, then setup environment
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/../.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Never prompt for username/password during non-interactive git operations
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=true

# Convert a repo URL or slug to owner/repo format
parse_repo_slug() {
    local input="$1"
    local slug="${input%.git}"

    if [[ "$slug" =~ github\.com[:/]([^/]+)/([^/]+) ]]; then
        echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
        return 0
    fi

    if [[ "$slug" =~ ^[^/[:space:]]+/[^/[:space:]]+$ ]]; then
        echo "$slug"
        return 0
    fi

    return 1
}

# Convert owner/repo to an SSH git remote URL
repo_slug_to_ssh_url() {
    echo "git@github.com:$1.git"
}

# Test whether git can reach a remote URL over SSH
test_ssh_remote_url() {
    git ls-remote "$1" HEAD > /dev/null 2>&1
}

# Resolve any GitHub remote input to an SSH URL
normalize_github_remote_to_ssh() {
    local input="$1"
    local slug

    if [[ "$input" == git@* ]] || [[ "$input" == ssh://* ]]; then
        if [[ "$input" == *.git ]]; then
            echo "$input"
        else
            echo "${input}.git"
        fi
        return 0
    fi

    slug="$(parse_repo_slug "$input")" || return 1
    repo_slug_to_ssh_url "$slug"
}

# Resolve the SSH remote URL used for git operations
resolve_ssh_remote_url() {
    local repo_slug="$1"
    local remote_name="$2"
    local remote_url ssh_url

    if [ -n "$remote_name" ]; then
        remote_url="$(git remote get-url "$remote_name" 2>/dev/null)" || return 1
        ssh_url="$(normalize_github_remote_to_ssh "$remote_url")" || return 1
    else
        ssh_url="$(repo_slug_to_ssh_url "$repo_slug")"
    fi

    if test_ssh_remote_url "$ssh_url"; then
        echo "$ssh_url"
        return 0
    fi

    return 1
}

# Detect GitHub repo slug from a named git remote
detect_repo_from_remote() {
    local remote_name="$1"

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        return 1
    fi

    local remote_url
    remote_url="$(git remote get-url "$remote_name" 2>/dev/null)" || return 1
    parse_repo_slug "$remote_url"
}

# Normalize ls-remote pull refs to "number<TAB>sha" lines
normalize_pr_refs() {
    sed -E -n 's/^([0-9a-f]{7,})[[:space:]]+refs\/pull\/([0-9]+)\/(head|merge)$/\2	\1/p'
}

# Resolve a GitHub API token from env, gh, or git credentials
resolve_github_api_token() {
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        echo "$GITHUB_TOKEN"
        return 0
    fi

    if [ -n "${GH_TOKEN:-}" ]; then
        echo "$GH_TOKEN"
        return 0
    fi

    if command -v gh > /dev/null 2>&1; then
        gh auth token 2>/dev/null && return 0
    fi

    return 1
}

# Parse GitHub pull request JSON objects into "number<TAB>author<TAB>title" lines
parse_pull_request_json() {
    if command -v python3 > /dev/null 2>&1; then
        python3 -c '
import json, sys

try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

items = data if isinstance(data, list) else [data]
for pr in items:
    if not isinstance(pr, dict):
        continue
    number = pr.get("number")
    if number is None:
        continue
    author = pr.get("user", {}).get("login") or "n/a"
    title = pr.get("title") or "n/a"
    title = title.replace("\t", " ").replace("\n", " ").strip()
    print(f"{number}\t{author}\t{title}")
'
        return 0
    fi

    return 1
}

# Build curl args for GitHub API requests
github_api_curl_args() {
    local args=(-fsSL -H "Accept: application/vnd.github+json")

    if [ -n "${GITHUB_API_TOKEN:-}" ]; then
        args+=(-H "Authorization: Bearer ${GITHUB_API_TOKEN}")
    fi

    printf '%s\n' "${args[@]}"
}

# Load PR metadata from GitHub API into a cache file
load_pr_metadata_cache() {
    local owner="$1"
    local repo="$2"
    local pr_type="$3"
    local page=1
    local per_page=100
    local response curl_arg
    local -a curl_args

    PR_METADATA_CACHE="$(mktemp "${TMPDIR:-/tmp}/listPullRequests.XXXXXX")"
    : > "$PR_METADATA_CACHE"

    while IFS= read -r curl_arg; do
        [ -n "$curl_arg" ] && curl_args+=("$curl_arg")
    done < <(github_api_curl_args)

    while true; do
        response="$(curl "${curl_args[@]}" \
            "https://api.github.com/repos/${owner}/${repo}/pulls?state=${pr_type}&per_page=${per_page}&page=${page}&sort=updated&direction=desc" 2>/dev/null)" || break

        [ "$response" = "[]" ] && break

        if ! printf '%s' "$response" | parse_pull_request_json >> "$PR_METADATA_CACHE"; then
            break
        fi

        local page_count
        page_count="$(printf '%s' "$response" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null || echo 0)"
        [ "$page_count" -lt "$per_page" ] && break
        page=$((page + 1))
    done
}

# Look up PR metadata from the API cache
lookup_pr_metadata_cache() {
    local pr_number="$1"

    if [ -z "${PR_METADATA_CACHE:-}" ] || [ ! -s "$PR_METADATA_CACHE" ]; then
        return 1
    fi

    awk -F '\t' -v pr_number="$pr_number" '$1 == pr_number { print $2 "\t" $3; exit }' "$PR_METADATA_CACHE"
}

# Prepare a shared temp repo for incremental git metadata fetches
init_git_metadata_repo() {
    local remote_url="$1"

    GIT_METADATA_DIR="$(mktemp -d "${TMPDIR:-/tmp}/listPullRequests.gitdir.XXXXXX")" || return 1

    git -C "$GIT_METADATA_DIR" init -q \
        && git -C "$GIT_METADATA_DIR" remote add origin "$remote_url"
}

# Fetch PR author and title from the latest commit via git (shared temp repo)
fetch_pr_metadata_from_git() {
    local pr_number="$1"
    local ref_name="pr-${pr_number}"

    [ -n "${GIT_METADATA_DIR:-}" ] || return 1

    if git -C "$GIT_METADATA_DIR" fetch -q --depth 1 origin "pull/${pr_number}/head:${ref_name}" 2>/dev/null; then
        git -C "$GIT_METADATA_DIR" log -1 --format='%an%x09%s' "$ref_name" 2>/dev/null
    fi
}

# Apply a "author<TAB>title" metadata line to output variables
apply_pr_metadata_line() {
    local metadata="$1"

    PR_METADATA_AUTHOR="${metadata%%$'\t'*}"
    PR_METADATA_TITLE="${metadata#*$'\t'}"
}

# Fetch PR author and title from GitHub API or git commit metadata
fetch_pr_metadata() {
    local owner="$1"
    local repo="$2"
    local pr_number="$3"
    local remote_url="$4"
    local response curl_arg metadata
    local -a curl_args

    PR_METADATA_AUTHOR="n/a"
    PR_METADATA_TITLE="n/a"

    metadata="$(lookup_pr_metadata_cache "$pr_number")"
    if [ -n "$metadata" ]; then
        apply_pr_metadata_line "$metadata"
        return 0
    fi

    if [ -n "${GITHUB_API_TOKEN:-}" ]; then
        while IFS= read -r curl_arg; do
            [ -n "$curl_arg" ] && curl_args+=("$curl_arg")
        done < <(github_api_curl_args)

        response="$(curl "${curl_args[@]}" \
            "https://api.github.com/repos/${owner}/${repo}/pulls/${pr_number}" 2>/dev/null)" || response=""

        if [ -n "$response" ]; then
            metadata="$(printf '%s' "$response" | parse_pull_request_json | head -1)"
            if [ -n "$metadata" ]; then
                PR_METADATA_AUTHOR="$(printf '%s' "$metadata" | cut -f2)"
                PR_METADATA_TITLE="$(printf '%s' "$metadata" | cut -f3-)"
                return 0
            fi
        fi
    fi

    metadata="$(fetch_pr_metadata_from_git "$pr_number")"
    if [ -n "$metadata" ]; then
        apply_pr_metadata_line "$metadata"
        return 0
    fi

    return 1
}

usage() {
    echo
    echo -e "${DARKBLUE}List pull requests for a GitHub repository using git.${NC}"
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./listPullRequests.sh --repo <repo>${NC} [options]"
    echo -e "  ${AQUA}./listPullRequests.sh --remote <name>${NC} [options]"
    echo -e "  ${AQUA}./listPullRequests.sh --help${NC}              # Show this help"
    echo
    echo -e "${BROWN}Options:${NC}"
    echo
    echo -e "  ${INDIGO}--help, -h${NC}"
    echo -e "    Show this help message and exit."
    echo
    echo -e "  ${INDIGO}--repo <url-or-slug>${NC}"
    echo -e "    GitHub repository to list pull requests from."
    echo -e "    Accepts HTTPS URL, SSH URL, or ${AQUA}owner/repo${NC} slug."
    echo -e "    ${INDIGO}HTTPS or SSH inputs are normalized; git operations always use SSH.${NC}"
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--repo https://github.com/invisible-tech/fde-analytics-data-platform${NC}"
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--repo git@github.com:invisible-tech/fde-analytics-data-platform.git${NC}"
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--repo invisible-tech/fde-analytics-data-platform${NC}"
    echo
    echo -e "  ${INDIGO}--remote <name>${NC}"
    echo -e "    Use a configured Git remote from the current repository."
    echo -e "    ${BROWN}Default:${NC} ${AQUA}origin${NC} ${INDIGO}(when --repo is omitted and inside a Git repo)${NC}"
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--remote origin${NC}"
    echo
    echo -e "  ${INDIGO}--type <open|closed|all>${NC}"
    echo -e "    Pull request state to list."
    echo -e "    ${BROWN}Default:${NC} ${AQUA}open${NC}"
    echo -e "    ${BROWN}Example:${NC} ${AQUA}--type closed${NC}"
    echo -e "    ${INDIGO}Uses ${AQUA}git ls-remote${NC} against ${AQUA}refs/pull/*/head${NC} and ${AQUA}refs/pull/*/merge${NC}."
    echo -e "    ${INDIGO}Open PRs are approximated by refs that expose a merge ref; closed PRs are head refs without one.${NC}"
    echo
    echo -e "  ${INDIGO}--limit <number>${NC}"
    echo -e "    Maximum number of pull requests to show."
    echo -e "    ${BROWN}Default:${NC} ${AQUA}30${NC}"
    echo
    echo -e "${BROWN}Examples:${NC}"
    echo -e "  ${AQUA}./listPullRequests.sh --repo https://github.com/invisible-tech/fde-analytics-data-platform${NC}"
    echo -e "    ${INDIGO}# List open pull requests (default)${NC}"
    echo
    echo -e "  ${AQUA}./listPullRequests.sh --repo invisible-tech/fde-analytics-data-platform --type closed${NC}"
    echo -e "    ${INDIGO}# List closed pull requests${NC}"
    echo
    echo -e "  ${AQUA}./listPullRequests.sh --remote origin --type all --limit 50${NC}"
    echo -e "    ${INDIGO}# List up to 50 PRs from the origin remote of the current repo${NC}"
    echo
    echo -e "${BROWN}Prerequisites:${NC}"
    echo -e "  ${INDIGO}Git is required. PRs are discovered with ${AQUA}git ls-remote${NC}."
    echo -e "  ${INDIGO}Author and description come from the GitHub REST API when a token is available.${NC}"
    echo -e "  ${INDIGO}Otherwise commit metadata is fetched via ${AQUA}git fetch${NC} using the same remote auth.${NC}"
    echo -e "  ${INDIGO}Token sources: ${AQUA}GITHUB_TOKEN${NC}, ${AQUA}GH_TOKEN${NC}, or ${AQUA}gh auth token${NC}.${NC}"
    echo -e "  ${INDIGO}Without a token, commit metadata is fetched via ${AQUA}git fetch${NC} over SSH (no prompts).${NC}"
    echo -e "  ${INDIGO}For private repositories, configure SSH keys for ${AQUA}git@github.com${NC}.${NC}"
    echo
}

# Show help when invoked with no arguments
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

REPO=""
REMOTE_NAME=""
PR_TYPE="open"
LIMIT=30

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --repo)
            if [ -z "$2" ]; then
                print_error "Repository required after --repo"
                usage
                exit 1
            fi
            REPO="$2"
            shift 2
            ;;
        --remote)
            if [ -z "$2" ]; then
                print_error "Remote name required after --remote"
                usage
                exit 1
            fi
            REMOTE_NAME="$2"
            shift 2
            ;;
        --type)
            if [ -z "$2" ]; then
                print_error "Type required after --type (open, closed, or all)"
                usage
                exit 1
            fi
            PR_TYPE="$2"
            shift 2
            ;;
        --limit)
            if [ -z "$2" ]; then
                print_error "Number required after --limit"
                usage
                exit 1
            fi
            LIMIT="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

case "$PR_TYPE" in
    open|closed|all) ;;
    *)
        print_error "Invalid --type: ${PR_TYPE} (expected open, closed, or all)"
        exit 1
        ;;
esac

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || [ "$LIMIT" -lt 1 ]; then
    print_error "Invalid --limit: ${LIMIT} (expected a positive integer)"
    exit 1
fi

if ! command -v git > /dev/null 2>&1; then
    print_error "Git is not installed."
    exit 1
fi

if [ -z "$REPO" ] && [ -z "$REMOTE_NAME" ]; then
    REMOTE_NAME="origin"
fi

if [ -n "$REPO" ] && [ -n "$REMOTE_NAME" ]; then
    print_error "Use either --repo or --remote, not both."
    exit 1
fi

if [ -n "$REMOTE_NAME" ]; then
    REPO="$(detect_repo_from_remote "$REMOTE_NAME")" || {
        print_error "Could not resolve repository from remote: ${REMOTE_NAME}"
        exit 1
    }
    echo -e "${INDIGO}Using repository from ${AQUA}${REMOTE_NAME}${INDIGO} remote: ${AQUA}${REPO}${NC}"
else
    REPO="$(parse_repo_slug "$REPO")" || {
        print_error "Could not parse repository."
        exit 1
    }
fi

OWNER="${REPO%%/*}"
REPO_NAME="${REPO#*/}"
PR_BASE_URL="https://github.com/${OWNER}/${REPO_NAME}/pull"

SSH_URL="$(repo_slug_to_ssh_url "$REPO")"
REMOTE_URL="$(resolve_ssh_remote_url "$REPO" "$REMOTE_NAME")" || {
    print_error "Failed to connect to repository via SSH."
    echo -e "${INDIGO}Remote tried:${NC} ${AQUA}${SSH_URL}${NC}"
    echo -e "${INDIGO}Ensure SSH access works, e.g.: ${AQUA}ssh -T git@github.com${NC}"
    exit 1
}

GITHUB_API_TOKEN="$(resolve_github_api_token 2>/dev/null || true)"
PR_METADATA_CACHE=""
GIT_METADATA_DIR=""
NEEDS_GIT_METADATA=false

if [ -n "$GITHUB_API_TOKEN" ]; then
    load_pr_metadata_cache "$OWNER" "$REPO_NAME" "$PR_TYPE"
else
    echo -e "${INDIGO}No GitHub API token found; using commit metadata from git for author/description.${NC}"
    NEEDS_GIT_METADATA=true
fi

cleanup_metadata_caches() {
    if [ -n "${PR_METADATA_CACHE:-}" ] && [ -f "$PR_METADATA_CACHE" ]; then
        rm -f "$PR_METADATA_CACHE"
    fi
    if [ -n "${GIT_METADATA_DIR:-}" ] && [ -d "$GIT_METADATA_DIR" ]; then
        rm -rf "$GIT_METADATA_DIR"
    fi
}
trap cleanup_metadata_caches EXIT

print_header "Pull Requests (${PR_TYPE})"
echo -e "${INDIGO}Repository:${NC} ${AQUA}${REPO}${NC}"
echo -e "${INDIGO}Remote:${NC} ${AQUA}${REMOTE_URL}${NC}"
echo -e "${INDIGO}Connection:${NC} ${AQUA}SSH${NC}"
echo

echo -e "${INDIGO}Discovering pull request refs...${NC}"
HEAD_REFS="$(git ls-remote "$REMOTE_URL" 'refs/pull/*/head' 2>/dev/null | normalize_pr_refs)"
if [ $? -ne 0 ]; then
    print_error "Failed to list pull request refs with git ls-remote."
    echo -e "${INDIGO}Ensure the repository exists and Git can authenticate to it.${NC}"
    exit 1
fi

if [ -z "$HEAD_REFS" ]; then
    print_warning "No pull request refs found on remote."
    exit 0
fi

MERGE_NUMBERS="$(git ls-remote "$REMOTE_URL" 'refs/pull/*/merge' 2>/dev/null | normalize_pr_refs | cut -f1 | sort -u)"

FILTERED_REFS="$(
    awk -F '\t' -v pr_type="$PR_TYPE" '
        NR == FNR {
            merge[$1] = 1
            next
        }
        {
            number = $1
            sha = substr($2, 1, 7)
            if (pr_type == "all") {
                print number "\t" sha
            } else if (pr_type == "open" && (number in merge)) {
                print number "\t" sha
            } else if (pr_type == "closed" && !(number in merge)) {
                print number "\t" sha
            }
        }
    ' <(printf '%s\n' "$MERGE_NUMBERS") <(printf '%s\n' "$HEAD_REFS") | sort -t $'\t' -k1,1nr
)"

if [ -z "$FILTERED_REFS" ]; then
    print_warning "No ${PR_TYPE} pull requests found."
    exit 0
fi

if [ "$NEEDS_GIT_METADATA" = true ] || [ ! -s "${PR_METADATA_CACHE:-}" ]; then
    init_git_metadata_repo "$REMOTE_URL" || NEEDS_GIT_METADATA=false
fi

echo -e "${INDIGO}Listing pull requests...${NC}"
echo

listed=0
while IFS=$'\t' read -r pr_number sha; do
    [ -z "$pr_number" ] && continue
    [ "$listed" -ge "$LIMIT" ] && break

    if fetch_pr_metadata "$OWNER" "$REPO_NAME" "$pr_number" "$REMOTE_URL"; then
        author="$PR_METADATA_AUTHOR"
        title="$PR_METADATA_TITLE"
    else
        author="n/a"
        title="n/a"
    fi

    echo -e "${AQUA}#${pr_number}${NC}  ${INDIGO}${sha}${NC}  ${BROWN}@${author}${NC}"
    echo -e "       ${title}"
    echo -e "       ${PR_BASE_URL}/${pr_number}"
    echo
    listed=$((listed + 1))
done <<EOF
$FILTERED_REFS
EOF

echo
print_success "Listed ${listed} pull request(s)."
