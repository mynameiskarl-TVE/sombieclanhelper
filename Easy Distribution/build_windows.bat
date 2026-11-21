@echo off
setlocal
title Build Sombie Clan Companion

set "ROOT=%~dp0.."
set "GAME=%ROOT%\SombieCompanion"
set "DIST=%~dp0dist"
set "STAGE=%TEMP%\sombie_companion_build_%RANDOM%"
if not exist "%GAME%\main.lua" (
  echo ERROR: Could not find SombieCompanion\main.lua
  goto fail
)

if not defined LOVE_HOME set "LOVE_HOME=C:\Program Files\LOVE"
if not exist "%LOVE_HOME%\love.exe" set "LOVE_HOME=C:\Program Files (x86)\LOVE"
if not exist "%LOVE_HOME%\love.exe" (
  echo Could not find the LÖVE runtime.
  echo Install LÖVE 11.4 or newer on THIS build computer, or set LOVE_HOME.
  echo Example: set "LOVE_HOME=C:\Program Files\LOVE"
  goto fail
)
if not exist "%LOVE_HOME%\love.dll" (
  echo ERROR: love.dll was not found in "%LOVE_HOME%".
  echo Please point LOVE_HOME to the folder containing love.exe and love.dll.
  goto fail
)

if exist "%DIST%" rmdir /s /q "%DIST%"
if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%DIST%"
if errorlevel 1 goto fail
mkdir "%STAGE%"
if errorlevel 1 goto fail

echo Packaging game files...
set "SOMBIE_GAME=%GAME%"
set "SOMBIE_STAGE=%STAGE%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; $archive = Join-Path $env:SOMBIE_STAGE 'game.zip'; [System.IO.Compression.ZipFile]::CreateFromDirectory($env:SOMBIE_GAME, $archive, [System.IO.Compression.CompressionLevel]::Optimal, $false)"
if errorlevel 1 (
  echo ERROR: Could not package the game files.
  goto fail
)
if not exist "%STAGE%\game.zip" (
  echo ERROR: The game archive was not created.
  goto fail
)
move /y "%STAGE%\game.zip" "%STAGE%\game.love" >nul
if errorlevel 1 goto fail

echo Copying the complete LÖVE runtime...
robocopy "%LOVE_HOME%" "%DIST%" /E /NFL /NDL /NJH /NJS /NP
if errorlevel 8 (
  echo ERROR: Could not copy the LÖVE runtime.
  goto fail
)

if not exist "%DIST%\love.exe" (
  echo ERROR: love.exe was not copied.
  goto fail
)
if not exist "%DIST%\love.dll" (
  echo ERROR: love.dll was not copied.
  goto fail
)

echo Creating the standalone game executable...
copy /b "%DIST%\love.exe"+"%STAGE%\game.love" "%DIST%\SombieCompanion.exe" >nul
if errorlevel 1 (
  echo ERROR: Could not create SombieCompanion.exe.
  goto fail
)
if not exist "%DIST%\SombieCompanion.exe" goto fail

del /q "%DIST%\love.exe"
copy /y "%ROOT%\SombieCompanion\README.txt" "%DIST%\ABOUT.txt" >nul
copy /y "%~dp0START_HERE.txt" "%DIST%\START_HERE.txt" >nul
copy /y "%~dp0Start Sombie Companion.bat" "%DIST%\Start Sombie Companion.bat" >nul
if errorlevel 1 (
  echo ERROR: Could not copy the launcher or readme files.
  goto fail
)

if exist "%STAGE%" rmdir /s /q "%STAGE%"
echo.
echo BUILD COMPLETE.
echo The portable app folder is:
echo %DIST%
echo You can run SombieCompanion.exe directly, or use Start Sombie Companion.bat.
echo Share the ZIP made by build_portable_zip.bat, or share the entire dist folder.
if not defined SOMBIE_NO_PAUSE pause
exit /b 0

:fail
echo.
echo BUILD FAILED. The messages above show what went wrong.
if exist "%STAGE%" rmdir /s /q "%STAGE%"
if not defined SOMBIE_NO_PAUSE pause
exit /b 1
