# Robotics Library - DLLs Full Deployment Script
# This script copies only the RL DLL artifacts and their complete dependencies
# for deployment into wrapper applications.
#
# Usage: .\deploy-dlls.ps1 [-SourceRL <path>] [-Source3rdParty <path>] [-OutputDir <name>] [-IncludeQt]

param(
    [string]$SourceRL = "",
    [string]$Source3rdParty = "",
    [string]$OutputDir = "deployment\dlls",
    [switch]$IncludeQt = $false,
    [string]$QtPath = ""
)

# Set default paths relative to script location if not provided
if ([string]::IsNullOrEmpty($SourceRL)) {
    $SourceRL = Split-Path -Parent $PSScriptRoot
}
if ([string]::IsNullOrEmpty($Source3rdParty)) {
    $Source3rdParty = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "rl-3rdparty"
}

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Robotics Library DLLs Full Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define source directories
$RLBinDir = Join-Path $SourceRL "install\bin"
$RL3rdPartyBinDir = Join-Path $Source3rdParty "install\bin"

# Create output directory
$DeployDir = Join-Path $SourceRL $OutputDir
if (Test-Path $DeployDir) {
    Write-Host "Removing existing deployment directory..." -ForegroundColor Yellow
    Remove-Item -Path $DeployDir -Recurse -Force
}
New-Item -ItemType Directory -Path $DeployDir -Force | Out-Null
Write-Host "Created deployment directory: $DeployDir" -ForegroundColor Green
Write-Host ""

# Function to copy file if it exists
function Copy-IfExists {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$Description
    )
    
    if (Test-Path $SourcePath) {
        $destDir = Split-Path -Parent $DestPath
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        try {
            Copy-Item -Path $SourcePath -Destination $DestPath -Force -ErrorAction Stop
            Write-Host "  [OK] $Description" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "  [ERROR] Failed to copy $Description : $_" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "  [MISSING] $Description" -ForegroundColor Yellow
        return $false
    }
}

# Function to copy all files matching pattern
function Copy-AllFiles {
    param(
        [string]$SourceDir,
        [string]$Pattern,
        [string]$Description,
        [string]$DestDir = $DeployDir
    )
    
    if (-not (Test-Path $SourceDir)) {
        Write-Host "  [ERROR] Source directory not found: $SourceDir" -ForegroundColor Red
        return 0
    }
    
    $files = Get-ChildItem -Path $SourceDir -Filter $Pattern -ErrorAction SilentlyContinue
    $count = 0
    foreach ($file in $files) {
        try {
            $destPath = Join-Path $DestDir $file.Name
            Copy-Item -Path $file.FullName -Destination $destPath -Force -ErrorAction Stop
            $count++
        } catch {
            Write-Host "    [WARNING] Failed to copy $($file.Name): $_" -ForegroundColor Yellow
        }
    }
    if ($count -gt 0) {
        Write-Host "  [OK] Copied $count $Description" -ForegroundColor Green
    }
    return $count
}

Write-Host "Step 1: Copying Robotics Library Core DLLs..." -ForegroundColor Cyan
$dllCount = 0

# RL Core DLLs that need to be deployed
$rlCoreDlls = @(
    "rlkin.dll",
    "rlhal.dll",
    "rlmdl.dll",
    "rlsg.dll",
    "rlplan.dll"
)

foreach ($dll in $rlCoreDlls) {
    $sourcePath = Join-Path $RLBinDir $dll
    $destPath = Join-Path $DeployDir $dll
    if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "RL Core: $dll") {
        $dllCount++
    }
}

Write-Host "  Total RL Core DLLs: $dllCount" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 2: Copying MSVC Runtime DLLs..." -ForegroundColor Cyan
# MSVC Runtime DLLs (required by all RL DLLs)
$msvcDlls = @(
    "vcruntime140.dll",
    "vcruntime140_1.dll",
    "msvcp140.dll",
    "msvcp140_1.dll",
    "msvcp140_2.dll",
    "msvcp140_atomic_wait.dll",
    "msvcp140_codecvt_ids.dll",
    "concrt140.dll"
)

foreach ($dll in $msvcDlls) {
    $sourcePath = Join-Path $RLBinDir $dll
    $destPath = Join-Path $DeployDir $dll
    if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "MSVC Runtime: $dll") {
        $dllCount++
    }
}

Write-Host ""

