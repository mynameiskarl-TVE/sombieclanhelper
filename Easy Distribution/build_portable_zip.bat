@echo off
setlocal
title Create Sombie Clan Companion ZIP

set "SOMBIE_NO_PAUSE=1"
call "%~dp0build_windows.bat"
if errorlevel 1 goto fail

set "SOMBIE_DIST=%~dp0dist"
set "SOMBIE_ZIP=%~dp0SombieCompanion-Windows.zip"

echo Creating the shareable ZIP...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Add-Type -AssemblyName System.IO.Compression.FileSystem; if (Test-Path $env:SOMBIE_ZIP) { Remove-Item -LiteralPath $env:SOMBIE_ZIP -Force }; [System.IO.Compression.ZipFile]::CreateFromDirectory($env:SOMBIE_DIST, $env:SOMBIE_ZIP, [System.IO.Compression.CompressionLevel]::Optimal, $false)"
if errorlevel 1 (
  echo ERROR: Could not create the ZIP file.
  goto fail
)
if not exist "%SOMBIE_ZIP%" (
  echo ERROR: The ZIP file was not created.
  goto fail
)

echo.
echo ZIP BUILD COMPLETE:
echo %SOMBIE_ZIP%
echo.
echo Send this ONE ZIP file to the other person.
echo They must extract it first, then double-click Start Sombie Companion.bat
echo or SombieCompanion.exe. They do not need to install LÖVE.
pause
exit /b 0

:fail
echo.
echo ZIP BUILD FAILED. Check the error messages above.
pause
exit /b 1
