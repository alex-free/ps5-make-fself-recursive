@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "version=1.0.1"
echo PS5 Make FSELF Recursive v%version%
echo By Alex-Free (C)2026
echo https://github.com/alex-free/ps5-recursive-make-fself
echo Powered by https://github.com/ps5-payload-dev/sdk/blob/master/samples/install_app/make_fself.py.
echo.

rem Folder where this script lives (portable layout: bin\make_fself.py next to it).
set "script_dir=%~dp0"
set "make_fself=%script_dir%bin\make_fself.py"

if not exist "%make_fself%" (
    echo Error: could not find "%make_fself%"
    pause
    exit /b 1
)

rem Find a working Python 3 interpreter (py launcher first, then python / python3).
set "PYTHON="
py -3 --version >nul 2>&1 && set "PYTHON=py -3"
if not defined PYTHON python --version >nul 2>&1 && set "PYTHON=python"
if not defined PYTHON python3 --version >nul 2>&1 && set "PYTHON=python3"
if not defined PYTHON (
    echo Error: Python 3 is required but was not found. Install it from https://www.python.org/downloads/
    pause
    exit /b 1
)

if "%~1"=="" goto :usage
if not exist "%~1\eboot.bin" goto :usage

set "game_dir=%~f1"

rem Temp directory for the copies of the original files.
set "tmp_dir=%TEMP%\ps5mfr.%RANDOM%%RANDOM%"
mkdir "%tmp_dir%" >nul 2>&1 || (
    echo Error: could not create temp directory "%tmp_dir%"
    pause
    exit /b 1
)

set /a self_count=0, elf_count=0, prx_count=0, sprx_count=0

rem Signed Executable and Linkable Format (SELF). Includes eboot.bin (main executable) and any others.
rem A .bin might just be game data, so errors are silenced and only real SELFs are counted.
for /r "%game_dir%" %%F in (*.bin) do call :process "%%F" .bin self quiet

rem ELF.
for /r "%game_dir%" %%F in (*.elf) do call :process "%%F" .elf elf

rem PlayStation Relocatable Executable (game dynamic libraries).
for /r "%game_dir%" %%F in (*.prx) do call :process "%%F" .prx prx

rem System PlayStation Relocatable Extension (system dynamic libraries).
for /r "%game_dir%" %%F in (*.sprx) do call :process "%%F" .sprx sprx

echo.
if %self_count% gtr 0 echo Fake signed %self_count% SELF (.bin) file(s).
if %elf_count% gtr 0 echo Fake signed %elf_count% ELF (.elf) file(s).
if %prx_count% gtr 0 echo Fake signed %prx_count% PRX (.prx) file(s).
if %sprx_count% gtr 0 echo Fake signed %sprx_count% SPRX (.sprx) file(s).

echo Clearing temp files...
rmdir /s /q "%tmp_dir%" >nul 2>&1
endlocal
pause
exit /b 0

:usage
echo Error: first argument should be a PS5 game dump folder
echo Usage: %~nx0 "C:\path\to\game_dump"
pause
exit /b 1

rem %1 = file, %2 = exact extension, %3 = counter name, %4 = "quiet" to silence errors
:process
rem for /r wildcards also match longer extensions (e.g. *.bin matches .bin2), so check exactly.
if /i not "%~x1"=="%~2" exit /b 0
echo.
echo Found %1
echo.
copy /y "%~1" "%tmp_dir%\%~nx1" >nul
if /i "%~4"=="quiet" (
    %PYTHON% "%make_fself%" "%tmp_dir%\%~nx1" "%~1" >nul 2>&1 && set /a %3_count+=1
) else (
    %PYTHON% "%make_fself%" "%tmp_dir%\%~nx1" "%~1"
    set /a %3_count+=1
)
del /f /q "%tmp_dir%\%~nx1" >nul 2>&1
exit /b 0
