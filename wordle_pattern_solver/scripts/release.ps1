param (
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

# 0. Safety Check
$existingTag = git tag -l "v$Version"
if ($existingTag) {
    Write-Host "❌ Error: Tag 'v$Version' already exists in the repository! Aborting." -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Starting Release Process for version $Version..." -ForegroundColor Cyan

# 1. Update pubspec.yaml
Write-Host "📝 Updating pubspec.yaml..."
$pubspec = Get-Content pubspec.yaml
$pubspec = $pubspec -replace 'version: .*', "version: $Version+1"
$pubspec | Set-Content pubspec.yaml

# 2. Build Windows
Write-Host "🪟 Building Windows Release..." -ForegroundColor Yellow
flutter build windows --release

# 3. Build Android
Write-Host "🤖 Building Android Release (Split APKs)..." -ForegroundColor Yellow
flutter build apk --release --split-per-abi

# 4. Prepare Artifacts
Write-Host "📦 Preparing Artifacts..." -ForegroundColor Green
$releaseDir = "release_output"
if (Test-Path $releaseDir) { Remove-Item $releaseDir -Recurse -Force }
New-Item -ItemType Directory -Path $releaseDir | Out-Null

# Copy APKs
Copy-Item "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" "$releaseDir/wordle-solver-$Version-arm64.apk"
Copy-Item "build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" "$releaseDir/wordle-solver-$Version-armv7.apk"
Copy-Item "build/app/outputs/flutter-apk/app-x86_64-release.apk" "$releaseDir/wordle-solver-$Version-x64.apk"

# Zip Windows
$windowsBuildDir = "build/windows/x64/runner/Release"
Compress-Archive -Path "$windowsBuildDir/*" -DestinationPath "$releaseDir/wordle-solver-$Version-windows.zip"

# 5. Git Operations
Write-Host "git Committing and Tagging..." -ForegroundColor Magenta
git add pubspec.yaml
git commit -m "Bump version to $Version"
git tag "v$Version"
git push origin master
git push origin "v$Version"

# 6. GitHub Release
Write-Host "🚀 Creating GitHub Release..." -ForegroundColor Cyan
gh release create "v$Version" `
    --title "v$Version" `
    --notes "Release v$Version" `
    "$releaseDir/wordle-solver-$Version-arm64.apk" `
    "$releaseDir/wordle-solver-$Version-armv7.apk" `
    "$releaseDir/wordle-solver-$Version-x64.apk" `
    "$releaseDir/wordle-solver-$Version-windows.zip"

Write-Host "✅ Release published to GitHub!" -ForegroundColor Green
Invoke-Item $releaseDir
