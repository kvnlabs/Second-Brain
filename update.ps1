# Git Repository Sync Script with Advanced Error Handling

# Configuration
$repoPath = "D:\Dev\Second-Brain"
$obsidianPath = "D:\Obsidian\Vault\Pages"
$hugoContentPath = "D:\Dev\Second-Brain\content\posts"
$pythonScriptPath = "D:\Dev\Second-Brain\images.py"
$gitRemoteUrl = "https://github.com/kvnlabs/Second-Brain.git"

# Error Handling and Logging
$ErrorActionPreference = "Stop"
$logFile = "$repoPath\sync_log.txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$Level] $timestamp - $Message"
    Add-Content -Path $logFile -Value $logEntry
    Write-Host $logEntry
}

# Ensure Git is installed
try {
    $gitVersion = git --version
    Write-Log "Git version: $gitVersion"
} catch {
    Write-Log "Git is not installed" -Level "ERROR"
    exit 1
}

# Change to repository directory
Set-Location $repoPath

# Ensure we're in the correct branch
try {
    # Check current branch
    $currentBranch = git rev-parse --abbrev-ref HEAD
    Write-Log "Current branch: $currentBranch"

    # If not on main or master, create or switch
    if ($currentBranch -ne "main" -and $currentBranch -ne "master") {
        Write-Log "Switching to main branch"
        git checkout -b main
    }
} catch {
    Write-Log "Error checking/creating branch" -Level "ERROR"
    exit 1
}

# Python script for processing
try {
    Write-Log "Running Python image processing script"
    python $pythonScriptPath
} catch {
    Write-Log "Python script failed" -Level "ERROR"
    exit 1
}

# Configure Git user
git config user.name "kavinthangavel"
git config user.email "kxvinthxngxvel@gmail.com"

# Add remote if not exists
try {
    $remotes = git remote
    if (-not ($remotes -contains 'origin')) {
        Write-Log "Adding remote origin"
        git remote add origin $gitRemoteUrl
    }
} catch {
    Write-Log "Error configuring remote" -Level "ERROR"
    exit 1
}

# Fetch and pull latest changes
try {
    Write-Log "Fetching latest changes"
    git fetch origin
    
    # Ensure we have a tracking branch
    git branch --set-upstream-to=origin/main main
    
    # Pull latest changes, rebase if needed
    git pull --rebase origin main
} catch {
    Write-Log "Fetch/Pull error" -Level "WARNING"
}

# Stage and commit changes
try {
    git add .
    $commitMessage = "Sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    
    # Check if there are changes to commit
    $status = git status --porcelain
    if ($status) {
        Write-Log "Committing changes"
        git commit -m "$commitMessage"
    } else {
        Write-Log "No changes to commit"
    }
} catch {
    Write-Log "Commit failed" -Level "ERROR"
    exit 1
}

# Push changes with force option
try {
    Write-Log "Pushing changes"
    git push -u origin main
} catch {
    Write-Log "Push failed, attempting force push" -Level "WARNING"
    try {
        git push -f origin main
    } catch {
        Write-Log "Force push failed" -Level "ERROR"
        exit 1
    }
}

Write-Log "Sync completed successfully"