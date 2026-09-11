@echo off
title Push Skibidi Defense to GitHub
color 0A
cls
echo ========================================================
echo     UPLOAD SKIBIDI TOILET DEFENSE TO GITHUB PAGES
echo ========================================================
echo.
echo  Step 1: Make sure you created a NEW repository on GitHub
echo         (e.g., named "skibidi-toilet-defense")
echo.
set /p REPO_URL="Enter your GitHub Repository URL (https://github.com/...): "

if "%REPO_URL%"=="" (
    echo [!] No URL entered. Exiting...
    pause
    exit /b 1
)

echo.
echo [*] Linking remote repository...
git remote remove origin 2>nul
git remote add origin %REPO_URL%
git branch -M main

echo [*] Pushing files to GitHub main branch...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  [OK] Upload successful!
    echo ========================================================
    echo  Now enable GitHub Pages in your repo:
    echo  1. Open your repository on GitHub.
    echo  2. Click Settings -> Pages.
    echo  3. Under Branch, choose 'main' and click Save!
    echo ========================================================
) else (
    echo.
    echo [!] Push failed. Check your repo URL or GitHub credentials.
)
echo.
pause