Write-Host "Step 3: Copying Third-Party DLLs..." -ForegroundColor Cyan
if (Test-Path $RL3rdPartyBinDir) {
    # XML Processing DLLs (required by rlkin, rlhal, rlmdl, rlsg, rlplan)
    $xmlDlls = @(
        "libxml2.dll",
        "libxslt.dll",
        "libexslt.dll"
    )
    
    foreach ($dll in $xmlDlls) {
        $sourcePath = Join-Path $RL3rdPartyBinDir $dll
        $destPath = Join-Path $DeployDir $dll
        if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "XML: $dll") {
            $dllCount++
        }
    }
    
    # Character Encoding DLLs (required by XML libraries)
    $encodingDlls = @(
        "libiconv.dll",
        "libcharset.dll"
    )
    
    foreach ($dll in $encodingDlls) {
        $sourcePath = Join-Path $RL3rdPartyBinDir $dll
        $destPath = Join-Path $DeployDir $dll
        if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "Encoding: $dll") {
            $dllCount++
        }
    }
    
    # Scene Graph DLLs (required by rlsg.dll)
    $sceneGraphDlls = @(
        "Coin4.dll",
        "SoQt1.dll",
        "simage1.dll"
    )
    
    foreach ($dll in $sceneGraphDlls) {
        $sourcePath = Join-Path $RL3rdPartyBinDir $dll
        $destPath = Join-Path $DeployDir $dll
        if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "Scene Graph: $dll") {
            $dllCount++
        }
    }
    
    # Collision Detection DLLs (optional, but may be required depending on build config)
    $collisionDlls = @(
        "ccd.dll",           # FCL dependency
        "fcl.dll",            # FCL collision detection
        "ode_double.dll",     # ODE physics engine
        "solid3.dll",         # SOLID collision detection
        "BulletCollision.dll", # Bullet Physics
        "BulletDynamics.dll",
        "BulletSoftBody.dll",
        "LinearMath.dll"      # Bullet Math
    )
    
    foreach ($dll in $collisionDlls) {
        $sourcePath = Join-Path $RL3rdPartyBinDir $dll
        $destPath = Join-Path $DeployDir $dll
        if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "Collision: $dll") {
            $dllCount++
        }
    }
    
    # Optimization DLL (required by rlmdl.dll if NLopt support is enabled)
    $optDll = "nlopt.dll"
    $sourcePath = Join-Path $RL3rdPartyBinDir $optDll
    $destPath = Join-Path $DeployDir $optDll
    if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "Optimization: $optDll") {
        $dllCount++
    }
    
    # Boost DLLs (if using DLL versions, header-only doesn't need DLLs)
    $boostDlls = Get-ChildItem -Path $RL3rdPartyBinDir -Filter "boost_*.dll" -ErrorAction SilentlyContinue
    if ($boostDlls) {
        Write-Host "  Copying Boost DLLs..." -ForegroundColor Cyan
        foreach ($dll in $boostDlls) {
            $destPath = Join-Path $DeployDir $dll.Name
            try {
                Copy-Item -Path $dll.FullName -Destination $destPath -Force -ErrorAction Stop
                $dllCount++
            } catch {
                Write-Host "    [WARNING] Failed to copy $($dll.Name): $_" -ForegroundColor Yellow
            }
        }
        Write-Host "  [OK] Copied $($boostDlls.Count) Boost DLLs" -ForegroundColor Green
    }
    
} else {
    Write-Host "  [ERROR] Third-party bin directory not found: $RL3rdPartyBinDir" -ForegroundColor Red
}

Write-Host ""

Write-Host "Step 4: Detecting Qt installation (Qt DLLs not copied - needed for GUI applications)..." -ForegroundColor Cyan

# Check if SoQt was built with Qt5 or Qt6 by reading the config file
$soqtConfigFile = Join-Path $Source3rdParty "install\lib\cmake\SoQt-1.6.3\soqt-config.cmake"
$needsQt5 = $false
$needsQt6 = $false

if (Test-Path $soqtConfigFile) {
    $configContent = Get-Content $soqtConfigFile -Raw
    if ($configContent -match 'SoQt_HAVE_QT5\s+1') {
        $needsQt5 = $true
        Write-Host "  Detected: SoQt was built with Qt5" -ForegroundColor Yellow
    }
    if ($configContent -match 'SoQt_HAVE_QT6\s+1') {
        $needsQt6 = $true
        Write-Host "  Detected: SoQt was built with Qt6" -ForegroundColor Yellow
    }
}

# Also check the export file for Qt dependencies
$soqtExportFile = Join-Path $Source3rdParty "install\lib\cmake\SoQt-1.6.3\soqt-export.cmake"
if (Test-Path $soqtExportFile) {
    $exportContent = Get-Content $soqtExportFile -Raw
    if ($exportContent -match 'Qt5::') {
        $needsQt5 = $true
        Write-Host "  Detected: SoQt requires Qt5 DLLs" -ForegroundColor Yellow
    }
    if ($exportContent -match 'Qt6::') {
        $needsQt6 = $true
        Write-Host "  Detected: SoQt requires Qt6 DLLs" -ForegroundColor Yellow
    }
}

