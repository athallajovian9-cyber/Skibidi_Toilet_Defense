@echo off
REM ========================================================
REM       SKIBIDI TOILET DEFENSE: SIGMA LAUNCHER v3.0
REM   Smart Browser Detection, Frameless App, Kiosk, 
REM   Resolution Selector & Save Profile Backup System
REM ========================================================
setlocal enabledelayedexpansion

title SKIBIDI TOILET DEFENSE -- SIGMA LAUNCHER v3.0
color 0A
mode con: cols=76 lines=36 >nul 2>&1

set "SCRIPT_DIR=%~dp0"
set "APP_DIR=%LocalAppData%\SkibidiLauncher"

REM --- Smart Game File Detection ---
set "GAME="
set "GAME_NAME="

if exist "%SCRIPT_DIR%Skibidi_Toilet_Defense_Sigma_Ultimate_Enhanced (1).html" (
    set "GAME=%SCRIPT_DIR%Skibidi_Toilet_Defense_Sigma_Ultimate_Enhanced (1).html"
    set "GAME_NAME=Sigma Ultimate [Enhanced Edition v3.0]"
) else if exist "%SCRIPT_DIR%Skibidi_Toilet_Defense_Sigma_Ultimate_Enhanced.html" (
    set "GAME=%SCRIPT_DIR%Skibidi_Toilet_Defense_Sigma_Ultimate_Enhanced.html"
    set "GAME_NAME=Sigma Ultimate [Enhanced V2 Edition]"
) else if exist "%SCRIPT_DIR%Skibidi_Toilet_Defense_Sigma_Ultimate.html" (
    set "GAME=%SCRIPT_DIR%Skibidi_Toilet_Defense_Sigma_Ultimate.html"
    set "GAME_NAME=Sigma Ultimate Standard"
) else (
    for %%F in ("%SCRIPT_DIR%*skibidi*.html") do (
        if not defined GAME (
            set "GAME=%%~fF"
            set "GAME_NAME=%%~nxF"
        )
    )
)

if not defined GAME (
    color 0C
    echo.
    echo ================================================================
    echo  ERROR: Skibidi Toilet Game HTML file not found!
    echo ================================================================
    echo  Make sure launcher.bat is in the same folder as:
    echo    - Skibidi_Toilet_Defense_Sigma_Ultimate_Enhanced (1).html
    echo    - or Skibidi_Toilet_Defense_Sigma_Ultimate_Enhanced.html
    echo.
    echo  Current directory: "%SCRIPT_DIR%"
    echo ================================================================
    echo.
    pause
    exit /b 1
)

set "GAME_URL=%GAME:\=/%"

REM --- Direct Browser Detection ---
set "CHROME_EXE="
set "EDGE_EXE="
set "BRAVE_EXE="
set "OPERA_EXE="
set "FIREFOX_EXE="
set "VIVALDI_EXE="
set "TOR_EXE="

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME_EXE=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME_EXE if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME_EXE=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined CHROME_EXE if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" set "CHROME_EXE=%LocalAppData%\Google\Chrome\Application\chrome.exe"

if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "EDGE_EXE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
if not defined EDGE_EXE if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "EDGE_EXE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined EDGE_EXE if exist "%LocalAppData%\Microsoft\Edge\Application\msedge.exe" set "EDGE_EXE=%LocalAppData%\Microsoft\Edge\Application\msedge.exe"

if exist "%ProgramFiles%\BraveSoftware\Brave-Browser\Application\brave.exe" set "BRAVE_EXE=%ProgramFiles%\BraveSoftware\Brave-Browser\Application\brave.exe"
if not defined BRAVE_EXE if exist "%ProgramFiles(x86)%\BraveSoftware\Brave-Browser\Application\brave.exe" set "BRAVE_EXE=%ProgramFiles(x86)%\BraveSoftware\Brave-Browser\Application\brave.exe"
if not defined BRAVE_EXE if exist "%LocalAppData%\BraveSoftware\Brave-Browser\Application\brave.exe" set "BRAVE_EXE=%LocalAppData%\BraveSoftware\Brave-Browser\Application\brave.exe"

