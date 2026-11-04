# Smart Farm - PowerShell Launcher
$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $PSScriptRoot
$BackendDir = Join-Path $RootDir "Smart_Farm_Backend"
$FrontendDir = Join-Path $RootDir "farm"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  SMART FARM - UNIFIED LAUNCHER (BACKEND + FRONTEND)" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Launching Backend API (Port 5000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$BackendDir'; Write-Host 'Starting Backend API on http://localhost:5000' -ForegroundColor Green; npm run dev"

Start-Sleep -Seconds 2

Write-Host "[2/2] Launching Flutter Frontend..." -ForegroundColor Yellow
Write-Host "Select target device:"
Write-Host "  1. Chrome (Web) [Default]"
Write-Host "  2. Windows (Desktop)"
Write-Host "  3. Edge (Web)"
Write-Host "  4. Android Emulator / Connected Phone"

$choice = Read-Host "Select device [1-4, default 1]"
$target = "chrome"
if ($choice -eq "2") { $target = "windows" }
elseif ($choice -eq "3") { $target = "edge" }
elseif ($choice -eq "4") { $target = "android" }

Write-Host "Starting Flutter on target: $target" -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$FrontendDir'; Write-Host 'Starting Flutter ($target)...' -ForegroundColor Green; flutter run -d $target"

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Both services have been launched in separate windows!" -ForegroundColor Cyan
Write-Host "  - Backend API: http://localhost:5000" -ForegroundColor White
Write-Host "  - Flutter App: Check the Flutter terminal" -ForegroundColor White
Write-Host "====================================================" -ForegroundColor Cyan
