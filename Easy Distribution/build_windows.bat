@echo off
setlocal
title Build Sombie Clan Companion

set "ROOT=%~dp0.."
set "GAME=%ROOT%\SombieCompanion"
if not exist "%GAME%\main.lua" (
  echo ERROR: Could not find SombieCompanion\main.lua
  pause
  exit /b 1
)

if "%LOVE_HOME%"=="" set "LOVE_HOME=C:\Program Files\LOVE"
if not exist "%LOVE_HOME%\love.exe" set "LOVE_HOME=C:\Program Files (x86)\LOVE"
if not exist "%LOVE_HOME%\love.exe" (
  echo Could not find love.exe.
  echo Install LÖVE 11.4+ or set LOVE_HOME to its install folder.
  echo Example: set LOVE_HOME=C:\Program Files\LOVE
  pause
  exit /b 1
)

set "DIST=%~dp0dist"
set "STAGE=%TEMP%\sombie_companion_build"
if exist "%DIST%" rmdir /s /q "%DIST%"
if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%DIST%"
mkdir "%STAGE%"

echo Packaging game files...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%GAME%\*' -DestinationPath '%STAGE%\game.love' -Force"
if errorlevel 1 (
  echo ERROR: Could not package game files.
  pause
  exit /b 1
)

echo Copying LÖVE runtime...
xcopy "%LOVE_HOME%\*" "%DIST%\" /E /I /Y >nul
if errorlevel 1 (
  echo ERROR: Could not copy the LÖVE runtime.
  pause
  exit /b 1
)

if not exist "%DIST%\love.exe" (
  echo ERROR: love.exe was not copied.
  pause
  exit /b 1
)

echo Creating standalone game executable...
copy /b "%DIST%\love.exe"+"%STAGE%\game.love" "%DIST%\SombieCompanion.exe" >nul
if errorlevel 1 (
  echo ERROR: Could not create the fused executable.
  pause
  exit /b 1
)
del "%DIST%\love.exe"

copy "%ROOT%\SombieCompanion\README.txt" "%DIST%\ABOUT.txt" >nul
if exist "%~dp0README.txt" copy "%~dp0README.txt" "%DIST%\DISTRIBUTION.txt" >nul

echo.
echo BUILD COMPLETE.
echo Your distributable app is here:
echo %DIST%
echo Share the ENTIRE dist folder, not just the EXE.
pause
