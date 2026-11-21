@echo off
setlocal
title Create Sombie Clan Companion ZIP
set "SOMBIE_NO_PAUSE=1"

call "%~dp0build_windows.bat"
if errorlevel 1 goto fail

set "SOMBIE_DIST=%~dp0dist"
set "SOMBIE_ZIP=%~dp0SombieCompanion-Windows.zip"

if not exist "%SOMBIE_DIST%\SombieCompanion.exe" (
  echo ERROR: The finished app EXE is missing. No ZIP will be made.
  goto fail
)
if not exist "%SOMBIE_DIST%\Install Sombie Companion.bat" (
  echo ERROR: The installer is missing. No ZIP will be made.
  goto fail
)

echo.
echo Creating the complete shareable ZIP...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; if (Test-Path $env:SOMBIE_ZIP) { Remove-Item -LiteralPath $env:SOMBIE_ZIP -Force }; [System.IO.Compression.ZipFile]::CreateFromDirectory($env:SOMBIE_DIST, $env:SOMBIE_ZIP, [System.IO.Compression.CompressionLevel]::Optimal, $false)"
if errorlevel 1 goto fail
if not exist "%SOMBIE_ZIP%" goto fail
for %%F in ("%SOMBIE_ZIP%") do if %%~zF LSS 1000000 goto fail

echo.
echo ZIP BUILD COMPLETE:
echo %SOMBIE_ZIP%
echo.
echo SEND THIS ONE ZIP FILE.
echo Recipient: extract it, double-click Install Sombie Companion.bat,
echo and press ENTER. The app and runtime are included; no LÖVE install needed.
if not defined SOMBIE_NO_PAUSE pause
exit /b 0

:fail
echo.
echo ZIP BUILD FAILED. No finished shareable ZIP was produced.
if not defined SOMBIE_NO_PAUSE pause
exit /b 1