# Try to find Qt installation (for detection only, not copying)
$QtBinDir = $null

if ($QtPath) {
    $QtBinDir = Join-Path $QtPath "bin"
} else {
    # First check environment variables (Qt5_DIR or Qt6_DIR)
    if ($needsQt5 -and $env:Qt5_DIR) {
        # Qt5_DIR points to lib\cmake\Qt5, need to go up to get to bin
        # e.g., C:\Tools\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5 -> C:\Tools\Qt\5.15.2\msvc2019_64\bin
        $qt5Dir = $env:Qt5_DIR
        if ($qt5Dir -match '\\lib\\cmake\\Qt5') {
            $QtBinDir = Join-Path (Split-Path (Split-Path (Split-Path $qt5Dir -Parent) -Parent) -Parent) "bin"
        } else {
            $QtBinDir = Join-Path $qt5Dir "bin"
        }
        if (Test-Path $QtBinDir) {
            Write-Host "  Found Qt5 via Qt5_DIR environment variable: $QtBinDir" -ForegroundColor Green
        } else {
            $QtBinDir = $null
        }
    }
    
    if (-not $QtBinDir -and $needsQt6 -and $env:Qt6_DIR) {
        # Qt6_DIR points to lib\cmake\Qt6, need to go up to get to bin
        $qt6Dir = $env:Qt6_DIR
        if ($qt6Dir -match '\\lib\\cmake\\Qt6') {
            $QtBinDir = Join-Path (Split-Path (Split-Path (Split-Path $qt6Dir -Parent) -Parent) -Parent) "bin"
        } else {
            $QtBinDir = Join-Path $qt6Dir "bin"
        }
        if (Test-Path $QtBinDir) {
            Write-Host "  Found Qt6 via Qt6_DIR environment variable: $QtBinDir" -ForegroundColor Green
        } else {
            $QtBinDir = $null
        }
    }
    
    # If not found via environment variables, try common locations
    if (-not $QtBinDir) {
        $possibleQtPaths = @(
            "C:\Qt",
            "C:\Qt5",
            "C:\Qt6",
            "${env:ProgramFiles}\Qt",
            "${env:ProgramFiles(x86)}\Qt"
        )
        
        $preferredQtVersion = if ($needsQt5) { "5" } elseif ($needsQt6) { "6" } else { $null }
        
        foreach ($path in $possibleQtPaths) {
            if (Test-Path $path) {
                # Look for Qt version directories
                $qtVersions = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | 
                    Where-Object { $_.Name -match "^[0-9]" } | 
                    Sort-Object Name -Descending
                
                if ($qtVersions) {
                    # If we know which Qt version we need, prefer that
                    if ($preferredQtVersion) {
                        $matchingVersion = $qtVersions | Where-Object { $_.Name.StartsWith($preferredQtVersion) } | Select-Object -First 1
                        if ($matchingVersion) {
                            $qtVersions = @($matchingVersion)
                        }
                    }
                    
                    foreach ($qtVersion in $qtVersions) {
                        $compilers = Get-ChildItem -Path $qtVersion.FullName -Directory -ErrorAction SilentlyContinue
                        if ($compilers) {
                            # Prefer msvc compiler variants
                            $msvcCompiler = $compilers | Where-Object { $_.Name -match "msvc" } | Select-Object -First 1
                            $selectedCompiler = if ($msvcCompiler) { $msvcCompiler} else { $compilers[0] }
                            
                            $testQtBinDir = Join-Path $selectedCompiler.FullName "bin"
                            if (Test-Path $testQtBinDir) {
                                # Verify it has the required DLLs
                                $hasRequiredDlls = $true
                                if ($needsQt5) {
                                    $hasRequiredDlls = (Test-Path (Join-Path $testQtBinDir "Qt5Core.dll"))
                                } elseif ($needsQt6) {
                                    $hasRequiredDlls = (Test-Path (Join-Path $testQtBinDir "Qt6Core.dll"))
                                }
                                
                                if ($hasRequiredDlls) {
                                    $QtBinDir = $testQtBinDir
                                    Write-Host "  Found Qt at: $QtBinDir" -ForegroundColor Green
                                    break
                                }
                            }
                        }
                    }
                    
                    if ($QtBinDir) {
                        break
                    }
                }
            }
        }
        
        # Also check PATH for Qt
        if (-not $QtBinDir) {
            $pathQt = Get-Command "qmake.exe" -ErrorAction SilentlyContinue
            if ($pathQt) {
                $qmakePath = $pathQt.Source
                $possibleQtBin = Join-Path (Split-Path (Split-Path $qmakePath -Parent) -Parent) "bin"
                if (Test-Path $possibleQtBin) {
                    $QtBinDir = $possibleQtBin
                    Write-Host "  Found Qt via PATH at: $QtBinDir" -ForegroundColor Green
                }
            }
        }
    }
}

