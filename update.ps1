# Simple Sync Script

# Configuration
$repoPath = "D:\Dev\Second-Brain"
$obsidianPath = "D:\Obsidian\Vault\Pages"
$hugoContentPath = "D:\Dev\Second-Brain\content\posts"
$pythonScriptPath = "D:\Dev\Second-Brain\images.py"

# Copy Markdown files from Obsidian to Hugo content directory
try {
    Write-Host "Copying Markdown files from Obsidian to Hugo content directory..."
    Copy-Item -Path "$obsidianPath\*.md" -Destination $hugoContentPath -Force
    Write-Host "Markdown files copied successfully."
} catch {
    Write-Host "Error copying Markdown files: $_"
    exit 1
}

# Run Python image processing script
try {
    Write-Host "Running Python image processing script..."
    python $pythonScriptPath
    Write-Host "Python script executed successfully."
} catch {
    Write-Host "Error running Python script: $_"
    exit 1
}

# Change to repository directory
Set-Location $repoPath

# Git operations
try {
    # Stage all changes
    git add .

    # Commit with timestamp
    $commitMessage = "Sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m "$commitMessage"

    # Push to main branch
    git push origin main
    Write-Host "Changes pushed to GitHub successfully."
} catch {
    Write-Host "Git operation failed: $_"
    exit 1
}

Write-Host "Sync process completed successfully."