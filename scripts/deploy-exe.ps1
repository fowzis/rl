# Robotics Library - Full Install Copy Script
# This script copies all executables and their dependencies to a single folder
# for easy distribution and standalone execution.

param(
    [string]$SourceRL = "",
    [string]$Source3rdParty = "",
    [string]$OutputDir = "deployment\exe",
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
Write-Host "Robotics Library Full Install Copy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define source directories
$RLBinDir = Join-Path $SourceRL "install\bin"
$RL3rdPartyBinDir = Join-Path $Source3rdParty "install\bin"
$RLBuildBinDir = Join-Path $SourceRL "build\bin\Release"

# Create output directory
$FullInstallDir = Join-Path $SourceRL $OutputDir
if (Test-Path $FullInstallDir) {
    Write-Host "Removing existing deployment directory..." -ForegroundColor Yellow
    Remove-Item -Path $FullInstallDir -Recurse -Force
}
New-Item -ItemType Directory -Path $FullInstallDir -Force | Out-Null
Write-Host "Created output directory: $FullInstallDir" -ForegroundColor Green
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
        Copy-Item -Path $SourcePath -Destination $DestPath -Force
        Write-Host "  [OK] $Description" -ForegroundColor Green
        return $true
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
        [string]$DestDir = $FullInstallDir
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
            Write-Host "  [ERROR] Failed to copy $($file.Name): $_" -ForegroundColor Red
        }
    }
    if ($count -gt 0) {
        Write-Host "  [OK] Copied $count $Description" -ForegroundColor Green
    }
    return $count
}

Write-Host "Step 1: Copying Robotics Library executables..." -ForegroundColor Cyan
$exeCount = 0

# Copy executables from install/bin
if (Test-Path $RLBinDir) {
    $exeCount += Copy-AllFiles -SourceDir $RLBinDir -Pattern "*.exe" -Description "executables from install/bin"
}

# Copy executables from build/bin/Release (in case some weren't installed)
if (Test-Path $RLBuildBinDir) {
    $buildExes = Get-ChildItem -Path $RLBuildBinDir -Filter "*.exe" -ErrorAction SilentlyContinue
    foreach ($exe in $buildExes) {
        $destPath = Join-Path $FullInstallDir $exe.Name
        if (-not (Test-Path $destPath)) {
            Copy-Item -Path $exe.FullName -Destination $destPath -Force
            $exeCount++
            Write-Host "  [OK] Copied $($exe.Name) from build directory" -ForegroundColor Green
        } else {
            # Update if build version is newer
            $buildTime = (Get-Item $exe.FullName).LastWriteTime
            $destTime = (Get-Item $destPath).LastWriteTime
            if ($buildTime -gt $destTime) {
                Copy-Item -Path $exe.FullName -Destination $destPath -Force
                Write-Host "  [OK] Updated $($exe.Name) from build directory" -ForegroundColor Green
            }
        }
    }
}

Write-Host "  Total executables: $exeCount" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 2: Copying Robotics Library DLLs..." -ForegroundColor Cyan
$dllCount = 0

# Copy RL core DLLs
if (Test-Path $RLBinDir) {
    $dllCount += Copy-AllFiles -SourceDir $RLBinDir -Pattern "*.dll" -Description "RL DLLs"
}

Write-Host ""

Write-Host "Step 3: Copying MSVC Runtime DLLs..." -ForegroundColor Cyan
# MSVC Runtime DLLs (already in RL install/bin, but ensure they're copied)
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
    $destPath = Join-Path $FullInstallDir $dll
    if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "MSVC Runtime: $dll") {
        $dllCount++
    }
}

Write-Host ""

Write-Host "Step 4: Copying Third-Party DLLs..." -ForegroundColor Cyan
if (Test-Path $RL3rdPartyBinDir) {
    # Copy all DLLs from third-party install
    $dllCount += Copy-AllFiles -SourceDir $RL3rdPartyBinDir -Pattern "*.dll" -Description "third-party DLLs"
    
    # Also copy any executables that might be needed
    Copy-AllFiles -SourceDir $RL3rdPartyBinDir -Pattern "*.exe" -Description "third-party executables"
} else {
    Write-Host "  [ERROR] Third-party bin directory not found: $RL3rdPartyBinDir" -ForegroundColor Red
}

Write-Host ""

Write-Host "Step 5: Detecting and copying Qt DLLs..." -ForegroundColor Cyan

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

