# RL Library Output Reference

## Quick Reference: Library Files Generated

This document provides a quick reference for the exact library files that are generated when building the Robotics Library.

## Windows Output (BUILD_SHARED_LIBS=ON)

### Release Build
```
build/src/rl/plan/Release/
  ├── rlplan.dll          # Main DLL
  ├── rlplan.lib          # Import library
  └── rlplan.pdb          # Debug symbols (if available)

build/src/rl/kin/Release/
  ├── rlkin.dll
  ├── rlkin.lib
  └── rlkin.pdb

build/src/rl/sg/Release/
  ├── rlsg.dll
  ├── rlsg.lib
  └── rlsg.pdb

build/src/rl/mdl/Release/
  ├── rlmdl.dll
  ├── rlmdl.lib
  └── rlmdl.pdb

build/src/rl/math/Release/
  ├── rlmath.dll          # Only if CMake < 3.0
  └── rlmath.lib

build/src/rl/util/Release/
  ├── rlutil.dll          # Only if CMake < 3.0
  └── rlutil.lib

build/src/rl/xml/Release/
  ├── rlxml.dll           # Only if CMake < 3.0
  └── rlxml.lib

build/src/rl/hal/Release/
  ├── rlhal.dll
  ├── rlhal.lib
  └── rlhal.pdb
```

### Debug Build
```
build/src/rl/plan/Debug/
  ├── rlpland.dll         # Debug DLL (note 'd' suffix)
  ├── rlpland.lib
  └── rlpland.pdb

build/src/rl/kin/Debug/
  ├── rlkind.dll
  ├── rlkind.lib
  └── rlkind.pdb

build/src/rl/sg/Debug/
  ├── rlsgd.dll
  ├── rlsgd.lib
  └── rlsgd.pdb
```

## Linux Output (BUILD_SHARED_LIBS=ON)

### Release Build
```
build/src/rl/plan/
  ├── librlplan.so.0.7.0  # Full version
  ├── librlplan.so.0      # Major version symlink
  └── librlplan.so        # Unversioned symlink

build/src/rl/kin/
  ├── librlkin.so.0.7.0
  ├── librlkin.so.0
  └── librlkin.so

build/src/rl/sg/
  ├── librlsg.so.0.7.0
  ├── librlsg.so.0
  └── librlsg.so

build/src/rl/mdl/
  ├── librlmdl.so.0.7.0
  ├── librlmdl.so.0
  └── librlmdl.so

build/src/rl/math/
  └── librlmath.so.0.7.0  # Only if CMake < 3.0

build/src/rl/util/
  └── librlutil.so.0.7.0  # Only if CMake < 3.0

build/src/rl/xml/
  └── librlxml.so.0.7.0   # Only if CMake < 3.0

build/src/rl/hal/
  ├── librlhal.so.0.7.0
  ├── librlhal.so.0
  └── librlhal.so
```

## After Installation

### Windows Install Location
```
<install_prefix>/
  ├── bin/
  │   ├── rlplan.dll
  │   ├── rlkin.dll
  │   ├── rlsg.dll
  │   ├── rlmdl.dll
  │   ├── rlhal.dll
  │   └── [other DLLs]
  ├── lib/
  │   ├── rlplan.lib
  │   ├── rlkin.lib
  │   ├── rlsg.lib
  │   ├── rlmdl.lib
  │   ├── rlhal.lib
  │   └── [other LIBs]
  └── include/
      └── rl-0.7.0/
          └── rl/
              ├── plan/
              ├── kin/
              ├── sg/
              ├── mdl/
              ├── math/
              ├── util/
              ├── xml/
              └── hal/
```

### Linux Install Location
```
<install_prefix>/
  ├── lib/
  │   ├── librlplan.so.0.7.0
  │   ├── librlplan.so.0 -> librlplan.so.0.7.0
  │   ├── librlplan.so -> librlplan.so.0
  │   ├── librlkin.so.0.7.0
  │   ├── librlkin.so.0 -> librlkin.so.0.7.0
  │   ├── librlkin.so -> librlkin.so.0
  │   ├── librlsg.so.0.7.0
  │   ├── librlsg.so.0 -> librlsg.so.0.7.0
  │   ├── librlsg.so -> librlsg.so.0
  │   └── [other .so files]
  └── include/
      └── rl-0.7.0/
          └── rl/
              ├── plan/
              ├── kin/
              ├── sg/
              ├── mdl/
              ├── math/
              ├── util/
              ├── xml/
              └── hal/
```

## Dependencies Between Libraries

### Library Dependencies Graph

```
rlplan
  ├── rlkin
  │   ├── rlmath
  │   └── rlxml
  ├── rlmath
  ├── rlmdl
  │   ├── rlmath
  │   └── rlxml
  ├── rlsg
  │   ├── rlmath
  │   ├── rlutil
  │   └── rlxml
  ├── rlutil
  └── rlxml
```

### Required External Dependencies

**All libraries require:**
- Boost (headers, regex, system, thread)
- Eigen3 (for rlmath)

**rlxml requires:**
- libxml2
- libxslt
- Optional: libiconv, zlib

**rlsg requires:**
- Coin3D (required)
- Optional collision backends: Bullet, CCD+FCL, ODE, PQP, SOLID3

**rlmdl requires:**
- Optional: NLopt

**rlhal requires:**
- Optional: ATIDAQ, cifX, Comedi, libdc1394

## Quick Build Commands

### Windows (MSVC)
```powershell
# Configure
cmake .. -G "Visual Studio 16 2019" -A x64 -DBUILD_SHARED_LIBS=ON

# Build Release
cmake --build . --config Release --parallel

# Build Debug
cmake --build . --config Debug --parallel

# Install
cmake --build . --config Release --target install
```

### Linux
```bash
# Configure
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON

# Build
cmake --build . --parallel $(nproc)

# Install
sudo cmake --build . --target install
```

## Verification Commands

### Windows
```powershell
# List all DLLs
Get-ChildItem -Recurse -Filter "*.dll" build\src\rl\

# List all import libraries
Get-ChildItem -Recurse -Filter "*.lib" build\src\rl\

# Check DLL dependencies
dumpbin /dependents build\src\rl\plan\Release\rlplan.dll
```

### Linux
```bash
# List all shared libraries
find build/src/rl -name "*.so*"

# List all static libraries
find build/src/rl -name "*.a"

# Check library dependencies
ldd build/src/rl/plan/librlplan.so.0.7.0

# Check library symbols
nm -D build/src/rl/plan/librlplan.so.0.7.0 | grep -i "T " | head -20
```

## Notes

1. **Interface Libraries (CMake 3.0+):**
   - `rlmath`, `rlutil`, and `rlxml` are INTERFACE libraries in CMake 3.0+
   - They don't generate actual library files, only headers
   - On CMake < 3.0, they are built as static libraries

2. **Version Suffixes:**
   - Windows: Version is embedded in DLL metadata, not filename
   - Linux: Version is part of filename (`.so.0.7.0`)

3. **Debug Postfixes:**
   - Windows: Debug builds append `d` (e.g., `rlplan.dll` → `rlpland.dll`)
   - Linux: Debug builds use same name, debug info in separate `.debug` file

4. **Static vs Shared:**
   - Static libraries use `s` suffix on Windows (e.g., `rlplans.lib`)
   - Static libraries use `.a` extension on Linux (e.g., `librlplan.a`)

