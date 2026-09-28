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

# Folder name of the shared spec repository, looked for next to the current repo.
$script:SpecsRepoName = 'unifyr-specs'

function ConvertTo-FullPath {
    param([string]$Path)
    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path (Get-Location).Path $Path
    }
    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

function Test-SamePath {
    param([string]$A, [string]$B)
    if (-not $A -or -not $B) { return $false }
    return ((ConvertTo-FullPath $A) -eq (ConvertTo-FullPath $B))
}

function Get-GitRoot {
    # Git top-level directory containing $Path, or $null when $Path is not in a git repo.
    param([string]$Path)
    if (-not $Path -or -not (Test-Path $Path -PathType Container)) { return $null }
    try {
        $result = git -C $Path rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            return (ConvertTo-FullPath $result)
        }
    } catch {
        # Git command failed
    }
    return $null
}

function Get-GitBranch {
    param([string]$Path)
    try {
        $result = git -C $Path rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            return $result
        }
    } catch {
        # Git command failed
    }
    return $null
}

function Get-SpecsDir {
    # Where NEW features and projects are created:
    #   1) $env:SPECIFY_SPECS_DIR, when set
    #   2) a sibling clone of the shared spec repo (<parent of repo root>/unifyr-specs), when present
    #   3) <repo root>/specs (the original behaviour)
    param([string]$RepoRoot)
    if ($env:SPECIFY_SPECS_DIR) {
        return (ConvertTo-FullPath $env:SPECIFY_SPECS_DIR)
    }
    $sibling = Join-Path (Split-Path (ConvertTo-FullPath $RepoRoot) -Parent) $script:SpecsRepoName
    if (Test-Path $sibling -PathType Container) {
        return (ConvertTo-FullPath $sibling)
    }
    return (Join-Path (ConvertTo-FullPath $RepoRoot) 'specs')
}

function Get-SpecsSearchDirs {
    # Where EXISTING features are looked up: the specs dir first, then the
    # repo-local specs/ so work started there before a move keeps resolving.
    param([string]$RepoRoot)
    $dirs = @(Get-SpecsDir -RepoRoot $RepoRoot)
    $local = Join-Path (ConvertTo-FullPath $RepoRoot) 'specs'
    if (-not (Test-SamePath $dirs[0] $local)) { $dirs += $local }
    return $dirs
}

function Get-SpecsRepoRoot {
    # Git repo that holds the specs dir, or $null when it is not in git.
    param([string]$RepoRoot)
    $specsDir = Get-SpecsDir -RepoRoot $RepoRoot
    $probe = if (Test-Path $specsDir -PathType Container) { $specsDir } else { Split-Path $specsDir -Parent }
    return (Get-GitRoot $probe)
}

function Find-FeatureDir {
    # Existing directory for feature $Name in any search dir, or $null.
    param([string]$RepoRoot, [string]$Name)
    if (-not $Name) { return $null }
    foreach ($dir in Get-SpecsSearchDirs -RepoRoot $RepoRoot) {
        $candidate = Join-Path $dir $Name
        if (Test-Path $candidate -PathType Container) { return $candidate }
    }
    return $null
}

function Restore-JiraKeyCase {
    # Branch names are lowercased, but Jira only links a branch to an issue when the
    # key is uppercase. Any key typed in uppercase in $Source (e.g. RED-6543) is put
    # back in uppercase in $Name.
    param([string]$Name, [string]$Source)
    if (-not $Name -or -not $Source) { return $Name }
    foreach ($m in [regex]::Matches($Source, '(?<![A-Za-z0-9])[A-Z][A-Z0-9]+-[0-9]+(?![0-9])')) {
        $key = $m.Value
        $pattern = '(^|-)' + [regex]::Escape($key.ToLower()) + '(?=-|$)'
        $Name = [regex]::Replace($Name, $pattern, { param($x) $x.Groups[1].Value + $key })
    }
    return $Name
}