# Auto-include Qt if SoQt needs it, or if explicitly requested
$shouldCopyQt = $IncludeQt -or $QtPath -or $needsQt5 -or $needsQt6

if ($shouldCopyQt) {
    if ($QtPath) {
        $QtBinDir = Join-Path $QtPath "bin"
    } else {
        # Try to find Qt in common locations
        $possibleQtPaths = @(
            "C:\Qt",
            "C:\Qt5",
            "C:\Qt6",
            "${env:ProgramFiles}\Qt",
            "${env:ProgramFiles(x86)}\Qt"
        )
        
        $QtBinDir = $null
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
                            $selectedCompiler = if ($msvcCompiler) { $msvcCompiler } else { $compilers[0] }
                            
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
    
    if ($QtBinDir -and (Test-Path $QtBinDir)) {
        # Determine which Qt version to copy based on what SoQt needs
        $requiredQtDlls = @()
        
        if ($needsQt5) {
            Write-Host "  Copying Qt5 DLLs..." -ForegroundColor Cyan
            # Core Qt5 DLLs required by SoQt
            $requiredQtDlls += @(
                "Qt5Core.dll",
                "Qt5Gui.dll",
                "Qt5OpenGL.dll",
                "Qt5PrintSupport.dll",
                "Qt5Widgets.dll"
            )
            
            # Additional Qt5 modules used by RL executables
            # rlSimulator requires Qt5Network
            $requiredQtDlls += @(
                "Qt5Network.dll"
            )
        }
        
        if ($needsQt6) {
            Write-Host "  Copying Qt6 DLLs..." -ForegroundColor Cyan
            $requiredQtDlls += @(
                "Qt6Core.dll",
                "Qt6Gui.dll",
                "Qt6OpenGL.dll",
                "Qt6PrintSupport.dll",
                "Qt6Widgets.dll",
                "Qt6Network.dll"
            )
        }
        
        # If neither was detected but Qt was requested, try both
        if (-not $needsQt5 -and -not $needsQt6 -and ($IncludeQt -or $QtPath)) {
            Write-Host "  Qt version not detected, trying Qt5 first..." -ForegroundColor Yellow
            $requiredQtDlls = @(
                "Qt5Core.dll",
                "Qt5Gui.dll",
                "Qt5OpenGL.dll",
                "Qt5PrintSupport.dll",
                "Qt5Widgets.dll",
                "Qt5Network.dll"
            )
        }
        
        $qtCopied = 0
        foreach ($dll in $requiredQtDlls) {
            $sourcePath = Join-Path $QtBinDir $dll
            $destPath = Join-Path $FullInstallDir $dll
            if (Copy-IfExists -SourcePath $sourcePath -DestPath $destPath -Description "Qt: $dll") {
                $qtCopied++
                $dllCount++
            }
        }
        
        if ($qtCopied -eq 0) {
            Write-Host "  [WARNING] No Qt DLLs found. GUI applications may not work." -ForegroundColor Yellow
        } else {
            Write-Host "  [OK] Copied $qtCopied Qt DLLs" -ForegroundColor Green
            
            # Copy Qt platform plugins (required for GUI applications)
            $pluginsDir = Join-Path $QtBinDir "..\plugins\platforms"
            if (Test-Path $pluginsDir) {
                $pluginsDest = Join-Path $FullInstallDir "platforms"
                if (-not (Test-Path $pluginsDest)) {
                    New-Item -ItemType Directory -Path $pluginsDest -Force | Out-Null
                }
                $pluginFiles = Get-ChildItem -Path "$pluginsDir\*.dll" -ErrorAction SilentlyContinue
                foreach ($plugin in $pluginFiles) {
                    Copy-Item -Path $plugin.FullName -Destination $pluginsDest -Force -ErrorAction SilentlyContinue
                }
                if ($pluginFiles) {
                    Write-Host "  [OK] Copied $($pluginFiles.Count) Qt platform plugin(s)" -ForegroundColor Green
                }
            }
            
            # Copy ALL Qt DLLs to ensure all dependencies are met
            # This is safer than trying to determine which ones are needed
            Write-Host "  Copying all Qt DLLs (to ensure all dependencies are met)..." -ForegroundColor Cyan
            $allQtDlls = Get-ChildItem -Path $QtBinDir -Filter "Qt5*.dll" -ErrorAction SilentlyContinue
            if ($needsQt6) {
                $allQtDlls += Get-ChildItem -Path $QtBinDir -Filter "Qt6*.dll" -ErrorAction SilentlyContinue
            }
            $additionalCount = 0
            foreach ($dll in $allQtDlls) {
                $destPath = Join-Path $FullInstallDir $dll.Name
                if (-not (Test-Path $destPath)) {
                    try {
                        Copy-Item -Path $dll.FullName -Destination $destPath -Force -ErrorAction Stop
                        $additionalCount++
                    } catch {
                        Write-Host "    [WARNING] Failed to copy $($dll.Name): $_" -ForegroundColor Yellow
                    }
                }
            }
            if ($additionalCount -gt 0) {
                Write-Host "  [OK] Copied $additionalCount additional Qt DLLs" -ForegroundColor Green
                $dllCount += $additionalCount
            }
        }
    } else {
        if ($needsQt5 -or $needsQt6) {
            Write-Host "  [ERROR] Qt directory not found but is required!" -ForegroundColor Red
            Write-Host "    SoQt was built with Qt, but Qt DLLs cannot be found." -ForegroundColor Red
            Write-Host "    Please:" -ForegroundColor Yellow
            Write-Host "    1. Install Qt5 or Qt6" -ForegroundColor Yellow
            Write-Host "    2. Use -QtPath parameter to specify Qt installation path" -ForegroundColor Yellow
            Write-Host "    3. Or use -IncludeQt to enable auto-detection" -ForegroundColor Yellow
        } else {
            Write-Host "  [WARNING] Qt directory not found. GUI applications may not work." -ForegroundColor Yellow
            Write-Host "    Use -QtPath parameter to specify Qt installation path" -ForegroundColor Yellow
        }
    }
} else {
    if ($needsQt5 -or $needsQt6) {
        Write-Host "  [WARNING] Qt is required but auto-copy is disabled!" -ForegroundColor Yellow
        Write-Host "    Use -IncludeQt to automatically copy Qt DLLs" -ForegroundColor Yellow
    } else {
        Write-Host "  Skipped (use -IncludeQt to copy Qt DLLs)" -ForegroundColor Gray
    }
}

Write-Host ""

Write-Host "Step 6: Copying OpenGL DLL (system check)..." -ForegroundColor Cyan
# OpenGL32.dll is usually in System32, but we note it
$openglPath = Join-Path ${env:SystemRoot} "System32\OpenGL32.dll"
if (Test-Path $openglPath) {
    Write-Host "  [OK] OpenGL32.dll found in system (not copied - system library)" -ForegroundColor Green
} else {
    Write-Host "  [WARNING] OpenGL32.dll not found - graphics may not work" -ForegroundColor Yellow
}

Write-Host ""

Write-Host "Step 7: Creating README file..." -ForegroundColor Cyan
$readmePath = Join-Path $FullInstallDir "README.txt"
$readmeContent = @"
Robotics Library - Full Install Package
========================================

This directory contains all executables and dependencies needed to run
Robotics Library applications standalone.

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Source: $SourceRL
Version: 0.7.0

Contents:
---------
- Executables: $exeCount files
- DLLs: $dllCount+ files

Usage:
------
All executables in this directory can be run directly without additional
PATH configuration. All dependencies are included in this folder.

GUI Applications:
-----------------
The following applications require Qt and OpenGL:
- rlPlanDemo.exe
- rlViewDemo.exe
- rlCollisionDemo.exe
- rlSimulator.exe
- rlCoachKin.exe
- rlCoachMdl.exe
- wrlview.exe

If Qt DLLs are missing, install Qt5 or Qt6 and ensure the DLLs are in
this directory or in the system PATH.

System Requirements:
--------------------
- Windows 10 or later
- OpenGL drivers (usually pre-installed)
- Visual C++ Redistributable 2015-2022 (if DLLs are missing)

For more information, see:
- BUILD_REPORT.md
- DEPENDENCIES.md

"@

Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
Write-Host "  [OK] Created README.txt" -ForegroundColor Green

Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Copy Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output directory: $FullInstallDir" -ForegroundColor Cyan
Write-Host "Executables: $exeCount" -ForegroundColor Cyan
Write-Host "DLLs: $dllCount+" -ForegroundColor Cyan
Write-Host ""
Write-Host "All files are ready for distribution!" -ForegroundColor Green
Write-Host ""

# List all executables
Write-Host "Executables in deployment/exe:" -ForegroundColor Yellow
$exes = Get-ChildItem -Path $FullInstallDir -Filter "*.exe" | Sort-Object Name
foreach ($exe in $exes) {
    Write-Host "  - $($exe.Name)" -ForegroundColor Gray
}
