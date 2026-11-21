SOMBIE // CLAN COMPANION
Version 0.3 - Expanded offline clan-leader toolkit

WHAT THIS IS
A personal companion app for Sombie players and especially clan leaders.
Every ally runs their own local copy. There are no accounts, server, online
clan network, subscriptions or automatic connection to Sombie.

REQUIREMENTS
- LÖVE 11.4 or newer

RUN
1. Install LÖVE from https://love2d.org/
2. Drag the SombieCompanion folder onto love.exe, or run: love SombieCompanion

FEATURES
- Dashboard overview
- Events: date, leader, description, attendee list, checklist and attachments
- Members: role, notes and three editable free-text server fields
- Projects: open individual projects, edit their description and notes,
  add checklist tasks, attach images and spreadsheets/documents
- Resources: current and target quantities, notes, category and attachments
- Missions: objectives, rewards, notes and checklist tasks
- Local JSON save file

ATTACHMENTS
Use the full file path in the attachment dialog. The app copies the selected
file into its own local attachments folder. PNG/JPG images can be previewed in
the app. CSV, XLSX and other files are stored as attachments and opened with
the computer's default application. Spreadsheet contents are not yet parsed
or edited inside the app.

DATA AND PRIVACY
All records and copied attachments stay in the local LÖVE save directory.
The app does not transmit information anywhere. Back up the save directory
before moving computers or reinstalling. The app's identity is unchanged, so
existing clan_data.json data should be retained and upgraded with new fields.

NOTES / LIMITATIONS
- File attachments are added by typing or pasting a full file path; LÖVE2D
  does not include a built-in cross-platform file picker.
- No live Sombie game integration or automatic player/server lookup.
- Data is personal to each installation; no sharing or synchronisation.
- The spreadsheet files are attachments, not editable in-app spreadsheets.
