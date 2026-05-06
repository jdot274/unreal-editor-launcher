@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  launch-unreal-editor.bat
REM  Locates and launches the Unreal Engine Editor from the
REM  Windows command prompt.
REM
REM  Usage:
REM     launch-unreal-editor.bat                     -- launch newest installed version
REM     launch-unreal-editor.bat path\to\Project.uproject  -- open a project
REM
REM  Override detection by setting UE_PATH to the full path of
REM  UnrealEditor.exe before running this script:
REM     set UE_PATH=D:\Epic\UE_5.4\Engine\Binaries\Win64\UnrealEditor.exe
REM ============================================================

set "EDITOR_EXE="

REM 1. Honor explicit override
if defined UE_PATH (
    if exist "%UE_PATH%" (
        set "EDITOR_EXE=%UE_PATH%"
        goto :launch
    ) else (
        echo [ERROR] UE_PATH is set but the file does not exist:
        echo         %UE_PATH%
        exit /b 1
    )
)

REM 2. Scan the standard Epic Games install roots for the newest UE_x.y
set "ROOTS=C:\Program Files\Epic Games;D:\Program Files\Epic Games;C:\Epic Games;D:\Epic Games"

set "BEST_VERSION=0.0"
set "BEST_EXE="

for %%R in ("%ROOTS:;=" "%") do (
    if exist %%~R (
        for /d %%D in ("%%~R\UE_*") do (
            set "CANDIDATE=%%~D\Engine\Binaries\Win64\UnrealEditor.exe"
            if exist "!CANDIDATE!" (
                set "VER=%%~nxD"
                set "VER=!VER:UE_=!"
                call :compare_versions "!VER!" "!BEST_VERSION!"
                if "!CMP!"=="GT" (
                    set "BEST_VERSION=!VER!"
                    set "BEST_EXE=!CANDIDATE!"
                )
            )
        )
    )
)

if defined BEST_EXE (
    set "EDITOR_EXE=%BEST_EXE%"
    echo [INFO] Using Unreal Engine !BEST_VERSION!
    goto :launch
)

echo [ERROR] Could not find an installed Unreal Editor.
echo         Searched: %ROOTS%
echo         Set UE_PATH to the full path of UnrealEditor.exe to override.
exit /b 1

:launch
echo [INFO] Launching: %EDITOR_EXE%
if "%~1"=="" (
    start "" "%EDITOR_EXE%"
) else (
    start "" "%EDITOR_EXE%" "%~1"
)
exit /b 0

REM ----- helpers -----
:compare_versions
REM Compares %1 and %2 as dotted versions. Sets CMP to GT, LT, or EQ.
set "A=%~1"
set "B=%~2"
for /f "tokens=1,2 delims=." %%a in ("%A%") do (
    set "A_MAJOR=%%a"
    set "A_MINOR=%%b"
)
for /f "tokens=1,2 delims=." %%a in ("%B%") do (
    set "B_MAJOR=%%a"
    set "B_MINOR=%%b"
)
if not defined A_MINOR set "A_MINOR=0"
if not defined B_MINOR set "B_MINOR=0"
set "CMP=EQ"
if %A_MAJOR% GTR %B_MAJOR% set "CMP=GT" & goto :eof
if %A_MAJOR% LSS %B_MAJOR% set "CMP=LT" & goto :eof
if %A_MINOR% GTR %B_MINOR% set "CMP=GT" & goto :eof
if %A_MINOR% LSS %B_MINOR% set "CMP=LT" & goto :eof
goto :eof
