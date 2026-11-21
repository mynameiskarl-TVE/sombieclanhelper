@echo off
setlocal
title Install Sombie Clan Companion

set "SOURCE=%~dp0"
set "APP_SOURCE=%SOURCE%SombieCompanion.exe"
set "INSTALL=%LOCALAPPDATA%\Programs\SombieCompanion"

if not exist "%APP_SOURCE%" (
  echo SombieCompanion.exe was not found beside this installer.
  echo Extract the complete ZIP first, then run this installer again.
  pause
  exit /b 1
)

echo.
echo SOMBIE CLAN COMPANION SETUP
echo ---------------------------
echo This installs the app for your Windows user only.
echo No administrator permission, LÖVE installation, or internet is needed.
echo Your saved clan data will stay in its existing local save folder.
echo.
echo Press ENTER to install and launch, or close this window to cancel.
set /p "CONTINUE= "

if not exist "%INSTALL%" mkdir "%INSTALL%"
if errorlevel 1 goto install_fail

echo.
echo Copying app and runtime files...
robocopy "%SOURCE%" "%INSTALL%" /E /COPY:DAT /R:2 /W:2 /NFL /NDL /NJH /NJS /NP
if errorlevel 8 goto install_fail

if not exist "%INSTALL%\SombieCompanion.exe" goto install_fail
if not exist "%INSTALL%\love.dll" goto install_fail

echo.
echo Creating a desktop shortcut...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $desktop=[Environment]::GetFolderPath('Desktop'); $shell=New-Object -ComObject WScript.Shell; $shortcut=$shell.CreateShortcut((Join-Path $desktop 'Sombie Clan Companion.lnk')); $shortcut.TargetPath=Join-Path $env:LOCALAPPDATA 'Programs\SombieCompanion\SombieCompanion.exe'; $shortcut.WorkingDirectory=Join-Path $env:LOCALAPPDATA 'Programs\SombieCompanion'; $shortcut.Description='Sombie Clan Companion'; $shortcut.Save()"
if errorlevel 1 (
  echo Could not create a desktop shortcut.
  echo You can still launch the app from %INSTALL%\SombieCompanion.exe
  pause
  exit /b 1
)

echo.
echo Installation complete. Starting Sombie Clan Companion...
start "" "%INSTALL%\SombieCompanion.exe"
exit /b 0

:install_fail
echo.
echo Installation failed. Check that the ZIP was fully extracted and try again.
pause
exit /b 1
