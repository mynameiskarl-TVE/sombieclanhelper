SOMBIE CLAN COMPANION - WINDOWS DISTRIBUTION

This folder contains scripts for making a standalone Windows build.

QUICK BUILD
1. Install LÖVE 11.4 or newer from https://love2d.org/
2. Run build_windows.bat.
3. When it finishes, open the "dist" folder.
4. Share the entire dist folder (or zip it) with your clan members.

The generated SombieCompanion.exe contains the game itself. The LÖVE
runtime DLLs and supporting files are copied beside it, so recipients do
not need to install LÖVE separately. Do not share only the EXE: share the
whole dist folder or its ZIP.

If the script cannot find LÖVE, set LOVE_HOME to the folder containing
love.exe before running the script. Example:
  set LOVE_HOME=C:\Program Files\LOVE

DATA
Each person gets their own local save data. The app does not connect to a
server or synchronize between users. Save data is stored in the user's
local LÖVE application-data directory, not inside the distribution folder.

UPDATING
Build a fresh dist folder after changing the source. Users should back up
their local Sombie clan data before replacing an older copy.

NOTES
- Build on Windows to create a Windows EXE.
- Keep all runtime DLLs and files in dist.
- This script uses the installed LÖVE runtime; it does not download it.