if exist "%LocalAppData%\Programs\Opera GX\launcher.exe" set "OPERA_EXE=%LocalAppData%\Programs\Opera GX\launcher.exe"
if not defined OPERA_EXE if exist "%ProgramFiles%\Opera GX\launcher.exe" set "OPERA_EXE=%ProgramFiles%\Opera GX\launcher.exe"
if not defined OPERA_EXE if exist "%LocalAppData%\Programs\Opera\launcher.exe" set "OPERA_EXE=%LocalAppData%\Programs\Opera\launcher.exe"
if not defined OPERA_EXE if exist "%ProgramFiles%\Opera\launcher.exe" set "OPERA_EXE=%ProgramFiles%\Opera\launcher.exe"

if exist "%ProgramFiles%\Mozilla Firefox\firefox.exe" set "FIREFOX_EXE=%ProgramFiles%\Mozilla Firefox\firefox.exe"
if not defined FIREFOX_EXE if exist "%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe" set "FIREFOX_EXE=%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe"

if exist "%LocalAppData%\Vivaldi\Application\vivaldi.exe" set "VIVALDI_EXE=%LocalAppData%\Vivaldi\Application\vivaldi.exe"
if not defined VIVALDI_EXE if exist "%ProgramFiles%\Vivaldi\Application\vivaldi.exe" set "VIVALDI_EXE=%ProgramFiles%\Vivaldi\Application\vivaldi.exe"

if exist "%USERPROFILE%\Desktop\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%USERPROFILE%\Desktop\Tor Browser\Browser\firefox.exe"
if not defined TOR_EXE if exist "%USERPROFILE%\Downloads\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%USERPROFILE%\Downloads\Tor Browser\Browser\firefox.exe"
if not defined TOR_EXE if exist "%USERPROFILE%\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%USERPROFILE%\Tor Browser\Browser\firefox.exe"
if not defined TOR_EXE if exist "%LocalAppData%\Programs\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%LocalAppData%\Programs\Tor Browser\Browser\firefox.exe"
if not defined TOR_EXE if exist "%LocalAppData%\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%LocalAppData%\Tor Browser\Browser\firefox.exe"
if not defined TOR_EXE if exist "%ProgramFiles%\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%ProgramFiles%\Tor Browser\Browser\firefox.exe"
if not defined TOR_EXE if exist "C:\Tor Browser\Browser\firefox.exe" set "TOR_EXE=C:\Tor Browser\Browser\firefox.exe"
for %%D in (D E F G H) do (
    if not defined TOR_EXE if exist "%%D:\Tor Browser\Browser\firefox.exe" set "TOR_EXE=%%D:\Tor Browser\Browser\firefox.exe"
)

set "LAUNCH_MODE=app"
set "WIN_RES=1280,720"
set "RES_NAME=720p HD (1280x720)"

:menu
cls
echo ============================================================================
echo      [+] SKIBIDI TOILET DEFENSE -- SIGMA LAUNCHER v3.0 [+]
echo ============================================================================
echo  Target: %GAME_NAME%
if "%LAUNCH_MODE%"=="app" (
    echo  Mode  : Frameless Desktop App [No Browser Bar]  ^| Res: %RES_NAME%
) else (
    echo  Mode  : Fullscreen Kiosk Mode [F11 / Borderless Fullscreen]
)
echo ============================================================================
echo.

if defined CHROME_EXE (
    echo   1. Google Chrome            [READY]
) else (
    echo   1. Google Chrome            [NOT DETECTED]
)

if defined EDGE_EXE (
    echo   2. Microsoft Edge           [READY]
) else (
    echo   2. Microsoft Edge           [NOT DETECTED]
)

if defined BRAVE_EXE (
    echo   3. Brave Browser            [READY]
) else (
    echo   3. Brave Browser            [NOT DETECTED]
)

if defined OPERA_EXE (
    echo   4. Opera / Opera GX         [READY]
) else (
    echo   4. Opera / Opera GX         [NOT DETECTED]
)

