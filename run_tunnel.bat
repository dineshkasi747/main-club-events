@echo off
title GVP College Portal - Tunnel Server
color 0A
cls

echo ============================================
echo   GVP COLLEGE PORTAL - LOCALTUNNEL SERVER
echo ============================================
echo.
echo  This window keeps the tunnel alive.
echo  DO NOT CLOSE this window while using the app.
echo.
echo  Public URL: https://gvp-college-portal.loca.lt
echo  Local URL:  http://localhost:8080
echo.
echo ============================================
echo.

:: Check if XAMPP Apache is running on port 8080
netstat -ano | findstr ":8080" > nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] XAMPP Apache is NOT running on port 8080!
    echo.
    echo  Please start XAMPP and make sure Apache is running first.
    echo  Then double-click this file again.
    echo.
    pause
    exit /b 1
)

color 0A
echo [OK] XAMPP Apache is running on port 8080
echo.

:loop
echo [%TIME%] Connecting tunnel...
echo.

:: Run localtunnel - errors are swallowed so the loop always continues
npx localtunnel --port 8080 --subdomain gvp-college-portal 2>nul

echo.
echo [%TIME%] Tunnel stopped. Reconnecting in 3 seconds...
echo.
timeout /t 3 /nobreak > nul
goto loop
