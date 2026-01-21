@ECHO OFF
ECHO(
ECHO ================================================================
ECHO GrEEV.com KG - EXECUTIONPOLICY FOUNDATION for PS v2.0.0
ECHO "www.greev.com | office@greev.com | Dual Licensed"
ECHO ================================================================
ECHO(
ECHO Copyright (C) 2026 GrEEV.com KG. All rights reserved.
ECHO(
ECHO Dual Licensed:
ECHO 1. AGPLv3 (Community Edition) - for OSS projects
ECHO 2. MIT License (Commercial-Friendly) - for commercial use
ECHO 3. Professional Support - EUR 499/year
ECHO(
ECHO SPDX-License-Identifier: (AGPL-3.0-or-later OR MIT)
ECHO "Support: support@greev.com | www.greev.com"
ECHO ================================================================

SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >nul 2>&1

REM ================================================================
REM PARAMETER PARSING
REM ================================================================

SET "SCRIPT_NAME=%~1"
SET "LANGUAGE=%~2"

IF NOT DEFINED SCRIPT_NAME SET "SCRIPT_NAME=Start.ps1"
IF NOT DEFINED LANGUAGE SET "LANGUAGE=en"

REM ================================================================
REM  DETECT: PowerShell 7 (pwsh.exe) vs PowerShell 5.1 (powershell.exe)
REM ================================================================

SETLOCAL EnableDelayedExpansion


SET "PS_EXECUTABLE=powershell.exe"
REM Try to find pwsh.exe (PowerShell 7+)

WHERE pwsh.exe >nul 2>&1

IF !ERRORLEVEL! EQU 0 (
    SET "PS_EXECUTABLE=pwsh.exe"
    ECHO "[INFO] Using PowerShell 7+ (pwsh.exe)"
) ELSE (
    ECHO [INFO] Using Windows PowerShell 5.1 (powershell.exe)
)

REM ================================================================
REM MAIN EXECUTION
REM ================================================================

ECHO(
ECHO ============================================================
ECHO ExecutionPolicy Foundation v2.0.0 - GrEEV.com KG
ECHO Dual Licensed (AGPLv3/MIT) with Professional Support Option
ECHO ============================================================
ECHO(

REM POWERSHELL -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0Start.ps1' -ScriptName '!SCRIPT_NAME!' -Language '!LANGUAGE!'"

%PS_EXECUTABLE% -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0!SCRIPT_NAME!' -ScriptName '!SCRIPT_NAME!' -Language '!LANGUAGE!'"


SET "EXIT_CODE=!ERRORLEVEL!"

ECHO(
IF !EXIT_CODE! EQU 0 (
    ECHO ============================================================
    ECHO [OK] Script completed successfully
    ECHO "Need support? support@greev.com (EUR 499/year)"
    ECHO ============================================================
) ELSE (
    ECHO ============================================================
    ECHO [ERROR] Script failed with exit code !EXIT_CODE!
    ECHO Issues? Contact: office@greev.com
    ECHO ============================================================
    ECHO(
    PAUSE
)

EXIT /B !EXIT_CODE!

