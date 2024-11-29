# Set variables for the source and destination paths
$obsidianPath = "D:\Obsidian\Vault\Pages"  # Path to your Obsidian posts
$hugoContentPath = "D:\Dev\Second-Brain\content\posts"  # Path to Hugo content posts
$attachmentsPath = "D:\Obsidian\Vault\Attachments"  # Path to attachments
$staticImagesPath = "D:\Dev\Second-Brain\static\images"  # Path to Hugo static images
$myrepo = "https://github.com/kvnlabs/Second-Brain.git"  
$pythonScriptPath =""

# Set error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Change to the script's directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

# Check for required commands
$requiredCommands = @('git', 'python')

foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "$cmd is not installed or not in PATH."
        exit 1
    }
}

# Step 1: Copy Markdown files from Obsidian to Hugo content folder
Write-Host "Copying Markdown files from Obsidian to Hugo content folder..."
if (-not (Test-Path $obsidianPath)) {
    Write-Error "Source path does not exist: $obsidianPath"
    exit 1
}

Copy-Item -Path "$obsidianPath\*.md" -Destination $hugoContentPath -Recurse -Force

# Step 2: Copy images from Obsidian to Hugo static images directory
Write-Host "Copying images from Obsidian to Hugo static images directory..."
if (-not (Test-Path $attachmentsPath)) {
    Write-Error "Source images path does not exist: $attachmentsPath"
    exit 1
}

# Ensure the static images directory exists
if (-not (Test-Path $staticImagesPath)) {
    New-Item -ItemType Directory -Path $staticImagesPath
}

Copy-Item -Path "$attachmentsPath\*" -Destination $staticImagesPath -Recurse -Force

# Step 3: Run the images.py script to process Markdown files
Write-Host "Processing Markdown files with images.py..."
try {
    & python $pythonScriptPath
} catch {
    Write-Error "Failed to run images.py."
    exit 1
}

# Step 4: Check if Git is initialized, and initialize if necessary
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..."
    git init
    git remote add origin $myrepo
} else {
    Write-Host "Git repository already initialized."
    $remotes = git remote
    if (-not ($remotes -contains 'origin')) {
        Write-Host "Adding remote origin..."
        git remote add origin $myrepo
    }
}

# Step 5: Stage all changes for Git
Write-Host "Staging changes for Git..."
git add .

# Step 6: Commit changes with a dynamic message
$commitMessage = "Sync Obsidian posts and images on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$hasChanges = (git status --porcelain) -ne ""
if (-not $hasChanges) {
    Write-Host "No changes to commit."
} else {
    Write-Host "Committing changes..."
    git commit -m "$commitMessage"
}

# Step 7: Push all changes to the main branch
Write-Host "Pushing changes to GitHub..."
try {
    git push origin master
} catch {
    Write-Error "Failed to push to the master branch."
    exit 1
}

Write-Host "All done! Markdown files and images copied, processed, committed, and pushed to GitHub."