@echo off
title Smart Farm - Unified Launcher
cls

echo ====================================================
echo   SMART FARM - UNIFIED LAUNCHER (BACKEND + FRONTEND)
echo ====================================================
echo.

set ROOT_DIR=%~dp0..
set BACKEND_DIR=%ROOT_DIR%\Smart_Farm_Backend
set FRONTEND_DIR=%ROOT_DIR%\farm

echo [1/2] Launching Backend API in new window (Port 5000)...
start "Smart Farm - Backend API" cmd /k "cd /d "%BACKEND_DIR%" && echo Starting Backend... && npm run dev"

timeout /t 2 /nobreak >nul

echo [2/2] Launching Flutter Frontend in new window...
echo.
echo Choose your target device:
echo   1. Chrome (Web) [Default]
echo   2. Windows (Desktop)
echo   3. Edge (Web)
echo   4. Android Emulator / Connected Phone
echo.
set /p DEVICE_CHOICE="Select device [1-4, default 1]: "

if "%DEVICE_CHOICE%"=="2" (
    set TARGET=windows
) else if "%DEVICE_CHOICE%"=="3" (
    set TARGET=edge
) else if "%DEVICE_CHOICE%"=="4" (
    set TARGET=android
) else (
    set TARGET=chrome
)

echo.
echo Launching Flutter on target: %TARGET%...
start "Smart Farm - Flutter App (%TARGET%)" cmd /k "cd /d "%FRONTEND_DIR%" && echo Starting Flutter (%TARGET%)... && flutter run -d %TARGET%"

echo.
echo ====================================================
echo  Both Backend and Frontend are now starting up!
echo  - Backend:  http://localhost:5000/health
echo  - Frontend: Running in the second terminal window
echo ====================================================
echo.
pause