function Get-CurrentBranch {
    # First check if SPECIFY_FEATURE environment variable is set
    if ($env:SPECIFY_FEATURE) {
        return $env:SPECIFY_FEATURE
    }

    $repoRoot = Get-RepoRoot

    # Candidate feature names: when specs live in a separate git repo, that
    # repo's branch names the feature; then the current repo's branch.
    $candidates = @()
    $specsRepoRoot = Get-SpecsRepoRoot -RepoRoot $repoRoot
    if ($specsRepoRoot -and -not (Test-SamePath $specsRepoRoot $repoRoot)) {
        $specsBranch = Get-GitBranch $specsRepoRoot
        if ($specsBranch) { $candidates += $specsBranch }
    }
    $currentBranch = Get-GitBranch (Get-Location).Path
    if ($currentBranch) { $candidates += $currentBranch }

    if ($candidates.Count -gt 0) {
        # Prefer a name that has a feature directory, then a numbered feature name
        foreach ($name in $candidates) {
            if (Find-FeatureDir -RepoRoot $repoRoot -Name $name) { return $name }
        }
        foreach ($name in $candidates) {
            if ($name -match '^[0-9]{3}-') { return $name }
        }
        return $candidates[-1]
    }

    # For non-git repos, try to find the latest feature directory
    $latestFeature = ""
    $highest = 0
    foreach ($specsDir in Get-SpecsSearchDirs -RepoRoot $repoRoot) {
        if (-not (Test-Path $specsDir)) { continue }
        Get-ChildItem -Path $specsDir -Directory | ForEach-Object {
            if ($_.Name -match '^(\d{3})-') {
                $num = [int]$matches[1]
                if ($num -gt $highest) {
                    $highest = $num
                    $latestFeature = $_.Name
                }
            }
        }
    }

    if ($latestFeature) {
        return $latestFeature
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
        # A name with an existing feature directory is accepted as-is
        if (Find-FeatureDir -RepoRoot (Get-RepoRoot) -Name $Branch) {
            return $true
        }
        Write-Output "ERROR: Not on a feature branch. Current branch: $Branch"
        Write-Output "Feature branches should be named like: 001-feature-name"
        Write-Output "Or set SPECIFY_FEATURE to the name of an existing feature directory."
        return $false
    }
    return $true
}

function Get-FeatureDir {
    # Existing feature directory in any search dir; otherwise the path under the specs dir.
    param([string]$RepoRoot, [string]$Branch)
    $existing = Find-FeatureDir -RepoRoot $RepoRoot -Name $Branch
    if ($existing) { return $existing }
    Join-Path (Get-SpecsDir -RepoRoot $RepoRoot) $Branch
}

function Get-CharterFile {
    # Resolve the Engineering Charter file path.
    # The charter lives beside project.md when the work is part of a project
    # (<specs dir>/project-<name>/charter.md); otherwise it lives in the feature
    # directory (<specs dir>/<###-feature>/charter.md). The seed template that new
    # charters are created from stays at .specify/memory/charter.md.
    #
    # Back-compat: the charter was formerly named "constitution". Repos created
    # before the rename have a legacy constitution.md in the same location. If a
    # charter.md is not present but a constitution.md is, the legacy path is
    # returned so existing work keeps resolving; new charters always write charter.md.
    param([string]$RepoRoot, [string]$FeatureDir, [string]$Branch)

    # 1) On a project branch -> the project directory holds the charter
    if ($Branch -like 'project-*') {
        $dir = Get-FeatureDir -RepoRoot $RepoRoot -Branch $Branch
    }
    else {
        # 2) Feature directory nested under a project directory -> use the project dir
        $parentDir = Split-Path $FeatureDir -Parent
        if ((Split-Path $parentDir -Leaf) -like 'project-*') {
            $dir = $parentDir
        }
        # 3) SPECIFY_PROJECT env var set -> the named project directory
        elseif ($env:SPECIFY_PROJECT) {
            $dir = Get-FeatureDir -RepoRoot $RepoRoot -Branch "project-$($env:SPECIFY_PROJECT)"
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

    # Git repo holding this feature's artefacts (the spec repo, or the current repo)
    $featureParent = Split-Path $featureDir -Parent
    $probe = if (Test-Path $featureParent) { $featureParent } else { Split-Path $featureParent -Parent }
    $specsRepoRoot = Get-GitRoot $probe
    if (-not $specsRepoRoot) { $specsRepoRoot = $repoRoot }

    # CONSTITUTION is emitted as a deprecated alias of CHARTER so pre-rename
    # command prompts still resolve; both point to the same path.
    [PSCustomObject]@{
        REPO_ROOT     = $repoRoot
        CURRENT_BRANCH = $currentBranch
        HAS_GIT       = $hasGit
        SPECS_ROOT    = Get-SpecsDir -RepoRoot $repoRoot
        SPECS_REPO_ROOT = $specsRepoRoot
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

