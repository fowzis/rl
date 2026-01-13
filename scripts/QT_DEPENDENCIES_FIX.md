# Qt Dependencies Fix

## Issue
The `rlViewDemo.exe` (and other GUI applications) were failing with:
```
The procedure entry point ?hitButton@QPushButton@@MEBA_NAEBVQPoint@@@Z 
could not be located in the dynamic link library SoQt1.dll
```

## Root Cause
SoQt1.dll was built against Qt5, but Qt5 DLLs were not being copied to the `fullinstall` directory automatically.

## Solution
The `deploy-exe.ps1` script has been updated to:

1. **Auto-detect Qt requirements**: Reads SoQt CMake config files to determine if Qt5 or Qt6 is needed
2. **Auto-locate Qt installation**: Searches common Qt installation paths
3. **Auto-copy Qt DLLs**: Automatically copies required Qt DLLs when SoQt is detected
4. **Copy Qt platform plugins**: Copies the `platforms` directory with `qwindows.dll` (required for Windows GUI)

## What Gets Copied

### Required Qt5 DLLs (when SoQt uses Qt5):
- `Qt5Core.dll` - Core Qt functionality
- `Qt5Gui.dll` - GUI framework
- `Qt5OpenGL.dll` - OpenGL integration
- `Qt5PrintSupport.dll` - Printing support (for rlPlanDemo)
- `Qt5Widgets.dll` - Widget library
- `Qt5Network.dll` - Network support (for rlSimulator, rlCoachKin, rlCoachMdl)

### Additional Qt DLLs:
All other Qt5*.dll files in the Qt bin directory are also copied to ensure complete dependency coverage.

### Additional Qt DLLs:
- All other Qt5*.dll files in the Qt bin directory (dependencies)
- Platform plugins (in `platforms/qwindows.dll`)

## Usage

The script now automatically detects and copies Qt DLLs. No special flags needed:

```powershell
.\deploy-exe.ps1
```

If Qt is not found automatically, you can specify the path:

```powershell
.\deploy-exe.ps1 -QtPath "C:\Qt\5.15.2\msvc2019_64"
```

## Verification

After running the script, verify Qt DLLs are present:

```powershell
Get-ChildItem fullinstall\Qt5*.dll
Get-ChildItem fullinstall\platforms\*.dll
```

## Testing

Test a GUI application:

```powershell
cd fullinstall
.\rlViewDemo.exe
```

If it runs without errors, the Qt dependencies are correctly installed.

## Notes

- The script detects Qt version from SoQt CMake config files
- The script automatically includes `Qt5Network.dll` which is required by:
  - `rlSimulator.exe`
  - `rlCoachKin.exe`
  - `rlCoachMdl.exe`
- All Qt5*.dll files are copied to ensure complete dependency coverage
- If Qt is not found, the script will warn but continue
- GUI applications will not work without Qt DLLs
- Platform plugins are essential for Windows GUI applications
- The script now copies ALL Qt DLLs from the Qt bin directory to avoid missing dependencies
