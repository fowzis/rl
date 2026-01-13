@echo off
REM Robotics Library - DLLs Deployment Script (Batch Wrapper)
REM This batch file calls the PowerShell script with default parameters
REM Target directory: deployment/dlls

echo ========================================
echo Robotics Library DLLs Full Deployment
echo ========================================
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%deploy-dlls.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Script execution failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Script completed successfully!
pause
