SOMBIE CLAN COMPANION - WINDOWS PORTABLE BUILD

WHAT TO SEND
Run build_portable_zip.bat on a Windows computer. It creates:
  SombieCompanion-Windows.zip

Send that single ZIP file to the person receiving the app.

HOW TO BUILD
1. Install LÖVE 11.4 or newer on the computer making the build.
2. Double-click build_portable_zip.bat.
3. The completed ZIP will be in this folder.

The build computer needs LÖVE installed. The person receiving the ZIP does NOT.
The ZIP contains the game, the LÖVE runtime and its supporting DLL files.

HOW THE RECIPIENT RUNS IT
1. Right-click the ZIP and choose Extract All.
2. Open the extracted folder.
3. Double-click "Start Sombie Companion.bat" or "SombieCompanion.exe".

Keep the extracted files together. Do not move the EXE away from its DLL files.
The app can be launched directly; no internet connection or separate Lua/LÖVE
installation is required.

BUILDING THE FOLDER ONLY
Run build_windows.bat to create the portable "dist" folder without making a ZIP.
Share the entire dist folder, not just SombieCompanion.exe.

If LÖVE is installed somewhere nonstandard, set LOVE_HOME to the folder
containing love.exe and love.dll before running the build script. Example:
  set "LOVE_HOME=C:\Program Files\LOVE"

DATA
Each person has their own local save data. The app does not connect to a server
or synchronize between users. Save data is stored in the user's local LÖVE
application-data directory, not inside the distribution folder.

NOTES
- Build the Windows version on Windows.
- Keep all runtime DLLs and files beside SombieCompanion.exe.
- Back up local clan data before replacing an older copy.
