@echo off
setlocal
set "APP=%~dp0SombieCompanion.exe"
if not exist "%APP%" (
  echo SombieCompanion.exe was not found.
  echo Keep this launcher in the same folder as the app files.
  pause
  exit /b 1
)
start "" "%APP%" %*
exit /b 0
