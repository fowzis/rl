@echo off
REM Batch file wrapper to run build-rl.ps1 with execution policy bypass
REM Builds Robotics Library (RL) project

set SCRIPT_DIR=%~dp0
set LOG_DIR=%SCRIPT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Redirect output to log file while also displaying on console using PowerShell Tee-Object
REM Generate timestamp and log file path entirely within PowerShell for reliability
REM Use default install prefix (script directory\install) unless overridden
REM Pass -SkipTranscript to prevent duplicate logging (batch handles logging via Tee-Object)
PowerShell -ExecutionPolicy Bypass -Command "& { $ErrorActionPreference='Continue'; $logDir = '%LOG_DIR%'; $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'; $logFile = Join-Path $logDir \"build-rl-batch-$timestamp.log\"; Write-Host \"Batch log: $logFile\"; & '%SCRIPT_DIR%build-rl.ps1' -SkipTranscript *>&1 | Tee-Object -FilePath $logFile; $exitCode = $LASTEXITCODE; exit $exitCode }"

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
