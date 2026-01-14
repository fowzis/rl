@echo off
REM Batch file wrapper to run build-rl.ps1 with execution policy bypass
REM Builds Robotics Library (RL) project
REM 
REM Usage: build-rl.bat [parameters]
REM Examples:
REM   build-rl.bat                    - Build shared libraries (default)
REM   build-rl.bat -BuildStatic      - Build static libraries
REM   build-rl.bat -Clean -BuildStatic - Clean previous build and build static libraries
REM   build-rl.bat -BuildStatic -Config Debug -Architecture x64
REM   build-rl.bat -BuildDocumentation - Build with Doxygen documentation (requires Doxygen)

set SCRIPT_DIR=%~dp0
set LOG_DIR=%SCRIPT_DIR%..\logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Redirect output to log file while also displaying on console using PowerShell Tee-Object
REM Generate timestamp and log file path entirely within PowerShell for reliability
REM Pass all command-line arguments to the PowerShell script via wrapper
PowerShell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%build-rl-wrapper.ps1" "%LOG_DIR%" %*

set EXIT_CODE=%ERRORLEVEL%

if %EXIT_CODE% NEQ 0 (
    echo.
    echo Script failed with error code %EXIT_CODE%
    echo Build log saved to: %LOG_DIR%
    pause
    exit /b %EXIT_CODE%
)

echo.
echo Build log saved to: %LOG_DIR%
pause
