@echo off
title Key Validator with Redirect
setlocal enabledelayedexpansion

:: URL of keys.txt and website to manage keys
set "KEYS_URL=https://yourdomain.com/keys.txt"
set "ADMIN_PAGE=https://yourdomain.com/add_key.html"
set "KEYFILE=%temp%\keys.txt"

:: Download latest keys.txt
powershell -Command "(New-Object Net.WebClient).DownloadFile('%KEYS_URL%', '%KEYFILE%')" 2>nul
if not exist "%KEYFILE%" (
    echo Cannot download keys file.
    start "" "%ADMIN_PAGE%"
    exit /b
)

:: User input
set /p "userkey=Enter your activation key: "

:: Validate key
set "found="
for /f "tokens=1,2 delims=|" %%A in (%KEYFILE%) do (
    if /i "%%A"=="%userkey%" (
        set "found=1"
        set "exp=%%B"
    )
)

if not defined found (
    echo Invalid or expired key!
    echo Redirecting to admin page...
    start "" "%ADMIN_PAGE%"
    exit /b
)

:: Get today's date
for /f %%A in ('powershell -Command "Get-Date -Format yyyy-MM-dd"') do set "today=%%A"

:: Compare dates
if "%today%" GEQ "%exp%" (
    echo Key expired on %exp%.
    echo Redirecting to admin page...
    start "" "%ADMIN_PAGE%"
    exit /b
) else (
    echo Access granted! Key valid until %exp%.
)

del "%KEYFILE%"
pause
exit /b