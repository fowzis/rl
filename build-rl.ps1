# PowerShell script to build Robotics Library (RL)
# Usage: .\build-rl.ps1 [-InstallPrefix <path>] [-ThirdPartyPrefix <path>] [-VisualStudioVersion <version>] [-Architecture <x64|x86>] [-Config <Release|Debug>] [-BuildSharedLibs]

param(
    [string]$InstallPrefix = "$PSScriptRoot\install",
    [string]$ThirdPartyPrefix = "$PSScriptRoot\..\rl-3rdparty\install",
    [string]$VisualStudioVersion = "17",  # Visual Studio 2022
    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64",
    [ValidateSet("Release", "Debug", "RelWithDebInfo", "MinSizeRel")]
    [string]$Config = "Release",
    [switch]$SkipBuild,
    [switch]$SkipInstall,
    [int]$ParallelJobs = 0,  # 0 = use all available cores
    [switch]$BuildDemos = $true,
    [switch]$BuildExtras = $true,
    [switch]$BuildMath = $true,
    [switch]$BuildTests = $false,
    [switch]$BuildUtil = $true,
    [switch]$BuildXml = $true,
    [switch]$BuildSharedLibs = $true,  # Build shared libraries (DLLs) - enabled by default for C# interoperability
    [switch]$SkipTranscript  # Skip Start-Transcript when called from batch wrapper
)

$ErrorActionPreference = "Stop"

# Setup logging
$logDir = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path $logDir "build-rl-$timestamp.log"

# Start transcript to capture all output (unless called from batch wrapper)
$transcriptStarted = $false
if (-not $SkipTranscript) {
    Start-Transcript -Path $logFile -Append | Out-Null
    $transcriptStarted = $true
    Write-Host "Logging output to: $logFile" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Robotics Library Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check CMake version
Write-Host "Checking CMake version..." -ForegroundColor Yellow
$cmakeVersion = & cmake --version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: CMake not found. Please install CMake 3.1 or later." -ForegroundColor Red
    exit 1
}
Write-Host "Found: $cmakeVersion" -ForegroundColor Green

# Verify third-party dependencies exist
Write-Host "Checking third-party dependencies..." -ForegroundColor Yellow
if (-not (Test-Path $ThirdPartyPrefix)) {
    Write-Host "ERROR: Third-party dependencies not found at: $ThirdPartyPrefix" -ForegroundColor Red
    Write-Host "Please build rl-3rdparty first using build-3rdparty.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "Found third-party dependencies at: $ThirdPartyPrefix" -ForegroundColor Green
Write-Host ""

# Determine Visual Studio generator
$generator = "Visual Studio $VisualStudioVersion 2022"
if ($VisualStudioVersion -eq "16") {
    $generator = "Visual Studio 16 2019"
} elseif ($VisualStudioVersion -eq "15") {
    $generator = "Visual Studio 15 2017"
}

Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Generator: $generator" -ForegroundColor White
Write-Host "  Architecture: $Architecture" -ForegroundColor White
Write-Host "  Configuration: $Config" -ForegroundColor White
Write-Host "  Install Prefix: $InstallPrefix" -ForegroundColor White
Write-Host "  Third-Party Prefix: $ThirdPartyPrefix" -ForegroundColor White
Write-Host "  Parallel Jobs: $(if ($ParallelJobs -eq 0) { 'All available' } else { $ParallelJobs })" -ForegroundColor White
Write-Host "  Build Shared Libraries (DLLs): $BuildSharedLibs" -ForegroundColor White
Write-Host "  Build Demos: $BuildDemos" -ForegroundColor White
Write-Host "  Build Extras: $BuildExtras" -ForegroundColor White
Write-Host "  Build Math: $BuildMath" -ForegroundColor White
Write-Host "  Build Tests: $BuildTests" -ForegroundColor White
Write-Host "  Build Util: $BuildUtil" -ForegroundColor White
Write-Host "  Build XML: $BuildXml" -ForegroundColor White
Write-Host ""

# Create build directory
$buildDir = Join-Path $PSScriptRoot "build"
if (-not (Test-Path $buildDir)) {
    Write-Host "Creating build directory: $buildDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

Push-Location $buildDir

try {
    # Configure CMake
    Write-Host "Configuring CMake..." -ForegroundColor Yellow
    $cmakeArgs = @(
        ".."
        "-G", "`"$generator`""
        "-A", $Architecture
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.1"
        "-DCMAKE_INSTALL_PREFIX=`"$InstallPrefix`""
        "-DCMAKE_BUILD_TYPE=$Config"
        "-DCMAKE_PREFIX_PATH=`"$ThirdPartyPrefix`""
        "-DBUILD_SHARED_LIBS=$(if ($BuildSharedLibs) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_DEMOS=$(if ($BuildDemos) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_EXTRAS=$(if ($BuildExtras) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_MATH=$(if ($BuildMath) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_TESTS=$(if ($BuildTests) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_UTIL=$(if ($BuildUtil) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_XML=$(if ($BuildXml) { 'ON' } else { 'OFF' })"
    )
    
    Write-Host "Running: cmake $($cmakeArgs -join ' ')" -ForegroundColor Gray
    & cmake @cmakeArgs 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: CMake configuration failed!" -ForegroundColor Red
        Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Configuration successful!" -ForegroundColor Green
    Write-Host ""
    
    if (-not $SkipBuild) {
        # Build RL
        Write-Host "Building Robotics Library (this may take some time)..." -ForegroundColor Yellow
        $buildArgs = @(
            "--build", "."
            "--config", $Config
        )
        
        if ($ParallelJobs -gt 0) {
            $buildArgs += "--parallel", $ParallelJobs
        } else {
            $buildArgs += "--parallel"
        }
        
        Write-Host "Running: cmake $($buildArgs -join ' ')" -ForegroundColor Gray
        & cmake @buildArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed!" -ForegroundColor Red
            Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "Build successful!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "Skipping build (--SkipBuild specified)" -ForegroundColor Yellow
        Write-Host ""
    }
    
    if (-not $SkipInstall) {
        # Install RL
        Write-Host "Installing Robotics Library..." -ForegroundColor Yellow
        $installArgs = @(
            "--build", "."
            "--config", $Config
            "--target", "install"
        )
        
        Write-Host "Running: cmake $($installArgs -join ' ')" -ForegroundColor Gray
        & cmake @installArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "WARNING: Install failed, but build artifacts are in the build directory" -ForegroundColor Yellow
            Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
        } else {
            Write-Host "Installation successful!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Robotics Library installed to: $InstallPrefix" -ForegroundColor Green
        }
    } else {
        Write-Host "Skipping install (--SkipInstall specified)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Build Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    if ($transcriptStarted) {
        Write-Host "Build log saved to: $logFile" -ForegroundColor Gray
        Write-Host ""
    }
    
} finally {
    Pop-Location
    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
}
