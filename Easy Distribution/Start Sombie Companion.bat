@echo off
setlocal
set "APP=%~dp0SombieCompanion.exe"
if exist "%APP%" goto launch
set "APP=%~dp0dist\SombieCompanion.exe"
if exist "%APP%" goto launch

echo SombieCompanion.exe was not found.
echo This is the source/build-tools folder, not the finished app folder.
echo Run build_portable_zip.bat to create the complete shareable ZIP.
echo After a successful build, the ready-to-run app is inside the dist folder.
pause
exit /b 1

:launch
start "" "%APP%" %*
exit /b 0
