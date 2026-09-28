#!/usr/bin/env pwsh
# Create a new project for multi-feature specs
[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ProjectName
)
$ErrorActionPreference = 'Stop'

# Show help if requested
if ($Help) {
    Write-Host "Usage: ./create-project.ps1 [-Json] <project_name>"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Json               Output in JSON format"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "Creates a project branch and directory for multi-feature projects."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  ./create-project.ps1 taskify"
    Write-Host "  ./create-project.ps1 -Json 'my-platform'"
    exit 0
}

# Check if project name provided
if (-not $ProjectName -or $ProjectName.Count -eq 0) {
    Write-Error "Usage: ./create-project.ps1 [-Json] <project_name>"
    exit 1
}

$projectNameInput = ($ProjectName -join ' ').Trim()

# Shared path helpers (specs dir resolution)
. "$PSScriptRoot/common.ps1"

# Function to find the repository root by searching for existing project markers
function Find-RepositoryRoot {
    param(
        [string]$StartDir,
        [string[]]$Markers = @('.git', '.specify')
    )
    $current = Resolve-Path $StartDir
    while ($true) {
        foreach ($marker in $Markers) {
            if (Test-Path (Join-Path $current $marker)) {
                return $current
            }
        }
        $parent = Split-Path $current -Parent
        if ($parent -eq $current) {
            # Reached filesystem root without finding markers
            return $null
        }
        $current = $parent
    }
}

function ConvertTo-CleanBranchName {
    param([string]$Name)

    return $Name.ToLower() -replace '[^a-z0-9]', '-' -replace '-{2,}', '-' -replace '^-', '' -replace '-$', ''
}

# Resolve repository root
$fallbackRoot = (Find-RepositoryRoot -StartDir $PSScriptRoot)
if (-not $fallbackRoot) {
    Write-Error "Error: Could not determine repository root. Please run this script from within the repository."
    exit 1
}

try {
    $repoRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0) {
        $hasGit = $true
    } else {
        throw "Git not available"
    }
} catch {
    $repoRoot = $fallbackRoot
    $hasGit = $false
}

Set-Location $repoRoot

# New projects go in the specs dir (SPECIFY_SPECS_DIR, a sibling unifyr-specs
# clone, or <repo>/specs). Branches are created in the git repo that holds it.
$specsDir = Get-SpecsDir -RepoRoot $repoRoot
New-Item -ItemType Directory -Path $specsDir -Force | Out-Null
$specsGitRoot = Get-GitRoot $specsDir
$hasGit = [bool]$specsGitRoot

# Clean project name for branch
$cleanProjectName = ConvertTo-CleanBranchName -Name $projectNameInput
# Keep Jira keys uppercase so Jira links the branch
$cleanProjectName = Restore-JiraKeyCase -Name $cleanProjectName -Source $projectNameInput
$branchName = "project-$cleanProjectName"
$projectDir = Join-Path $specsDir $branchName

# Check if project already exists (in the specs dir or the repo-local specs/)
$existingProjectDir = Find-FeatureDir -RepoRoot $repoRoot -Name $branchName
if ($existingProjectDir) {
    Write-Error "Error: Project directory already exists: $existingProjectDir"
    exit 1
}

# Check if branch already exists
if ($hasGit) {
    try {
        $localBranch = git -C $specsGitRoot show-ref --verify "refs/heads/$branchName" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Error "Error: Branch already exists: $branchName"
            exit 1
        }
    } catch {
        # Branch doesn't exist locally, which is fine
    }

    # Fetch remotes to check for remote branches
    try {
        git -C $specsGitRoot fetch --all --prune 2>$null | Out-Null
    } catch {
        # Ignore fetch errors
    }

    try {
        $remoteBranch = git -C $specsGitRoot show-ref --verify "refs/remotes/origin/$branchName" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Error "Error: Remote branch already exists: origin/$branchName"
            exit 1
        }
    } catch {
        # Remote branch doesn't exist, which is fine
    }
}

# Create branch from main
if ($hasGit) {
    # Try to checkout from main, master, or current branch
    $mainBranch = $null
    foreach ($branch in @('main', 'master')) {
        try {
            $localRef = git -C $specsGitRoot show-ref --verify "refs/heads/$branch" 2>$null
            $remoteRef = git -C $specsGitRoot show-ref --verify "refs/remotes/origin/$branch" 2>$null
            if ($LASTEXITCODE -eq 0 -or $localRef -or $remoteRef) {
                $mainBranch = $branch
                break
            }
        } catch {
            # Branch doesn't exist, try next
        }
    }

    try {
        if ($mainBranch) {
            git -C $specsGitRoot checkout -b $branchName $mainBranch 2>$null | Out-Null
        } else {
            git -C $specsGitRoot checkout -b $branchName 2>$null | Out-Null
        }
    } catch {
        try {
            git -C $specsGitRoot checkout -b $branchName | Out-Null
        } catch {
            Write-Warning "Failed to create git branch: $branchName"
        }
    }
} else {
    Write-Warning "[project] Warning: Git repository not detected; skipped branch creation for $branchName"
}

# Create project directory
New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

# Copy project template
$template = Join-Path $repoRoot '.specify/templates/project-template.md'
$projectFile = Join-Path $projectDir 'project.md'
if (Test-Path $template) {
    Copy-Item $template $projectFile -Force
} else {
    New-Item -ItemType File -Path $projectFile | Out-Null
}

# Set the SPECIFY_PROJECT environment variable for the current session
$env:SPECIFY_PROJECT = $cleanProjectName

if ($Json) {
    $obj = [PSCustomObject]@{
        PROJECT_NAME = $cleanProjectName
        PROJECT_DIR = $projectDir
        PROJECT_FILE = $projectFile
        BRANCH_NAME = $branchName
        HAS_GIT = $hasGit
    }
    $obj | ConvertTo-Json -Compress
} else {
    Write-Output "PROJECT_NAME: $cleanProjectName"
    Write-Output "PROJECT_DIR: $projectDir"
    Write-Output "PROJECT_FILE: $projectFile"
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "HAS_GIT: $hasGit"
    Write-Output "SPECIFY_PROJECT environment variable set to: $cleanProjectName"
}
