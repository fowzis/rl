# PowerShell script to build Robotics Library (RL)
# Usage: .\build-rl.ps1 [-InstallPrefix <path>] [-ThirdPartyPrefix <path>] [-VisualStudioVersion <version>] [-Architecture <x64|x86>] [-Config <Release|Debug>] [-BuildStatic] [-Clean] [-BuildDocumentation]

param(
    [string]$InstallPrefix = "",
    [string]$ThirdPartyPrefix = "",
    [string]$VisualStudioVersion = "17",  # Visual Studio 2022
    [ValidateSet("x64", "x86")]
    [string]$Architecture = "x64",
    [ValidateSet("Release", "Debug", "RelWithDebInfo", "MinSizeRel")]
    [string]$Config = "Release",
    [switch]$SkipBuild,
    [switch]$SkipInstall,
    [switch]$BuildStatic,  # Build static libraries instead of shared libraries (DLLs)
    [switch]$Clean,  # Clean previous build/install/logs directories before building
    [int]$ParallelJobs = 0,  # 0 = use all available cores
    [switch]$BuildDemos = $true,
    [switch]$BuildExtras = $true,
    [switch]$BuildMath = $true,
    [switch]$BuildTests = $false,
    [switch]$BuildUtil = $true,
    [switch]$BuildXml = $true,
    [switch]$BuildDocumentation = $false,  # Build Doxygen documentation (requires Doxygen to be installed)
    [switch]$SkipTranscript  # Skip Start-Transcript when called from batch wrapper
)

$ErrorActionPreference = "Stop"

# Determine the root directory of the RL project (parent of scripts directory)
# $PSScriptRoot is the directory where this script is located
$RLRoot = Split-Path -Parent $PSScriptRoot

# Set default third-party prefix if not provided (parent of RL root + rl-3rdparty/install)
if ([string]::IsNullOrEmpty($ThirdPartyPrefix)) {
    $ThirdPartyPrefix = Join-Path (Split-Path -Parent $RLRoot) "rl-3rdparty\install"
}

# Set default install prefix if not provided
if ([string]::IsNullOrEmpty($InstallPrefix)) {
    $InstallPrefix = Join-Path $RLRoot "install"
}

# Clean previous build, install, and logs if requested (do this BEFORE starting transcript)
if ($Clean) {
    Write-Host "Cleaning previous build artifacts..." -ForegroundColor Yellow
    
    # Remove build directory
    $buildDir = Join-Path $RLRoot "build"
    if (Test-Path $buildDir) {
        Write-Host "  Removing build directory: $buildDir" -ForegroundColor Gray
        Remove-Item -Path $buildDir -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $buildDir) {
            Write-Host "  WARNING: Could not fully remove build directory. Some files may be locked." -ForegroundColor Yellow
        }
        else {
            Write-Host "  Build directory removed." -ForegroundColor Green
        }
    }
    
    # Remove install directory
    if (Test-Path $InstallPrefix) {
        Write-Host "  Removing install directory: $InstallPrefix" -ForegroundColor Gray
        Remove-Item -Path $InstallPrefix -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $InstallPrefix) {
            Write-Host "  WARNING: Could not fully remove install directory. Some files may be locked." -ForegroundColor Yellow
        }
        else {
            Write-Host "  Install directory removed." -ForegroundColor Green
        }
    }
    
    # Remove logs directory (but keep current session log if transcript is active)
    $logDir = Join-Path $RLRoot "logs"
    if (Test-Path $logDir) {
        Write-Host "  Removing logs directory: $logDir" -ForegroundColor Gray
        Remove-Item -Path $logDir -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $logDir) {
            Write-Host "  WARNING: Could not fully remove logs directory. Some files may be locked." -ForegroundColor Yellow
        }
        else {
            Write-Host "  Logs directory removed." -ForegroundColor Green
        }
    }
    
    Write-Host "Cleanup complete!" -ForegroundColor Green
    Write-Host ""
}

