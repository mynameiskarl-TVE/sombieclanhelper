@echo off
setlocal
title Build Sombie Clan Companion

set "ROOT=%~dp0.."
set "GAME=%ROOT%\SombieCompanion"
set "DIST=%~dp0dist"
set "STAGE=%TEMP%\sombie_companion_build_%RANDOM%_%RANDOM%"

if not exist "%GAME%\main.lua" (
  echo ERROR: Could not find SombieCompanion\main.lua
  goto fail
)

if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE%"
if errorlevel 1 goto fail

rem Use an installed runtime if available; otherwise download the official portable ZIP.
if not defined LOVE_HOME if exist "C:\Program Files\LOVE\love.exe" set "LOVE_HOME=C:\Program Files\LOVE"
if not defined LOVE_HOME if exist "C:\Program Files (x86)\LOVE\love.exe" set "LOVE_HOME=C:\Program Files (x86)\LOVE"
if not defined LOVE_HOME goto download_love
if not exist "%LOVE_HOME%\love.exe" goto download_love
if not exist "%LOVE_HOME%\love.dll" goto download_love
goto have_love

:download_love
echo.
echo LÖVE was not found. Downloading the official portable LÖVE 11.5 runtime...
set "SOMBIE_LOVE_ZIP=%STAGE%\love-11.5-win64.zip"
set "SOMBIE_LOVE_EXTRACT=%STAGE%\love-download"
set "SOMBIE_LOVE_HOME=%STAGE%\love-runtime"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; Add-Type -AssemblyName System.IO.Compression.FileSystem; Invoke-WebRequest -Uri 'https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip' -OutFile $env:SOMBIE_LOVE_ZIP; Expand-Archive -LiteralPath $env:SOMBIE_LOVE_ZIP -DestinationPath $env:SOMBIE_LOVE_EXTRACT -Force; $exe=Get-ChildItem -LiteralPath $env:SOMBIE_LOVE_EXTRACT -Filter 'love.exe' -File -Recurse | Select-Object -First 1; if (-not $exe) { throw 'love.exe was not found in the downloaded archive.' }; New-Item -ItemType Directory -Path $env:SOMBIE_LOVE_HOME -Force | Out-Null; Copy-Item -Path (Join-Path $exe.DirectoryName '*') -Destination $env:SOMBIE_LOVE_HOME -Recurse -Force"
if errorlevel 1 (
  echo ERROR: The LÖVE download or extraction failed.
  echo Check your internet connection and try again.
  goto fail
)
set "LOVE_HOME=%STAGE%\love-runtime"
if not exist "%LOVE_HOME%\love.exe" (
  echo ERROR: Downloaded LÖVE runtime could not be located.
  goto fail
)

:have_love
if not exist "%LOVE_HOME%\love.exe" (
  echo ERROR: love.exe is missing from the selected runtime.
  goto fail
)
if not exist "%LOVE_HOME%\love.dll" (
  echo ERROR: love.dll is missing from the selected runtime.
  goto fail
)
echo Using LÖVE runtime from: %LOVE_HOME%

if exist "%DIST%" rmdir /s /q "%DIST%"
mkdir "%DIST%"
if errorlevel 1 goto fail

echo.
echo Packaging the game...
set "SOMBIE_GAME=%GAME%"
set "SOMBIE_GAMELOVE=%STAGE%\SombieCompanion.love"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory($env:SOMBIE_GAME, $env:SOMBIE_GAMELOVE, [System.IO.Compression.CompressionLevel]::Optimal, $false)"
if errorlevel 1 goto fail
if not exist "%STAGE%\SombieCompanion.love" goto fail

echo.
echo Copying the complete portable LÖVE runtime...
robocopy "%LOVE_HOME%" "%DIST%" /E /NFL /NDL /NJH /NJS /NP
if errorlevel 8 (
  echo ERROR: Could not copy the LÖVE runtime.
  goto fail
)
if not exist "%DIST%\love.exe" goto fail
if not exist "%DIST%\love.dll" goto fail

echo.
echo Creating the fused game executable...
copy /b "%DIST%\love.exe"+"%STAGE%\SombieCompanion.love" "%DIST%\SombieCompanion.exe" >nul
if errorlevel 1 goto fail
if not exist "%DIST%\SombieCompanion.exe" goto fail
del /q "%DIST%\love.exe"

echo.
echo Adding setup files...
copy /y "%ROOT%\SombieCompanion\README.txt" "%DIST%\ABOUT.txt" >nul
if errorlevel 1 goto fail
copy /y "%~dp0START_HERE.txt" "%DIST%\START_HERE.txt" >nul
if errorlevel 1 goto fail
copy /y "%~dp0Start Sombie Companion.bat" "%DIST%\Start Sombie Companion.bat" >nul
if errorlevel 1 goto fail
copy /y "%~dp0Install Sombie Companion.bat" "%DIST%\Install Sombie Companion.bat" >nul
if errorlevel 1 goto fail

if exist "%STAGE%" rmdir /s /q "%STAGE%"
echo.
echo BUILD COMPLETE.
echo Portable app folder: %DIST%
echo Run "Install Sombie Companion.bat" inside dist to test it.
echo Run build_portable_zip.bat to create the one-file ZIP to send.
if not defined SOMBIE_NO_PAUSE pause
exit /b 0

:fail
echo.
echo BUILD FAILED. The app was not packaged. Read the error above.
echo Do not run any launcher until the build completes successfully.
if exist "%STAGE%" rmdir /s /q "%STAGE%"
if not defined SOMBIE_NO_PAUSE pause
exit /b 1