if defined FIREFOX_EXE (
    echo   5. Mozilla Firefox          [READY]
) else (
    echo   5. Mozilla Firefox          [NOT DETECTED]
)

if defined VIVALDI_EXE (
    echo   6. Vivaldi Browser          [READY]
) else (
    echo   6. Vivaldi Browser          [NOT DETECTED]
)

if defined TOR_EXE (
    echo   7. Tor Browser [Kiosk]      [READY]
    echo   8. Tor Browser [Script Setup]
) else (
    echo   7. Tor Browser              [NOT DETECTED]
    echo   8. Tor Browser [Setup]      [NOT DETECTED]
)

echo   9. Default Windows Browser  [OPEN IN NEW TAB]
echo.
echo  --------------------------------------------------------------------------
echo   D. Auto-Launch Best Browser (Recommended)
echo   M. Toggle Launch Mode (Currently: %LAUNCH_MODE%)
echo   R. Change App Resolution (Currently: %WIN_RES%)
echo   S. Save Profile Backup / Restore Manager
echo   Q. Exit Launcher
echo ============================================================================
echo.

set "choice="
set /p "choice=Select an option: " || (
    echo Exiting...
    exit /b 0
)

if "!choice!"=="" goto menu
if /I "!choice!"=="q" goto :eof
if /I "!choice!"=="m" goto toggleMode
if /I "!choice!"=="r" goto toggleRes
if /I "!choice!"=="s" goto saveManager
if /I "!choice!"=="d" goto autoLaunch
if "!choice!"=="1" goto launchChrome
if "!choice!"=="2" goto launchEdge
if "!choice!"=="3" goto launchBrave
if "!choice!"=="4" goto launchOpera
if "!choice!"=="5" goto launchFirefox
if "!choice!"=="6" goto launchVivaldi
if "!choice!"=="7" goto launchTorKiosk
if "!choice!"=="8" goto launchTorSetup
if "!choice!"=="9" goto launchDefault

echo.
echo [!] Invalid selection "!choice!". Choose an option from the menu.
pause
goto menu

:toggleMode
if "%LAUNCH_MODE%"=="app" (
    set "LAUNCH_MODE=kiosk"
) else (
    set "LAUNCH_MODE=app"
)
goto menu

:toggleRes
if "%WIN_RES%"=="1280,720" (
    set "WIN_RES=1920,1080"
    set "RES_NAME=1080p FHD (1920x1080)"
) else if "%WIN_RES%"=="1920,1080" (
    set "WIN_RES=2560,1440"
    set "RES_NAME=1440p 2K (2560x1440)"
) else if "%WIN_RES%"=="2560,1440" (
    set "WIN_RES=3440,1440"
    set "RES_NAME=21:9 Ultrawide (3440x1440)"
) else (
    set "WIN_RES=1280,720"
    set "RES_NAME=720p HD (1280x720)"
)
goto menu

:saveManager
cls
echo ============================================================================
echo                 SAVE PROFILE BACKUP & RESTORE MANAGER
echo ============================================================================
echo  App Data Path: %APP_DIR%
echo.
echo   1. Backup Save Profile to Saves folder
echo   2. Restore Latest Backup
echo   3. Return to Main Menu
echo ============================================================================
echo.
set "sChoice="
set /p "sChoice=Select an option: "
if "!sChoice!"=="1" (
    if not exist "%SCRIPT_DIR%Saves" mkdir "%SCRIPT_DIR%Saves" 2>nul
    xcopy /E /I /Y "%APP_DIR%" "%SCRIPT_DIR%Saves\Backup_Latest" >nul 2>&1
    echo.
    echo [OK] Save profile backed up to "%SCRIPT_DIR%Saves\Backup_Latest"!
    pause
    goto saveManager
)
if "!sChoice!"=="2" (
    if not exist "%SCRIPT_DIR%Saves\Backup_Latest" (
        echo.
        echo [X] No backup found at "%SCRIPT_DIR%Saves\Backup_Latest"!
        pause
        goto saveManager
    )
    if not exist "%APP_DIR%" mkdir "%APP_DIR%" 2>nul
    xcopy /E /I /Y "%SCRIPT_DIR%Saves\Backup_Latest" "%APP_DIR%" >nul 2>&1
    echo.
    echo [OK] Save profile restored successfully from Backup_Latest!
    pause
    goto saveManager
)
goto menu

