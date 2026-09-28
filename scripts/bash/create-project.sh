#!/usr/bin/env bash

set -e

JSON_MODE=false
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--json] <project_name>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Creates a project branch and directory for multi-feature projects."
            echo ""
            echo "Examples:"
            echo "  $0 taskify"
            echo "  $0 --json 'my-platform'"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

PROJECT_NAME="${ARGS[*]}"
if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 [--json] <project_name>" >&2
    exit 1
fi

# Function to find the repository root by searching for existing project markers
find_repo_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -d "$dir/.specify" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Function to clean and format a branch name
clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Resolve repository root
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
    HAS_GIT=true
else
    REPO_ROOT="$(find_repo_root "$SCRIPT_DIR")"
    if [ -z "$REPO_ROOT" ]; then
        echo "Error: Could not determine repository root. Please run this script from within the repository." >&2
        exit 1
    fi
    HAS_GIT=false
fi

cd "$REPO_ROOT"

# Shared path helpers (specs dir resolution)
source "$SCRIPT_DIR/common.sh"

# New projects go in the specs dir (SPECIFY_SPECS_DIR, a sibling unifyr-specs
# clone, or <repo>/specs). Branches are created in the git repo that holds it.
SPECS_DIR="$(get_specs_dir "$REPO_ROOT")"
mkdir -p "$SPECS_DIR"
SPECS_GIT_ROOT="$(get_git_root "$SPECS_DIR")"
if [ -n "$SPECS_GIT_ROOT" ]; then HAS_GIT=true; else HAS_GIT=false; fi

# Clean project name for branch
CLEAN_PROJECT_NAME=$(clean_branch_name "$PROJECT_NAME")
BRANCH_NAME="project-${CLEAN_PROJECT_NAME}"
PROJECT_DIR="$SPECS_DIR/$BRANCH_NAME"

# Check if project already exists (in the specs dir or the repo-local specs/)
EXISTING_PROJECT_DIR="$(find_feature_dir "$REPO_ROOT" "$BRANCH_NAME")"
if [ -n "$EXISTING_PROJECT_DIR" ]; then
    echo "Error: Project directory already exists: $EXISTING_PROJECT_DIR" >&2
    exit 1
fi

# Check if branch already exists
if [ "$HAS_GIT" = true ]; then
    if git -C "$SPECS_GIT_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
        echo "Error: Branch already exists: $BRANCH_NAME" >&2
        exit 1
    fi

    # Fetch remotes to check for remote branches
    git -C "$SPECS_GIT_ROOT" fetch --all --prune 2>/dev/null || true

    if git -C "$SPECS_GIT_ROOT" show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME" 2>/dev/null; then
        echo "Error: Remote branch already exists: origin/$BRANCH_NAME" >&2
        exit 1
    fi
fi

# Create branch from main
if [ "$HAS_GIT" = true ]; then
    # Try to checkout from main, master, or current branch
    MAIN_BRANCH=""
    for branch in main master; do
        if git -C "$SPECS_GIT_ROOT" show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null || \
           git -C "$SPECS_GIT_ROOT" show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
            MAIN_BRANCH="$branch"
            break
        fi
    done

    if [ -n "$MAIN_BRANCH" ]; then
        git -C "$SPECS_GIT_ROOT" checkout -b "$BRANCH_NAME" "$MAIN_BRANCH" 2>/dev/null || git -C "$SPECS_GIT_ROOT" checkout -b "$BRANCH_NAME"
    else
        git -C "$SPECS_GIT_ROOT" checkout -b "$BRANCH_NAME"
    fi
else
    >&2 echo "[project] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
fi

# Create project directory
mkdir -p "$PROJECT_DIR"

# Copy project template
TEMPLATE="$REPO_ROOT/.specify/templates/project-template.md"
PROJECT_FILE="$PROJECT_DIR/project.md"
if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$PROJECT_FILE"
else
    touch "$PROJECT_FILE"
fi

# Set the SPECIFY_PROJECT environment variable for the current session
export SPECIFY_PROJECT="$CLEAN_PROJECT_NAME"

if $JSON_MODE; then
    printf '{"PROJECT_NAME":"%s","PROJECT_DIR":"%s","PROJECT_FILE":"%s","BRANCH_NAME":"%s","HAS_GIT":%s}\n' \
        "$CLEAN_PROJECT_NAME" "$PROJECT_DIR" "$PROJECT_FILE" "$BRANCH_NAME" "$HAS_GIT"
else
    echo "PROJECT_NAME: $CLEAN_PROJECT_NAME"
    echo "PROJECT_DIR: $PROJECT_DIR"
    echo "PROJECT_FILE: $PROJECT_FILE"
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "HAS_GIT: $HAS_GIT"
    echo "SPECIFY_PROJECT environment variable set to: $CLEAN_PROJECT_NAME"
fi
