# Vane Labs - cleanup + push
# Removes old files, commits new site, pushes to GitHub.
# Netlify auto-rebuilds on push.

$ErrorActionPreference = "Stop"

$RepoDir = "$env:USERPROFILE\Documents\Apps Codes\vane-labs"

Write-Host ""
Write-Host "=== Vane Labs: cleanup + push ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $RepoDir)) {
  Write-Host "ERROR: repo folder not found: $RepoDir" -ForegroundColor Red
  exit 1
}
Set-Location $RepoDir

if (-not (Test-Path ".git")) {
  Write-Host "ERROR: no .git folder here. Expected a git clone of vane-labs." -ForegroundColor Red
  exit 1
}

$toDelete = @(
  "demo-dark.html",
  "demo-light.html",
  "demo-v1.html",
  "demo-v2.html",
  "dewhite.py",
  "logo.png",
  "logo-horizontal.png",
  "logo-name.png",
  "test-write.txt"
)

Write-Host "Removing old files ..."
foreach ($f in $toDelete) {
  if (Test-Path $f) {
    Remove-Item -Path $f -Force
    Write-Host "  - $f"
  }
}

Write-Host ""
Write-Host "Git status (before commit):" -ForegroundColor Cyan
git status --short

git add -A

$staged = git diff --cached --name-only
if ([string]::IsNullOrWhiteSpace($staged)) {
  Write-Host ""
  Write-Host "Nothing to commit - repo already matches working tree." -ForegroundColor Yellow
  exit 0
}

Write-Host ""
Write-Host "Committing ..." -ForegroundColor Cyan
$CommitMsg = "Replace site with new one-pager (We copy, 3 services, 3 principles, embedded logo)"
git commit -m $CommitMsg
if ($LASTEXITCODE -ne 0) {
  Write-Host "ERROR: commit failed." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Pushing to origin/main ..." -ForegroundColor Cyan
git push origin main
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "ERROR: push failed." -ForegroundColor Red
  Write-Host "If it's an auth issue: generate a GitHub Personal Access Token at" -ForegroundColor Yellow
  Write-Host "  https://github.com/settings/tokens" -ForegroundColor Yellow
  Write-Host "Scope: 'repo'. Retry and paste the token when prompted for password." -ForegroundColor Yellow
  exit 1
}

Write-Host ""
Write-Host "=== Push complete ===" -ForegroundColor Green
Write-Host "Netlify will rebuild in ~15s."
Write-Host "  Deploys: https://app.netlify.com"
Write-Host "  Site:    https://vane-labs.com  (hard-refresh with Ctrl+Shift+R)"
Write-Host ""
