@echo off
REM Robotics Library - Executable Deployment Script (Batch Wrapper)
REM This batch file calls the PowerShell script with default parameters
REM Target directory: deployment/exe

echo ========================================
echo Robotics Library Full Install Copy
echo ========================================
echo.

REM Get the directory where this batch file is located
set SCRIPT_DIR=%~dp0

REM Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%deploy-exe.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Script execution failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Script completed successfully!
pause