:autoLaunch
if defined CHROME_EXE goto launchChrome
if defined EDGE_EXE goto launchEdge
if defined BRAVE_EXE goto launchBrave
if defined OPERA_EXE goto launchOpera
if defined FIREFOX_EXE goto launchFirefox
if defined VIVALDI_EXE goto launchVivaldi
goto launchDefault

:launchChrome
if not defined CHROME_EXE goto notFound
set "BROWSER_NAME=Google Chrome"
set "EXE=!CHROME_EXE!"
goto runChromium

:launchEdge
if not defined EDGE_EXE goto notFound
set "BROWSER_NAME=Microsoft Edge"
set "EXE=!EDGE_EXE!"
goto runChromium

:launchBrave
if not defined BRAVE_EXE goto notFound
set "BROWSER_NAME=Brave"
set "EXE=!BRAVE_EXE!"
goto runChromium

:launchOpera
if not defined OPERA_EXE goto notFound
set "BROWSER_NAME=Opera"
set "EXE=!OPERA_EXE!"
goto runChromium

:launchVivaldi
if not defined VIVALDI_EXE goto notFound
set "BROWSER_NAME=Vivaldi"
set "EXE=!VIVALDI_EXE!"
goto runChromium

:runChromium
echo.
echo [*] Launching %BROWSER_NAME% in %LAUNCH_MODE% mode...
if not exist "%APP_DIR%" mkdir "%APP_DIR%" 2>nul
if "%LAUNCH_MODE%"=="kiosk" (
    start "" "!EXE!" --kiosk "file:///!GAME_URL!" --autoplay-policy=no-user-gesture-required --user-data-dir="%APP_DIR%" --no-first-run
) else (
    start "" "!EXE!" "--app=file:///!GAME_URL!" --autoplay-policy=no-user-gesture-required --user-data-dir="%APP_DIR%" --no-first-run --no-default-browser-check --disable-sync --window-size=%WIN_RES%
)
goto launched

:launchFirefox
if not defined FIREFOX_EXE goto notFound
echo.
echo [*] Launching Mozilla Firefox...
if "%LAUNCH_MODE%"=="kiosk" (
    start "" "!FIREFOX_EXE!" --kiosk "file:///!GAME_URL!"
) else (
    start "" "!FIREFOX_EXE!" -new-window "file:///!GAME_URL!"
)
goto launched

:launchTorKiosk
if not defined TOR_EXE goto notFound
echo.
echo [*] Launching Tor Browser in Kiosk mode...
start "" "!TOR_EXE!" --kiosk "file:///!GAME_URL!"
goto launched

:launchTorSetup
if not defined TOR_EXE goto notFound
cls
echo ================================================================
echo                 TOR BROWSER SCRIPT PERMISSION
echo ================================================================
echo  Tor Browser blocks JavaScript by default on local files.
echo.
echo  1. A regular Tor window will now open with the game.
echo  2. Click the NoScript (S) icon in the toolbar.
echo  3. Choose "ALLOW scripts for this page / temp trust".
echo  4. Reload the page once to test.
echo.
echo  After doing this once, you can use Option 7 (Kiosk Mode) anytime!
echo ================================================================
echo.
pause
start "" "!TOR_EXE!" "file:///!GAME_URL!"
goto launched

:launchDefault
echo.
echo [*] Opening in Windows Default Browser...
start "" "%GAME%"
goto launched

:notFound
echo.
echo [X] Selected browser was not found on this computer.
echo     Please choose an installed browser marked [READY] or Option 9.
echo.
pause
goto menu

:launched
echo.
echo [OK] Game started successfully! Have fun defending Ohio!
echo Exiting launcher in 2 seconds...
ping -n 3 127.0.0.1 >nul
exit /b 0
