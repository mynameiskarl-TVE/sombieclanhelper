SOMBIE // CLAN COMPANION
Version 0.4 - Offline clan-leader toolkit

WHAT THIS IS
A personal companion app for Sombie players and especially clan leaders.
Every ally runs their own local copy. There are no accounts, server, online
clan network, subscriptions or automatic connection to Sombie.

RUN FROM SOURCE
For development, install LÖVE 11.4 or newer and drag the SombieCompanion
folder onto love.exe, or run: love SombieCompanion

FEATURES
- Dashboard overview
- Events: date, leader, description, attendee list, checklist and attachments
- Members: role, notes and three editable free-text server fields
- Projects: descriptions, notes, checklist tasks and supporting files
- Resources: current and target quantities, notes, category and attachments
- Missions: objectives, rewards, notes and checklist tasks
- Attachment browser across projects, events, resources and missions
- Local editable spreadsheet workspace
- Local JSON save file

ATTACHMENTS
Use the full file path in the attachment dialog. The app copies the selected
file into its own local attachments folder. PNG/JPG images can be previewed.
Files can be dragged onto an open event, project, resource or mission.
A native file picker is not included yet.

SPREADSHEETS
The Sheets tab provides editable local tables saved with the clan data.
This is a lightweight table editor, not a full Excel replacement. CSV import,
CSV export, formulas and XLSX editing are not included yet.

WINDOWS PORTABLE INSTALLER
Run build_portable_zip.bat in the Easy Distribution folder on Windows. It
automatically downloads the official portable LÖVE 11.5 runtime ZIP if a usable
runtime is not already available. It does not install LÖVE into Windows.

Send SombieCompanion-Windows.zip to the recipient. They extract it, double-click
"Install Sombie Companion.bat", and press ENTER. The installer copies the app
and runtime files, creates a desktop shortcut, and launches it. The recipient
does not need LÖVE or Lua installed and does not need internet.

DATA AND PRIVACY
All records and copied attachments stay in the local LÖVE save directory.
The app does not transmit information anywhere. Back up the save directory
before moving computers or reinstalling. The app identity remains
"sombie_companion", preserving existing clan_data.json data.

NOTES / LIMITATIONS
- No live Sombie game integration or automatic player/server lookup.
- Data is personal to each installation; no sharing or synchronisation.
- Windows EXE builds are for Windows PCs.
