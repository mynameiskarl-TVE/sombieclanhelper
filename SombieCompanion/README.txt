SOMBIE // CLAN COMPANION
Version 0.4 - Offline clan-leader toolkit

WHAT THIS IS
A personal companion app for Sombie players and especially clan leaders.
Every ally runs their own local copy. There are no accounts, server, online
clan network, subscriptions or automatic connection to Sombie.

REQUIREMENTS
- LÖVE 11.4 or newer (for running from source)

RUN FROM SOURCE
1. Install LÖVE from https://love2d.org/
2. Drag the SombieCompanion folder onto love.exe, or run: love SombieCompanion

FEATURES
- Dashboard overview
- Events: date, leader, description, attendee list, checklist and attachments
- Members: role, notes and three editable free-text server fields
- Projects: descriptions, notes, checklist tasks and supporting files
- Resources: current and target quantities, notes, category and attachments
- Missions: objectives, rewards, notes and checklist tasks
- Attachment browser: one place to browse attachments across projects, events,
  resources and missions, with image thumbnails and an Open action
- Local editable spreadsheet workspace: create sheets, add rows/columns, click
  cells and type; use arrow keys / Tab to move between cells
- Local JSON save file

ATTACHMENTS
Use the full file path in the attachment dialog. The app copies the selected
file into its own local attachments folder. PNG/JPG images can be previewed.
Files are listed together in the Files tab and can be opened with the computer's
default application. A native file picker is not included yet, so file paths
are still entered manually when adding a new attachment.

SPREADSHEETS
The Sheets tab provides editable local tables saved with the clan data. Click
a cell and type; use arrow keys or Tab to move. Add rows and columns as needed.
This is a lightweight table editor, not a full Excel replacement. CSV import,
CSV export, formulas and XLSX editing are not included yet. Existing XLSX/CSV
attachments can still be opened in an external spreadsheet program.

WINDOWS DISTRIBUTION
Use the scripts in the separate "Easy Distribution" folder. On Windows, install
LÖVE 11.4+, then run build_windows.bat. It creates a dist folder containing a
fused SombieCompanion.exe and the LÖVE runtime files. Share the entire dist
folder, or run build_portable_zip.bat to create a ZIP. Recipients do not need
to install LÖVE separately.

DATA AND PRIVACY
All records and copied attachments stay in the local LÖVE save directory.
The app does not transmit information anywhere. Back up the save directory
before moving computers or reinstalling. The app identity remains
"sombie_companion", preserving existing clan_data.json data.

NOTES / LIMITATIONS
- No live Sombie game integration or automatic player/server lookup.
- Data is personal to each installation; no sharing or synchronisation.
- Windows EXE builds must be made on Windows using the supplied scripts.