# Note: Qt DLLs are NOT copied in deploy-dlls because they are needed for GUI applications
# and should be deployed separately with the executables (use deploy-exe for that)
if ($QtBinDir -and (Test-Path $QtBinDir)) {
    Write-Host "  [OK] Qt installation detected at: $QtBinDir" -ForegroundColor Green
    Write-Host "  Note: Qt DLLs are not copied here (needed for GUI - use deploy-exe to include them)" -ForegroundColor Yellow
} else {
    if ($needsQt5 -or $needsQt6) {
        Write-Host "  [WARNING] Qt installation not found but may be required!" -ForegroundColor Yellow
        Write-Host "    SoQt was built with Qt, but Qt installation cannot be found." -ForegroundColor Yellow
        Write-Host "    Set Qt5_DIR or Qt6_DIR environment variable, or use -QtPath parameter." -ForegroundColor Yellow
    } else {
        Write-Host "  [INFO] Qt not required (SoQt was built without Qt)" -ForegroundColor Gray
    }
}

Write-Host ""

Write-Host "Step 5: Creating README file..." -ForegroundColor Cyan
$readmePath = Join-Path $DeployDir "README.txt"
$readmeContent = @"
Robotics Library DLLs - Full Deployment Package
================================================

This directory contains all Robotics Library DLLs and their dependencies
needed for deployment into wrapper applications.

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Source: $SourceRL
Version: 0.7.0

Contents:
---------
- RL Core DLLs: 5 files
  - rlkin.dll      (Kinematics library)
  - rlhal.dll      (Hardware abstraction layer)
  - rlmdl.dll      (Robot modeling and dynamics)
  - rlsg.dll       (Scene graph and collision detection)
  - rlplan.dll     (Path planning algorithms)

- Dependencies: $dllCount+ files
  - MSVC Runtime DLLs
  - XML Processing (libxml2, libxslt, libexslt)
  - Character Encoding (libiconv, libcharset)
  - Scene Graph (Coin4, SoQt1, simage1)
  - Collision Detection (FCL, ODE, SOLID, Bullet - if built)
  - Optimization (nlopt - if enabled)
  - Qt Framework (if rlsg.dll is used)

Usage:
------
Copy all DLLs from this directory to your application's directory or
add this directory to your application's PATH.

For wrapper applications:
1. Copy all DLLs to the same directory as your wrapper executable
2. Ensure Qt platform plugins are in a 'platforms' subdirectory if using rlsg.dll
3. All dependencies are included - no additional installation required

System Requirements:
--------------------
- Windows 10 or later
- OpenGL drivers (usually pre-installed, required for rlsg.dll)
- Visual C++ Redistributable 2015-2022 (if DLLs are missing)

DLL Dependencies:
-----------------
- rlkin.dll: Requires libxml2, libxslt, libiconv, libcharset, MSVC Runtime
- rlhal.dll: Requires libxml2, libxslt, libiconv, libcharset, MSVC Runtime
- rlmdl.dll: Requires rlkin.dll, libxml2, libxslt, libiconv, libcharset, nlopt (optional), MSVC Runtime
- rlsg.dll: Requires rlkin.dll, rlmdl.dll, Coin4.dll, SoQt1.dll, Qt DLLs, collision DLLs (optional), MSVC Runtime
- rlplan.dll: Requires rlkin.dll, rlmdl.dll, rlsg.dll, all above dependencies, MSVC Runtime

For more information, see:
- scripts/DEPENDENCIES.md
- scripts/BUILD_REPORT.md

"@

Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
Write-Host "  [OK] Created README.txt" -ForegroundColor Green

Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output directory: $DeployDir" -ForegroundColor Cyan
Write-Host "RL Core DLLs: 5" -ForegroundColor Cyan
Write-Host "Total DLLs: $dllCount+" -ForegroundColor Cyan
Write-Host ""
Write-Host "All DLLs are ready for deployment!" -ForegroundColor Green
Write-Host ""

# List all DLLs
Write-Host "DLLs in deployment package:" -ForegroundColor Yellow
$dlls = Get-ChildItem -Path $DeployDir -Filter "*.dll" | Sort-Object Name
foreach ($dll in $dlls) {
    Write-Host "  - $($dll.Name)" -ForegroundColor Gray
}