# Setup logging (after cleanup)
$logDir = Join-Path $RLRoot "logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Start transcript to capture all output (unless called from batch wrapper)
$transcriptStarted = $false
if (-not $SkipTranscript) {
    $logFile = Join-Path $logDir "build-rl-$timestamp.log"
    Start-Transcript -Path $logFile -Append | Out-Null
    $transcriptStarted = $true
    Write-Host "Logging output to: $logFile" -ForegroundColor Gray
    Write-Host ""
}
else {
    # When SkipTranscript is used, batch wrapper handles logging via Tee-Object
    # Reference the batch log file pattern for error messages
    $logFile = Join-Path $logDir "build-rl-batch-*.log"
    Write-Host "Logging handled by batch wrapper" -ForegroundColor Gray
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
if ([string]::IsNullOrEmpty($ThirdPartyPrefix) -or -not (Test-Path $ThirdPartyPrefix)) {
    Write-Host "ERROR: Third-party dependencies not found at: $ThirdPartyPrefix" -ForegroundColor Red
    Write-Host "Please build rl-3rdparty first using build-3rdparty.ps1" -ForegroundColor Yellow
    Write-Host "Or specify a custom path using -ThirdPartyPrefix parameter" -ForegroundColor Yellow
    exit 1
}
Write-Host "Found third-party dependencies at: $ThirdPartyPrefix" -ForegroundColor Green
Write-Host ""

# Determine Visual Studio generator
$generator = "Visual Studio $VisualStudioVersion 2022"
if ($VisualStudioVersion -eq "16") {
    $generator = "Visual Studio 16 2019"
}
elseif ($VisualStudioVersion -eq "15") {
    $generator = "Visual Studio 15 2017"
}

Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Generator: $generator" -ForegroundColor White
Write-Host "  Architecture: $Architecture" -ForegroundColor White
Write-Host "  Configuration: $Config" -ForegroundColor White
Write-Host "  Library Type: $(if ($BuildStatic) { 'Static' } else { 'Shared' })" -ForegroundColor White
Write-Host "  Install Prefix: $InstallPrefix" -ForegroundColor White
Write-Host "  Third-Party Prefix: $ThirdPartyPrefix" -ForegroundColor White
Write-Host "  Parallel Jobs: $(if ($ParallelJobs -eq 0) { 'All available' } else { $ParallelJobs })" -ForegroundColor White
Write-Host "  Clean Previous: $(if ($Clean) { 'Yes' } else { 'No' })" -ForegroundColor White
Write-Host "  Build Demos: $BuildDemos" -ForegroundColor White
Write-Host "  Build Extras: $BuildExtras" -ForegroundColor White
Write-Host "  Build Math: $BuildMath" -ForegroundColor White
Write-Host "  Build Tests: $BuildTests" -ForegroundColor White
Write-Host "  Build Util: $BuildUtil" -ForegroundColor White
Write-Host "  Build XML: $BuildXml" -ForegroundColor White
Write-Host "  Build Documentation: $BuildDocumentation" -ForegroundColor White
Write-Host ""

# Create build directory
$buildDir = Join-Path $RLRoot "build"
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
        "-DBUILD_SHARED_LIBS=$(if ($BuildStatic) { 'OFF' } else { 'ON' })"
        "-DRL_BUILD_DEMOS=$(if ($BuildDemos) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_EXTRAS=$(if ($BuildExtras) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_MATH=$(if ($BuildMath) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_TESTS=$(if ($BuildTests) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_UTIL=$(if ($BuildUtil) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_XML=$(if ($BuildXml) { 'ON' } else { 'OFF' })"
        "-DRL_BUILD_DOCUMENTATION=$(if ($BuildDocumentation) { 'ON' } else { 'OFF' })"
    )
    
    Write-Host "Running: cmake $($cmakeArgs -join ' ')" -ForegroundColor Gray
    
    # Temporarily change error action to continue to capture full CMake output
    $oldErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    
    # Capture CMake output
    $cmakeOutput = & cmake @cmakeArgs 2>&1
    $cmakeOutput | ForEach-Object { Write-Host $_ }
    
    # Restore error action
    $ErrorActionPreference = $oldErrorAction
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "" -ForegroundColor Red
        Write-Host "ERROR: CMake configuration failed!" -ForegroundColor Red
        Write-Host "Full CMake error output:" -ForegroundColor Yellow
        $cmakeOutput | Select-Object -Last 30 | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
        if ($SkipTranscript) {
            Write-Host "See batch log file in: $logDir" -ForegroundColor Yellow
        }
        else {
            Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
        }
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
        }
        else {
            $buildArgs += "--parallel"
        }
        
        Write-Host "Running: cmake $($buildArgs -join ' ')" -ForegroundColor Gray
        & cmake @buildArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed!" -ForegroundColor Red
            if ($SkipTranscript) {
                Write-Host "See batch log file in: $logDir" -ForegroundColor Yellow
            }
            else {
                Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
            }
            exit 1
        }
        
        Write-Host "Build successful!" -ForegroundColor Green
        Write-Host ""
        
        # Build documentation if requested
        if ($BuildDocumentation) {
            Write-Host "Building documentation..." -ForegroundColor Yellow
            $docArgs = @(
                "--build", "."
                "--config", $Config
                "--target", "doc"
            )
            
            Write-Host "Running: cmake $($docArgs -join ' ')" -ForegroundColor Gray
            $docOutput = & cmake @docArgs 2>&1
            $docOutput | ForEach-Object { Write-Host $_ }
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "WARNING: Documentation build failed!" -ForegroundColor Yellow
                Write-Host "Make sure Doxygen is installed and available in PATH." -ForegroundColor Yellow
                Write-Host "Documentation will not be available, but the library build was successful." -ForegroundColor Yellow
                if ($SkipTranscript) {
                    Write-Host "See batch log file in: $logDir" -ForegroundColor Yellow
                }
                else {
                    Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "Documentation build successful!" -ForegroundColor Green
                $docHtmlPath = Join-Path $buildDir "doc\html\index.html"
                if (Test-Path $docHtmlPath) {
                    Write-Host "Documentation available at: $docHtmlPath" -ForegroundColor Green
                }
                Write-Host ""
            }
        }
    }
    else {
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
            if ($SkipTranscript) {
                Write-Host "See batch log file in: $logDir" -ForegroundColor Yellow
            }
            else {
                Write-Host "See log file for details: $logFile" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Installation successful!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Robotics Library installed to: $InstallPrefix" -ForegroundColor Green
        }
    }
    else {
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
    elseif ($SkipTranscript) {
        Write-Host "Build log saved to batch log file in: $logDir" -ForegroundColor Gray
        Write-Host ""
    }
    
}
finally {
    Pop-Location
    if ($transcriptStarted) {
        Stop-Transcript | Out-Null
    }
}
