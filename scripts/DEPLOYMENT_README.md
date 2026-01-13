# Full Install Copy Script - Usage Guide

## Overview

The `deploy-exe.ps1` script creates a standalone distribution package by copying all Robotics Library executables and their dependencies into a single `deployment/exe` folder. This allows you to distribute or run the executables without requiring PATH configuration or separate dependency installation.

## Quick Start

### Option 1: Run the batch file (easiest)

```batch
deploy-exe.bat
```

### Option 2: Run PowerShell script directly

```powershell
.\deploy-exe.ps1
```

### Option 3: Run with custom parameters

```powershell
.\deploy-exe.ps1 -SourceRL "C:\Path\To\rl" -Source3rdParty "C:\Path\To\rl-3rdparty" -OutputDir "myinstall"
```

## Parameters

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `-SourceRL` | Path to RL source directory | `C:\Tools\RoboticLibrary\GitHub\rl` |
| `-Source3rdParty` | Path to 3rdparty directory | `C:\Tools\RoboticLibrary\GitHub\rl-3rdparty` |
| `-OutputDir` | Output folder name (relative to SourceRL) | `deployment\exe` |
| `-IncludeQt` | Include Qt DLLs (auto-detects Qt) | `$false` |
| `-QtPath` | Explicit Qt installation path | (auto-detect) |

## Examples

### Basic usage (default paths)

```powershell
.\deploy-exe.ps1
```

### Include Qt DLLs

```powershell
.\deploy-exe.ps1 -IncludeQt
```

### Specify Qt path explicitly

```powershell
.\deploy-exe.ps1 -IncludeQt -QtPath "C:\Qt\6.5.0\msvc2019_64"
```

### Custom output directory

```powershell
.\deploy-exe.ps1 -OutputDir "distribution"
```

### Full custom setup

```powershell
.\deploy-exe.ps1 `
    -SourceRL "D:\MyProjects\rl" `
    -Source3rdParty "D:\MyProjects\rl-3rdparty" `
    -OutputDir "release" `
    -IncludeQt `
    -QtPath "C:\Qt\6.5.0\msvc2019_64"
```

## What Gets Copied

### Executables

- All `.exe` files from `install/bin/`
- All `.exe` files from `build/bin/Release/` (if not already in install)

### DLLs

- **RL Core DLLs:** `rlkin.dll`, `rlhal.dll`, `rlmdl.dll`, `rlsg.dll`, `rlplan.dll`
- **MSVC Runtime:** All Visual C++ runtime DLLs
- **Third-Party DLLs:** All DLLs from `rl-3rdparty/install/bin/`
  - XML: `libxml2.dll`, `libxslt.dll`, `libexslt.dll`
  - Encoding: `libiconv.dll`, `libcharset.dll`
  - Scene Graph: `Coin4.dll`, `SoQt1.dll`, `simage1.dll`
  - Collision: `ccd.dll`, `fcl.dll`, `ode_double.dll`, `solid3.dll`
  - Physics: Bullet DLLs (if built)
  - Optimization: `nlopt.dll`
  - Boost: All Boost DLLs (if using DLL versions)

### Qt DLLs (if `-IncludeQt` is used)

- `Qt5Core.dll` / `Qt6Core.dll`
- `Qt5Gui.dll` / `Qt6Gui.dll`
- `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
- `Qt5PrintSupport.dll` / `Qt6PrintSupport.dll`
- `Qt5Widgets.dll` / `Qt6Widgets.dll`
- Qt platform plugins (in `platforms/` subdirectory)

## Output Structure

```text
deployment/exe/
├── README.txt                    # Information about the package
├── *.exe                         # All executables
├── *.dll                         # All DLLs
└── platforms/                    # Qt platform plugins (if Qt included)
    └── qwindows.dll
```

## Requirements

- PowerShell 3.0 or later
- Write permissions to create the output directory
- Source directories must exist and contain built files

## Notes

### Qt Detection

- If `-IncludeQt` is used, the script attempts to auto-detect Qt in common locations
- If auto-detection fails, use `-QtPath` to specify the Qt installation directory
- Qt is only needed for GUI applications (rlPlanDemo, rlViewDemo, etc.)

### OpenGL

- `OpenGL32.dll` is a system library and is not copied
- It should be available on all Windows systems with graphics drivers
- The script verifies its presence but doesn't copy it

### System Libraries

- Some DLLs (like `OpenGL32.dll`) are system libraries and are not copied
- These are typically pre-installed on Windows systems

## Troubleshooting

### "Access Denied" Error

- Run PowerShell as Administrator
- Ensure no files in the output directory are in use
- Close any running executables from the output directory

### Missing Qt DLLs

- Use `-IncludeQt` parameter
- Or manually specify Qt path with `-QtPath`
- Or copy Qt DLLs manually to the output directory

### Missing DLLs at Runtime

- Check that all third-party DLLs were copied
- Verify MSVC Runtime DLLs are present
- Use Dependency Walker to identify missing DLLs

### Executables Don't Run

- Ensure all DLLs are in the same directory as executables
- Check that MSVC Runtime is installed or DLLs are present
- Verify Qt DLLs are present for GUI applications

## Distribution

The `deployment/exe` folder can be:

- Zipped and distributed
- Copied to another machine
- Run directly without installation
- Added to PATH (though not necessary)

All executables in the folder are self-contained and can run independently.

## Script Output

The script provides detailed progress information:

- ✓ Green checkmarks for successful operations
- ✗ Red X for missing files
- ⚠ Yellow warnings for optional components
- Summary statistics at the end

## Example Output

```text
========================================
Robotics Library Full Install Copy
========================================

Created output directory: C:\Tools\RoboticLibrary\GitHub\rl\deployment\exe

Step 1: Copying Robotics Library executables...
  ✓ Copied 40 executables from install/bin
  Total executables: 40

Step 2: Copying Robotics Library DLLs...
  ✓ Copied 5 RL DLLs

Step 3: Copying MSVC Runtime DLLs...
  ✓ MSVC Runtime: vcruntime140.dll
  ...

Step 4: Copying Third-Party DLLs...
  ✓ Copied 50+ third-party DLLs

Step 5: Copying Qt DLLs (if requested)...
  ...

========================================
Copy Complete!
========================================
```

---

**Last Updated:** January 13, 2025
