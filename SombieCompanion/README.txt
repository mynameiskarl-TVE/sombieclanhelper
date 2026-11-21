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

WINDOWS PORTABLE VERSION
The Easy Distribution folder contains build scripts. On the build computer,
install LÖVE 11.4 or newer and run build_portable_zip.bat. It creates one
SombieCompanion-Windows.zip containing the app and the required LÖVE runtime.
Send that ZIP to the recipient. They extract it and double-click
"Start Sombie Companion.bat" or "SombieCompanion.exe". Recipients do not need
to install LÖVE or Lua separately. Keep the extracted runtime DLL files beside
the EXE.

DATA AND PRIVACY
All records and copied attachments stay in the local LÖVE save directory.
The app does not transmit information anywhere. Back up the save directory
before moving computers or reinstalling. The app identity remains
"sombie_companion", preserving existing clan_data.json data.

NOTES / LIMITATIONS
- No live Sombie game integration or automatic player/server lookup.
- Data is personal to each installation; no sharing or synchronisation.
- Windows EXE builds must be made on Windows using the supplied scripts.
