# Win11 To-Do Desktop (Tauri + React + TypeScript)

This repository contains a Windows 11 style desktop to-do app built with Tauri v2 and React.

## MVP status

This PR scaffolds the desktop application shell and routing for:

- Today
- Calendar
- All Tasks
- Completed

## Local development

```bash
npm install
npm run dev
npm run tauri dev
npm run tauri build
```

## Planned next steps

1. Add SQLite persistence with migrations and typed data access layer.
2. Implement task CRUD with filters, sorting, and search.
3. Build calendar month grid + agenda experience.
