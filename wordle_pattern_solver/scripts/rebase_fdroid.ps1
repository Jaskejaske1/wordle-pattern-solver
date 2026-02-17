$ErrorActionPreference = "Stop"

# Use the absolute path to your fdroiddata fork
$FdroidRepoPath = "c:\Users\Jaske\source\repos\fdroiddata"
$BranchName = "be.jaspersavels.wordle_pattern_solver"

Write-Host "Starting F-Droid Rebase Automation..." -ForegroundColor Cyan

# Check if directory exists
if (-not (Test-Path $FdroidRepoPath)) {
    Write-Host "Error: Could not find fdroiddata at $FdroidRepoPath" -ForegroundColor Red
    exit 1
}

Set-Location $FdroidRepoPath
Write-Host "Changed directory to: $PWD" -ForegroundColor Gray

# Ensure upstream is set (just in case)
Write-Host "Checking upstream remote..."
$remotes = git remote -v
if ($remotes -notmatch "upstream") {
    Write-Host "   -> Adding upstream remote..."
    git remote add upstream https://gitlab.com/fdroid/fdroiddata.git
}

# Fetch
Write-Host "Fetching upstream master..." -ForegroundColor Yellow
git fetch upstream master

# Rebase
Write-Host "Rebasing $BranchName on upstream/master..." -ForegroundColor Yellow
git checkout $BranchName
git rebase upstream/master

if ($LASTEXITCODE -ne 0) {
    Write-Host "Rebase failed (Conflict?). Please fix manually." -ForegroundColor Red
    exit 1
}

# Push
Write-Host "Force Pushing to origin..." -ForegroundColor Yellow
git push -f origin $BranchName

Write-Host "Done! Your MR should be unblocked now." -ForegroundColor Green
Write-Host "   (Refresh the GitLab page in a few seconds)" -ForegroundColor Gray
