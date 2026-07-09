#!/usr/bin/env pwsh
# Common PowerShell functions analogous to common.sh

function Get-RepoRoot {
    try {
        $result = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # Fall back to script location for non-git repos
    return (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
}

function Get-CurrentBranch {
    # First check if SPECIFY_FEATURE environment variable is set
    if ($env:SPECIFY_FEATURE) {
        return $env:SPECIFY_FEATURE
    }
    
    # Then check git if available
    try {
        $result = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            return $result
        }
    } catch {
        # Git command failed
    }
    
    # For non-git repos, try to find the latest feature directory
    $repoRoot = Get-RepoRoot
    $specsDir = Join-Path $repoRoot "specs"
    
    if (Test-Path $specsDir) {
        $latestFeature = ""
        $highest = 0
        
        Get-ChildItem -Path $specsDir -Directory | ForEach-Object {
            if ($_.Name -match '^(\d{3})-') {
                $num = [int]$matches[1]
                if ($num -gt $highest) {
                    $highest = $num
                    $latestFeature = $_.Name
                }
            }
        }
        
        if ($latestFeature) {
            return $latestFeature
        }
    }
    
    # Final fallback
    return "main"
}

function Test-HasGit {
    try {
        git rev-parse --show-toplevel 2>$null | Out-Null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-FeatureBranch {
    param(
        [string]$Branch,
        [bool]$HasGit = $true
    )
    
    # For non-git repos, we can't enforce branch naming but still provide output
    if (-not $HasGit) {
        Write-Warning "[specify] Warning: Git repository not detected; skipped branch validation"
        return $true
    }
    
    if ($Branch -notmatch '^[0-9]{3}-') {
        Write-Output "ERROR: Not on a feature branch. Current branch: $Branch"
        Write-Output "Feature branches should be named like: 001-feature-name"
        return $false
    }
    return $true
}

function Get-FeatureDir {
    param([string]$RepoRoot, [string]$Branch)
    Join-Path $RepoRoot "specs/$Branch"
}

function Get-CharterFile {
    # Resolve the Engineering Charter file path.
    # The charter lives beside project.md when the work is part of a project
    # (specs/project-<name>/charter.md); otherwise it lives in the feature
    # directory (specs/<###-feature>/charter.md). The seed template that new
    # charters are created from stays at .specify/memory/charter.md.
    #
    # Back-compat: the charter was formerly named "constitution". Repos created
    # before the rename have a legacy constitution.md in the same location. If a
    # charter.md is not present but a constitution.md is, the legacy path is
    # returned so existing work keeps resolving; new charters always write charter.md.
    param([string]$RepoRoot, [string]$FeatureDir, [string]$Branch)

    # 1) On a project branch -> the project directory holds the charter
    if ($Branch -like 'project-*') {
        $dir = Join-Path $RepoRoot "specs/$Branch"
    }
    else {
        # 2) Feature directory nested under a project directory -> use the project dir
        $parentDir = Split-Path $FeatureDir -Parent
        if ((Split-Path $parentDir -Leaf) -like 'project-*') {
            $dir = $parentDir
        }
        # 3) SPECIFY_PROJECT env var set -> the named project directory
        elseif ($env:SPECIFY_PROJECT) {
            $dir = Join-Path $RepoRoot "specs/project-$($env:SPECIFY_PROJECT)"
        }
        # 4) Standalone feature -> the feature directory holds the charter
        else {
            $dir = $FeatureDir
        }
    }

    # Prefer charter.md; fall back to a legacy constitution.md when only that exists.
    $charterPath = Join-Path $dir 'charter.md'
    $legacyPath = Join-Path $dir 'constitution.md'
    if (Test-Path $charterPath) { return $charterPath }
    if (Test-Path $legacyPath) { return $legacyPath }
    return $charterPath
}

function Get-FeaturePathsEnv {
    $repoRoot = Get-RepoRoot
    $currentBranch = Get-CurrentBranch
    $hasGit = Test-HasGit
    $featureDir = Get-FeatureDir -RepoRoot $repoRoot -Branch $currentBranch
    $charterFile = Get-CharterFile -RepoRoot $repoRoot -FeatureDir $featureDir -Branch $currentBranch

    # CONSTITUTION is emitted as a deprecated alias of CHARTER so pre-rename
    # command prompts still resolve; both point to the same path.
    [PSCustomObject]@{
        REPO_ROOT     = $repoRoot
        CURRENT_BRANCH = $currentBranch
        HAS_GIT       = $hasGit
        FEATURE_DIR   = $featureDir
        FEATURE_SPEC  = Join-Path $featureDir 'spec.md'
        IMPL_PLAN     = Join-Path $featureDir 'plan.md'
        TASKS         = Join-Path $featureDir 'tasks.md'
        RESEARCH      = Join-Path $featureDir 'research.md'
        DATA_MODEL    = Join-Path $featureDir 'data-model.md'
        QUICKSTART    = Join-Path $featureDir 'quickstart.md'
        CONTRACTS_DIR = Join-Path $featureDir 'contracts'
        CHARTER       = $charterFile
        CONSTITUTION  = $charterFile
    }
}

function Test-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Output "  ✓ $Description"
        return $true
    } else {
        Write-Output "  ✗ $Description"
        return $false
    }
}

function Test-DirHasFiles {
    param([string]$Path, [string]$Description)
    if ((Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1)) {
        Write-Output "  ✓ $Description"
        return $true
    } else {
        Write-Output "  ✗ $Description"
        return $false
    }
}

