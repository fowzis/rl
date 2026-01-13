# Wrapper script to handle logging and pass arguments to build-rl.ps1
# First argument is the log directory, remaining arguments are passed to build-rl.ps1

$ErrorActionPreference = "Continue"

# First argument is the log directory
$logDir = $args[0]

# Ensure log directory exists (it may have been removed during cleanup)
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Setup batch-specific logging
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $logDir "build-rl-batch-$timestamp.log"
Write-Host "Batch log: $logFile"

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $scriptDir "build-rl.ps1"

# Get all remaining arguments (skip the first one which is the log directory)
$scriptArgs = @()
if ($args.Count -gt 1) {
    $scriptArgs = $args[1..($args.Count - 1)]
}

# Call the main script with all arguments and -SkipTranscript switch (batch handles logging)
# Pass SkipTranscript as a separate explicit parameter to avoid it being treated as a positional argument
# Use explicit UTF-8 encoding for log file
$null = New-Item -Path $logFile -ItemType File -Force
& $scriptPath @scriptArgs -SkipTranscript *>&1 | ForEach-Object {
    Write-Host $_
    # Ensure log directory exists (it may have been removed during cleanup)
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    try {
        $_ | Out-File -FilePath $logFile -Append -Encoding utf8 -NoNewline:$false -ErrorAction Stop
    }
    catch {
        # If write fails, recreate directory and try again
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        $_ | Out-File -FilePath $logFile -Append -Encoding utf8 -NoNewline:$false
    }
}

$exitCode = $LASTEXITCODE
exit $exitCode
