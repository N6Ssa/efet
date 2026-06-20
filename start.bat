@echo off
cd /d "%~dp0"
where npm >nul 2>&1
if %errorlevel%==0 (
  echo Starting Vite dev server...
  call npm run dev
) else (
  echo npm not found — using PowerShell dev server.
  echo For full hot reload run: npm install ^&^& npm run dev
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev_server.ps1"
)
pause
