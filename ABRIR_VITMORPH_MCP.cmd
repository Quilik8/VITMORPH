@echo off
tasklist /FI "IMAGENAME eq Godot_v4.7.2-stable_win64.exe" | find /I "Godot_v4.7.2" >nul
if not errorlevel 1 exit /b 0
set "TEMP=%~dp0.godot-temp-mcp"
set "TMP=%TEMP%"
if not exist "%TEMP%" mkdir "%TEMP%"
start "" "C:\Users\jp_va\AppData\Local\Programs\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe" --editor --path "%~dp0."
