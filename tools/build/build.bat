@echo off
rem Copyright (c) 2020 Aleksej Komarov
rem SPDX-License-Identifier: MIT
call node "%~dp0\build.js" %*
rem Pause if launched in a separate shell unless initiated from powershell
echo %PSModulePath% | findstr %USERPROFILE% >NUL
if %errorlevel% equ 0 exit 0
echo %cmdcmdline% | find /i "/c"
if %errorlevel% equ 0 pause
