#!/usr/bin/env bash
# Common functions and variables for all scripts

# Get repository root, with fallback for non-git repositories
get_repo_root() {
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        # Fall back to script location for non-git repos
        local script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        (cd "$script_dir/../../.." && pwd)
    fi
}

# Folder name of the shared spec repository, looked for next to the current repo.
SPECS_REPO_NAME="unifyr-specs"

# Absolute, normalised path (the directory itself need not exist)
to_full_path() {
    local path="$1"
    # Absolute: POSIX (/...) or Windows drive (C:/... or C:\...) as returned by git on Windows
    if [[ "$path" != /* && ! "$path" =~ ^[A-Za-z]: ]]; then
        path="$PWD/$path"
    fi
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    else
        local parent
        parent="$(dirname "$path")"
        if [[ -d "$parent" ]]; then
            echo "$(cd "$parent" && pwd)/$(basename "$path")"
        else
            echo "${path%/}"
        fi
    fi
}

# Git top-level directory containing $1, or empty when it is not in a git repo
get_git_root() {
    local path="$1"
    [[ -n "$path" && -d "$path" ]] || return 0
    git -C "$path" rev-parse --show-toplevel 2>/dev/null || true
}

get_git_branch() {
    git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null || true
}

# Where NEW features and projects are created:
#   1) $SPECIFY_SPECS_DIR, when set
#   2) a sibling clone of the shared spec repo (<parent of repo root>/unifyr-specs), when present
#   3) <repo root>/specs (the original behaviour)
get_specs_dir() {
    local repo_root="$1"
    if [[ -n "${SPECIFY_SPECS_DIR:-}" ]]; then
        to_full_path "$SPECIFY_SPECS_DIR"
        return
    fi
    local sibling
    sibling="$(dirname "$repo_root")/$SPECS_REPO_NAME"
    if [[ -d "$sibling" ]]; then
        to_full_path "$sibling"
        return
    fi
    echo "$repo_root/specs"
}

# Where EXISTING features are looked up, one per line: the specs dir first,
# then the repo-local specs/ so work started there before a move keeps resolving.
get_specs_search_dirs() {
    local repo_root="$1"
    local primary
    primary="$(get_specs_dir "$repo_root")"
    echo "$primary"
    if [[ "$primary" != "$repo_root/specs" ]]; then
        echo "$repo_root/specs"
    fi
}

# Git repo that holds the specs dir, or empty when it is not in git
get_specs_repo_root() {
    local specs_dir probe
    specs_dir="$(get_specs_dir "$1")"
    probe="$specs_dir"
    [[ -d "$probe" ]] || probe="$(dirname "$specs_dir")"
    get_git_root "$probe"
}

# Existing directory for feature $2 in any search dir, or empty
find_feature_dir() {
    local repo_root="$1"
    local name="$2"
    [[ -n "$name" ]] || return 0
    local dir
    while IFS= read -r dir; do
        if [[ -d "$dir/$name" ]]; then
            echo "$dir/$name"
            return
        fi
    done < <(get_specs_search_dirs "$repo_root")
}

# Get current branch, with fallback for non-git repositories
get_current_branch() {
    # First check if SPECIFY_FEATURE environment variable is set
    if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
        echo "$SPECIFY_FEATURE"
        return
    fi

    local repo_root
    repo_root=$(get_repo_root)

    # Candidate feature names: when specs live in a separate git repo, that
    # repo's branch names the feature; then the current repo's branch.
    local candidates=()
    local specs_repo_root specs_branch current_branch
    specs_repo_root="$(get_specs_repo_root "$repo_root")"
    if [[ -n "$specs_repo_root" && "$specs_repo_root" != "$repo_root" ]]; then
        specs_branch="$(get_git_branch "$specs_repo_root")"
        [[ -n "$specs_branch" ]] && candidates+=("$specs_branch")
    fi
    current_branch="$(get_git_branch "$PWD")"
    [[ -n "$current_branch" ]] && candidates+=("$current_branch")

    if [[ ${#candidates[@]} -gt 0 ]]; then
        # Prefer a name that has a feature directory, then a numbered feature name
        local name
        for name in "${candidates[@]}"; do
            if [[ -n "$(find_feature_dir "$repo_root" "$name")" ]]; then
                echo "$name"
                return
            fi
        done
        for name in "${candidates[@]}"; do
            if [[ "$name" =~ ^[0-9]{3}- ]]; then
                echo "$name"
                return
            fi
        done
        echo "${candidates[${#candidates[@]}-1]}"
        return
    fi

    # For non-git repos, try to find the latest feature directory
    local latest_feature=""
    local highest=0
    local specs_dir
    while IFS= read -r specs_dir; do
        [[ -d "$specs_dir" ]] || continue
        for dir in "$specs_dir"/*; do
            if [[ -d "$dir" ]]; then
                local dirname=$(basename "$dir")
                if [[ "$dirname" =~ ^([0-9]{3})- ]]; then
                    local number=${BASH_REMATCH[1]}
                    number=$((10#$number))
                    if [[ "$number" -gt "$highest" ]]; then
                        highest=$number
                        latest_feature=$dirname
                    fi
                fi
            fi
        done
    done < <(get_specs_search_dirs "$repo_root")

    if [[ -n "$latest_feature" ]]; then
        echo "$latest_feature"
        return
    fi

    echo "main"  # Final fallback
}

# Check if we have git available
has_git() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

check_feature_branch() {
    local branch="$1"
    local has_git_repo="$2"

    # For non-git repos, we can't enforce branch naming but still provide output
    if [[ "$has_git_repo" != "true" ]]; then
        echo "[specify] Warning: Git repository not detected; skipped branch validation" >&2
        return 0
    fi

    if [[ ! "$branch" =~ ^[0-9]{3}- ]]; then
        # A name with an existing feature directory is accepted as-is
        if [[ -n "$(find_feature_dir "$(get_repo_root)" "$branch")" ]]; then
            return 0
        fi
        echo "ERROR: Not on a feature branch. Current branch: $branch" >&2
        echo "Feature branches should be named like: 001-feature-name" >&2
        echo "Or set SPECIFY_FEATURE to the name of an existing feature directory." >&2
        return 1
    fi

    return 0
}

# Existing feature directory in any search dir; otherwise the path under the specs dir
get_feature_dir() {
    local existing
    existing="$(find_feature_dir "$1" "$2")"
    if [[ -n "$existing" ]]; then
        echo "$existing"
    else
        echo "$(get_specs_dir "$1")/$2"
    fi
}

# Resolve the Engineering Charter file path.
# The charter lives beside project.md when the work is part of a project
# (<specs dir>/project-<name>/charter.md); otherwise it lives in the feature
# directory (<specs dir>/<###-feature>/charter.md). The seed template that new
# charters are created from stays at .specify/memory/charter.md.
#
# Back-compat: the charter was formerly named "constitution". Repos created
# before the rename have a legacy `constitution.md` in the same location. If a
# `charter.md` is not present but a `constitution.md` is, the legacy path is
# returned so existing work keeps resolving; new charters are always written to
# `charter.md`.
get_charter_file() {
    local repo_root="$1"
    local feature_dir="$2"
    local current_branch="$3"
    local dir

    # 1) On a project branch -> the project directory holds the charter
    if [[ "$current_branch" == project-* ]]; then
        dir="$(get_feature_dir "$repo_root" "$current_branch")"
    else
        # 2) Feature directory nested under a project directory -> use the project dir
        local parent_dir parent_base
        parent_dir="$(dirname "$feature_dir")"
        parent_base="$(basename "$parent_dir")"
        if [[ "$parent_base" == project-* ]]; then
            dir="$parent_dir"
        elif [[ -n "${SPECIFY_PROJECT:-}" ]]; then
            # 3) SPECIFY_PROJECT env var set -> the named project directory
            dir="$(get_feature_dir "$repo_root" "project-${SPECIFY_PROJECT}")"
        else
            # 4) Standalone feature -> the feature directory holds the charter
            dir="$feature_dir"
        fi
    fi

    # Prefer charter.md; fall back to a legacy constitution.md when only that exists.
    if [[ -f "$dir/charter.md" ]]; then
        echo "$dir/charter.md"
    elif [[ -f "$dir/constitution.md" ]]; then
        echo "$dir/constitution.md"
    else
        echo "$dir/charter.md"
    fi
}

# Find feature directory by numeric prefix instead of exact branch match
# This allows multiple branches to work on the same spec (e.g., 004-fix-bug, 004-add-feature)
find_feature_dir_by_prefix() {
    local repo_root="$1"
    local branch_name="$2"
    local specs_dir
    specs_dir="$(get_specs_dir "$repo_root")"

    # Extract numeric prefix from branch (e.g., "004" from "004-whatever")
    if [[ ! "$branch_name" =~ ^([0-9]{3})- ]]; then
        # If branch doesn't have numeric prefix, fall back to exact match
        get_feature_dir "$repo_root" "$branch_name"
        return
    fi

    local prefix="${BASH_REMATCH[1]}"

    # Search each specs dir for directories that start with this prefix;
    # the first specs dir with a match wins
    local matches=()
    local search_dir
    while IFS= read -r search_dir; do
        [[ -d "$search_dir" ]] || continue
        for dir in "$search_dir"/"$prefix"-*; do
            if [[ -d "$dir" ]]; then
                matches+=("$(basename "$dir")")
            fi
        done
        if [[ ${#matches[@]} -gt 0 ]]; then
            specs_dir="$search_dir"
            break
        fi
    done < <(get_specs_search_dirs "$repo_root")

    # Handle results
    if [[ ${#matches[@]} -eq 0 ]]; then
        # No match found - return the branch name path (will fail later with clear error)
        echo "$specs_dir/$branch_name"
    elif [[ ${#matches[@]} -eq 1 ]]; then
        # Exactly one match - perfect!
        echo "$specs_dir/${matches[0]}"
    else
        # Multiple matches - this shouldn't happen with proper naming convention
        echo "ERROR: Multiple spec directories found with prefix '$prefix': ${matches[*]}" >&2
        echo "Please ensure only one spec directory exists per numeric prefix." >&2
        echo "$specs_dir/$branch_name"  # Return something to avoid breaking the script
    fi
}

get_feature_paths() {
    local repo_root=$(get_repo_root)
    local current_branch=$(get_current_branch)
    local has_git_repo="false"

    if has_git; then
        has_git_repo="true"
    fi

    # Use prefix-based lookup to support multiple branches per spec
    local feature_dir=$(find_feature_dir_by_prefix "$repo_root" "$current_branch")
    local charter_file=$(get_charter_file "$repo_root" "$feature_dir" "$current_branch")

    # Git repo holding this feature's artefacts (the spec repo, or the current repo)
    local feature_parent probe specs_repo_root
    feature_parent="$(dirname "$feature_dir")"
    probe="$feature_parent"
    [[ -d "$probe" ]] || probe="$(dirname "$feature_parent")"
    specs_repo_root="$(get_git_root "$probe")"
    [[ -n "$specs_repo_root" ]] || specs_repo_root="$repo_root"
    local specs_root
    specs_root="$(get_specs_dir "$repo_root")"

    # CONSTITUTION is emitted as a deprecated alias of CHARTER so pre-rename
    # command prompts still resolve; both point to the same path.
    cat <<EOF
REPO_ROOT='$repo_root'
CURRENT_BRANCH='$current_branch'
HAS_GIT='$has_git_repo'
SPECS_ROOT='$specs_root'
SPECS_REPO_ROOT='$specs_repo_root'
FEATURE_DIR='$feature_dir'
FEATURE_SPEC='$feature_dir/spec.md'
IMPL_PLAN='$feature_dir/plan.md'
TASKS='$feature_dir/tasks.md'
RESEARCH='$feature_dir/research.md'
DATA_MODEL='$feature_dir/data-model.md'
QUICKSTART='$feature_dir/quickstart.md'
CONTRACTS_DIR='$feature_dir/contracts'
CHARTER='$charter_file'
CONSTITUTION='$charter_file'
EOF
}

check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }

