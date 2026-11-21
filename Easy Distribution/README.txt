SOMBIE CLAN COMPANION - WINDOWS DISTRIBUTION

EASIEST OPTION
A GitHub Actions workflow builds the Windows ZIP automatically whenever the
app or packaging files change. Open the repository's Actions tab, select
"Build Sombie Companion for Windows", open the latest successful run, and
download the "SombieCompanion-Windows" artifact.

BUILD ON YOUR OWN WINDOWS PC
1. Run build_portable_zip.bat.
2. It uses an installed LÖVE runtime if available.
3. If it cannot find one, it downloads the official portable LÖVE 11.5 ZIP.
4. It creates SombieCompanion-Windows.zip in this folder.

You do not need to install LÖVE just to build. The build script downloads the
portable runtime ZIP and uses it without installing it into Windows.

WHAT TO SEND
Send only SombieCompanion-Windows.zip.

RECIPIENT SETUP
1. Extract the ZIP.
2. Double-click "Install Sombie Companion.bat".
3. Press ENTER when prompted.

The installer copies the application and runtime to the user's local Programs
folder, creates a desktop shortcut, and launches the app. The recipient does
not need LÖVE, Lua, administrator permission, or internet.

The ZIP contains the fused SombieCompanion.exe and matching runtime DLLs.
Keep those runtime files together. This follows the official LÖVE Windows
distribution approach.

Each person has their own local save data. No server or synchronization is
used. Existing saves keep the same LÖVE identity: "sombie_companion".
