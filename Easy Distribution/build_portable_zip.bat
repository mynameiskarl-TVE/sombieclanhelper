@echo off
setlocal
call "%~dp0build_windows.bat"
if errorlevel 1 exit /b 1
if not exist "%~dp0dist\SombieCompanion.exe" exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (Test-Path '%~dp0SombieCompanion-Windows.zip') { Remove-Item '%~dp0SombieCompanion-Windows.zip' -Force }; Compress-Archive -Path '%~dp0dist\*' -DestinationPath '%~dp0SombieCompanion-Windows.zip' -Force"
if errorlevel 1 (
  echo Could not create ZIP.
  pause
  exit /b 1
)
echo Created: %~dp0SombieCompanion-Windows.zip
pause
