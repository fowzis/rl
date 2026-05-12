# Robotics Library (RL) Build Guide

## Overview

The Robotics Library (RL) is a self-contained C++ library for robot kinematics, visualization, motion planning, and control. This guide provides detailed instructions on how to build the project and generate all required libraries.

## Library Structure

The RL project consists of the following core libraries:

### Core Libraries

1. **rlstd** - C++ standard library interface layer (header-only)
   - Source: `src/rl/std/`

2. **rlmath** - Mathematics component (header-only/interface library, no compiled output)
   - Depends on: Boost, Eigen3
   - Source: `src/rl/math/`

3. **rlutil** - Utility component (header-only/interface library, no compiled output)
   - Depends on: Threads
   - Optional: RTAI, Xenomai
   - Source: `src/rl/util/`

4. **rlxml** - XML abstraction layer component (header-only/interface library, no compiled output)
   - Depends on: Boost, libxml2, libxslt
   - Optional: libiconv, zlib
   - Source: `src/rl/xml/`

5. **rlhal** (`rlhal.dll` / `librlhal.so`) - Hardware abstraction layer component
   - Depends on: math, util
   - Optional: ATIDAQ, cifX, Comedi, libdc1394
   - Source: `src/rl/hal/`

6. **rlkin** (`rlkin.dll` / `librlkin.so`) - Denavit-Hartenberg kinematics component
   - Depends on: math, xml
   - Source: `src/rl/kin/`

7. **rlmdl** (`rlmdl.dll` / `librlmdl.so`) - Rigid body kinematics and dynamics component
   - Depends on: math, xml
   - Optional: NLopt (for inverse kinematics)
   - Source: `src/rl/mdl/`

8. **rlsg** (`rlsg.dll` / `librlsg.so`) - Scene graph abstraction component
   - Depends on: math, util, xml, Coin3D
   - Optional collision detection backends: Bullet, CCD+FCL, ODE, PQP, SOLID3
   - Source: `src/rl/sg/`

9. **rlplan** (`rlplan.dll` / `librlplan.so`) - Path planning component
   - Depends on: kin, math, mdl, sg, util, xml
   - Source: `src/rl/plan/`

---

## Dependency Installation Guide

---

## Windows Dependency Installation (Visual Studio 2022)

### Required Tools

1. **Visual Studio 2022** (or Visual Studio Build Tools 2022)
   - **Required Workloads:**
     - Desktop development with C++
     - CMake tools for Windows (optional but recommended)
   - **Required Components:**
     - MSVC v143 — VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK (latest version)

2. **CMake** (3.1+ required)
   - **Download:** [CMake Downloads](https://cmake.org/download/)
   - Select "Add CMake to system PATH" during installation
   - **Verify:** `cmake --version`

3. **Ninja** (optional but recommended for faster builds)
   - **Download:** [Ninja releases](https://github.com/ninja-build/ninja/releases)
   - Add to PATH

4. **Git**
   - **Download:** [Git for Windows](https://git-scm.com/download/win)

### Dependency Strategy for Windows

On Windows, pre-built third-party dependency binaries are downloaded from the project's GitHub releases. After downloading and extracting them, point CMake to their location via `CMAKE_PREFIX_PATH`:

```powershell
cmake -B build -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_PREFIX_PATH="C:\path\to\3rdparty\install"
```

### Qt5/Qt6 Installation (Required for Demos)

1. Download Qt Online Installer from [qt.io/download-open-source](https://www.qt.io/download-open-source)
2. Install Qt 5.15.x or Qt 6.x — select the MSVC 2019 64-bit component
3. Set the CMake prefix so Qt is found:

   ```powershell
   $env:Qt5_DIR = "C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5"
   ```

### Step-by-Step Build (Windows)

1. **Open x64 Native Tools Command Prompt for VS 2022**

2. **Navigate to project directory:**

   ```powershell
   cd C:\path\to\rl
   ```

3. **Configure:**

   ```powershell
   cmake -B build -G "Visual Studio 17 2022" -A x64 `
     -DCMAKE_BUILD_TYPE=Release `
     -DCMAKE_PREFIX_PATH="C:\path\to\3rdparty\install" `
     -DCMAKE_INSTALL_PREFIX="C:\RL\install"
   ```

   For other Visual Studio versions:
   - VS 2015: `-G "Visual Studio 14 2015"`
   - VS 2017: `-G "Visual Studio 15 2017"`
   - VS 2019: `-G "Visual Studio 16 2019"`
   - VS 2022: `-G "Visual Studio 17 2022"`

4. **Build:**

   ```powershell
   cmake --build build --config Release --parallel
   ```

   Or open the generated `rl.sln` in Visual Studio and build from there.

5. **Install:**

   ```powershell
   cmake --build build --config Release --target install
   ```

### Output Locations (Windows)

When `BUILD_SHARED_LIBS=ON`:

- **Release DLLs:** `build\bin\rl<component>.dll`
- **Import libraries:** `build\lib\rl<component>.lib`

After install:

- **DLLs:** `<install_prefix>\bin\rl<component>.dll`
- **LIBs:** `<install_prefix>\lib\rl<component>.lib`
- **Headers:** `<install_prefix>\include\rl-0.7.0\rl\<component>\`

---

## Native Linux Dependency Installation

### Step 1: Install Build Tools

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  ninja-build \
  git \
  pkg-config
```

**Fedora/RHEL/CentOS:**

```bash
sudo dnf install -y \
  gcc-c++ \
  cmake \
  ninja-build \
  git \
  pkgconfig
```

**Arch Linux:**

```bash
sudo pacman -S \
  base-devel \
  cmake \
  ninja \
  git \
  pkgconf
```

### Step 2: Install Required Dependencies

**Ubuntu 24.04 (Noble) and later:**

```bash
sudo apt-get install -y \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-filesystem-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  liblzma-dev \
  libcoin-dev \
  libsoqt520-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  xorg-dev
```

**Ubuntu/Debian (20.04–22.04 / Debian 11+):**

```bash
sudo apt-get install -y \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-filesystem-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  liblzma-dev \
  libcoin80-dev \
  libsoqt80-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  xorg-dev
```

**Ubuntu 18.04:**

```bash
sudo apt-get install -y \
  libboost-dev \
  libboost-regex-dev \
  libboost-system-dev \
  libboost-thread-dev \
  libboost-filesystem-dev \
  libeigen3-dev \
  libxml2-dev \
  libxslt1-dev \
  liblzma-dev \
  libcoin80-dev \
  libsoqt80-dev \
  qtbase5-dev \
  libqt5opengl5-dev \
  libgl1-mesa-dev \
  xorg-dev
```

**Fedora/RHEL/CentOS:**

```bash
sudo dnf install -y \
  boost-devel \
  eigen3-devel \
  libxml2-devel \
  libxslt-devel \
  xz-devel \
  Coin3-devel \
  SoQt-devel \
  qt5-qtbase-devel \
  qt5-qtbase-opengl \
  mesa-libGL-devel \
  libX11-devel
```

**Arch Linux:**

```bash
sudo pacman -S \
  boost \
  eigen \
  libxml2 \
  libxslt \
  xz \
  coin \
  soqt \
  qt5-base \
  mesa \
  libx11
```

### Step 3: Install Optional Dependencies

**For collision detection backends:**

**Ubuntu/Debian:**

```bash
sudo apt-get install -y \
  libbullet-dev \
  libfcl-dev \
  libccd-dev \
  libode-dev \
  libnlopt-dev
```

**Fedora/RHEL:**

```bash
sudo dnf install -y \
  bullet-devel \
  fcl-devel \
  libccd-devel \
  ode-devel \
  nlopt-devel
```

**Arch Linux:**

```bash
sudo pacman -S \
  bullet \
  fcl \
  ccd \
  ode \
  nlopt
```

### Step 4: Verify Dependencies

```bash
cmake --version          # must be >= 3.1
g++ --version
pkg-config --modversion eigen3
pkg-config --modversion libxml-2.0
pkg-config --modversion libxslt
qmake --version          # Qt5
```

---

## WSL 2 Dependency Installation

WSL 2 uses the same dependency installation as native Linux. Follow the [Native Linux Dependency Installation](#native-linux-dependency-installation) section, then note the WSL 2-specific points below.

### WSL 2 Specific Considerations

**GUI Support (Windows 11 with WSLg):**

- WSLg is automatically enabled — no additional configuration needed.
- Test with: `xeyes` (install with `sudo apt-get install x11-apps`)

**GUI Support (Windows 10 without WSLg):**

- Install an X11 server on Windows: [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or [X410](https://www.microsoft.com/store/p/x410/9nlp712zmn9q)
- Set DISPLAY in WSL 2:

  ```bash
  export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
  ```

- Add to `~/.bashrc` to make permanent.

**Performance:**

- Build on the Linux filesystem (`~/`) not the Windows filesystem (`/mnt/c/`).
- Use `--parallel $(nproc)` or Ninja for faster builds.

---

## Dependency Summary Table

| Dependency | Windows | Native Linux | WSL 2 | Notes |
| --- | --- | --- | --- | --- |
| **CMake** | Manual install | Package manager | Package manager | >= 3.1 required |
| **Compiler** | VS 2022 | g++/clang | g++/clang | C++11 support required |
| **Boost** | Pre-built binaries | `libboost-dev` | `libboost-dev` | headers + regex + system + thread |
| **Eigen3** | Pre-built binaries | `libeigen3-dev` | `libeigen3-dev` | Required for math component |
| **libxml2** | Pre-built binaries | `libxml2-dev` | `libxml2-dev` | Required for XML component |
| **libxslt** | Pre-built binaries | `libxslt1-dev` | `libxslt1-dev` | Required for XML component |
| **liblzma** | Pre-built binaries | `liblzma-dev` | `liblzma-dev` | Required (transitive dep of libxml2) |
| **Coin3D** | Pre-built binaries | `libcoin-dev` (24.04+) / `libcoin80-dev` | same | Required for scene graph |
| **SoQt** | Pre-built binaries | `libsoqt520-dev` (24.04+) / `libsoqt80-dev` | same | Coin3D Qt integration |
| **Qt5** | Manual install | `qtbase5-dev` | `qtbase5-dev` | Required for GUI demos |
| **OpenGL** | VS included | `libgl1-mesa-dev` | `libgl1-mesa-dev` | For visualization |
| **Bullet** | Pre-built binaries | `libbullet-dev` | `libbullet-dev` | Optional collision backend |
| **FCL** | Pre-built binaries | `libfcl-dev` | `libfcl-dev` | Optional collision backend |
| **ODE** | Pre-built binaries | `libode-dev` | `libode-dev` | Optional collision backend |
| **NLopt** | Pre-built binaries | `libnlopt-dev` | `libnlopt-dev` | Optional for inverse kinematics |

---

## Build Configuration Options

### Main CMake Options

| Option | Default | Description |
| --- | --- | --- |
| `BUILD_SHARED_LIBS` | ON | Build shared libraries (.dll/.so) vs static libraries (.lib/.a) |
| `RL_BUILD_DEMOS` | ON | Build demo applications |
| `RL_BUILD_TESTS` | ON | Build test programs |
| `RL_BUILD_EXTRAS` | ON | Build extra utilities |
| `RL_USE_QT5` | ON | Prefer Qt5 over Qt4 if available |
| `RL_USE_QT6` | ON | Prefer Qt6 over Qt5 if available |

### Component Options

| Option | Default | Description |
| --- | --- | --- |
| `RL_BUILD_MATH` | ON | Build mathematics component |
| `RL_BUILD_UTIL` | ON | Build utility component |
| `RL_BUILD_XML` | ON | Build XML abstraction layer |
| `RL_BUILD_KIN` | ON | Build kinematics component (requires: math, xml) |
| `RL_BUILD_MDL` | ON | Build rigid body dynamics component (requires: math, xml) |
| `RL_BUILD_HAL` | ON | Build hardware abstraction layer (requires: math, util) |
| `RL_BUILD_SG` | ON | Build scene graph component (requires: math, util, xml) |
| `RL_BUILD_PLAN` | ON | Build path planning component (requires: kin, math, mdl, sg, util, xml) |

---

## Build Instructions

### Native Linux / WSL 2

#### Step-by-Step Build

1. **Configure:**

   ```bash
   cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
   ```

   Without Ninja (uses Make):

   ```bash
   cmake -B build -DCMAKE_BUILD_TYPE=Release
   ```

   With a custom install prefix:

   ```bash
   cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=/usr/local
   ```

2. **Build:**

   ```bash
   cmake --build build
   ```

   Or with explicit parallelism when not using Ninja:

   ```bash
   cmake --build build --parallel $(nproc)
   ```

3. **Run tests (optional):**

   ```bash
   cd build && ctest --output-on-failure
   ```

4. **Install:**

   ```bash
   sudo cmake --install build
   ```

#### Selective Builds

Disable unused components to speed up iteration:

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DRL_BUILD_DEMOS=OFF \
  -DRL_BUILD_EXTRAS=OFF \
  -DRL_BUILD_PLAN=OFF
```

#### Output Locations (Linux)

- **Libraries:** `build/lib/librl<component>.so.0.7.0`
- **Symlinks:** `build/lib/librl<component>.so`
- **Executables:** `build/bin/`

After install:

- **Libraries:** `<install_prefix>/lib/librl<component>.so.0.7.0`
- **Headers:** `<install_prefix>/include/rl-0.7.0/rl/<component>/`

---

### Windows (MSVC) — Visual Studio 2022

See the [Windows Dependency Installation](#windows-dependency-installation-visual-studio-2022) section for prerequisites.

#### Step-by-Step Build (Windows / MSVC)

1. Open **x64 Native Tools Command Prompt for VS 2022**

2. **Configure:**

   ```powershell
   cmake -B build -G "Visual Studio 17 2022" -A x64 `
     -DCMAKE_INSTALL_PREFIX="C:\RL\install" `
     -DCMAKE_PREFIX_PATH="C:\path\to\3rdparty\install"
   ```

3. **Build:**

   ```powershell
   cmake --build build --config Release --parallel
   ```

4. **Install:**

   ```powershell
   cmake --build build --config Release --target install
   ```

#### Output Locations (Windows / MSVC)

- **DLLs:** `build\bin\rl<component>.dll`
- **Import libraries:** `build\lib\rl<component>.lib`

After install:

- **DLLs:** `<install_prefix>\bin\rl<component>.dll`
- **LIBs:** `<install_prefix>\lib\rl<component>.lib`
- **Headers:** `<install_prefix>\include\rl-0.7.0\rl\<component>\`

---

## Running Examples and Demos

### Setup: library path

Before running anything, make the built `.so` files visible to the dynamic linker:

```bash
export LD_LIBRARY_PATH=/path/to/rl/build/lib:$LD_LIBRARY_PATH
```

### Sample data files

All demos load robot models and scene files. The bundled examples are in:

| Directory | Contents |
| --- | --- |
| `examples/rlsg/` | 3D scene geometry (`.xml` + `.wrl` meshes) |
| `examples/rlkin/` | DH kinematics-only models (`.xml`) |
| `examples/rlmdl/` | Full rigid-body models with dynamics (`.xml`) |
| `examples/rlplan/` | Self-contained planning configs (`.xml`) |

The **Unimation Puma 560** is the most complete robot available across all four categories:

- Scene: `examples/rlsg/unimation-puma560_boxes.xml`
- Kinematics: `examples/rlkin/unimation-puma560.xml`
- Dynamics model: `examples/rlmdl/unimation-puma560.xml`
- Planning config: `examples/rlplan/unimation-puma560_boxes_rrtConCon.mdl.xml`

### GUI Demos (interactive Qt window)

**rlViewDemo** — 3D scene viewer; simplest starting point:

```bash
./build/bin/rlViewDemo examples/rlsg/unimation-puma560_boxes.xml
# or launch without args and use File > Open
./build/bin/rlViewDemo
```

**rlCoachKin** — Interactive joint sliders using the kinematics model:

```bash
./build/bin/rlCoachKin \
  examples/rlsg/unimation-puma560_boxes.xml \
  examples/rlkin/unimation-puma560.xml
```

**rlCoachMdl** — Same as CoachKin but uses the full dynamics model:

```bash
./build/bin/rlCoachMdl \
  examples/rlsg/unimation-puma560_boxes.xml \
  examples/rlmdl/unimation-puma560.xml
```

**rlSimulator** — Real-time physics simulation:

```bash
./build/bin/rlSimulator \
  examples/rlsg/unimation-puma560_boxes.xml \
  examples/rlmdl/unimation-puma560.xml
```

**rlCollisionDemo** — Collision detection visualizer (opens a file dialog on launch):

```bash
./build/bin/rlCollisionDemo
# then open: examples/rlsg/unimation-puma560_boxes.xml
```

**rlPlanDemo** — Path planning visualizer (opens a file dialog on launch):

```bash
./build/bin/rlPlanDemo
# then open one of:
#   examples/rlplan/unimation-puma560_boxes_rrtConCon.mdl.xml   (RRT, Puma 560)
#   examples/rlplan/unimation-puma560_boxes_prm.mdl.xml         (PRM, Puma 560)
#   examples/rlplan/box-6d-300505_maze_rrtConCon.mdl.sixDof.xml (RRT, 6-DOF box)
```

### CLI Demos (console output, no window)

**rlRrtDemo / rlPrmDemo** — Run a planner and print the resulting path.

Arguments: `SCENE_XML  KINEMATICS_XML  q_start[n]  q_goal[n]` (joint angles in degrees)

```bash
./build/bin/rlRrtDemo \
  examples/rlsg/unimation-puma560_boxes.xml \
  examples/rlkin/unimation-puma560.xml \
  0 0 0 0 0 0 \
  90 45 0 0 0 0

./build/bin/rlPrmDemo \
  examples/rlsg/unimation-puma560_boxes.xml \
  examples/rlkin/unimation-puma560.xml \
  0 0 0 0 0 0 \
  90 45 0 0 0 0
```

**rlDynamics1Demo** — Inverse and forward dynamics.

Arguments: `MODEL_XML  q[n]  qd[n]  qdd[n]` (joint positions, velocities, accelerations)

```bash
./build/bin/rlDynamics1Demo \
  examples/rlmdl/unimation-puma560.xml \
  0 0 0 0 0 0 \
  0 0 0 0 0 0 \
  0 0 0 0 0 0
```

**rlDynamics2Demo** — Full kinematics and dynamics report (Jacobians, mass matrix, Coriolis, gravity):

```bash
./build/bin/rlDynamics2Demo \
  examples/rlmdl/unimation-puma560.xml \
  0 0 0 0 0 0 \
  0 0 0 0 0 0 \
  0 0 0 0 0 0
```

### Available Robot Models

| Robot | Scene | Kinematics | Dynamics |
| --- | --- | --- | --- |
| Unimation Puma 560 | `rlsg/unimation-puma560_boxes.xml` | `rlkin/unimation-puma560.xml` | `rlmdl/unimation-puma560.xml` |
| Mitsubishi RV-6SL | — | `rlkin/mitsubishi-rv6sl.xml` | `rlmdl/mitsubishi-rv6sl.xml` |
| Stäubli TX60L | — | `rlkin/staeubli-tx60l.xml` | — |
| Comau Smart5 NJ4 | — | — | `rlmdl/comau-smart5-nj4-220-27.xml` |
| Box 6-DOF (planar) | `rlsg/box-6d-300505_maze.xml` | `rlkin/box-6d-300505.xml` | `rlmdl/box-6d-300505.sixDof.xml` |
| Planar 2-link | `rlsg/planar2.xml` | — | `rlmdl/planar2.xml` |
| Planar 3-link | `rlsg/planar3.xml` | — | `rlmdl/planar3.xml` |

---

## Library Naming Conventions

### Windows Library Naming

**Shared Libraries (`BUILD_SHARED_LIBS=ON`):**

- Release: `rl<component>.dll`, `rl<component>.lib`
- Debug: `rl<component>d.dll`, `rl<component>d.lib`

**Static Libraries (`BUILD_SHARED_LIBS=OFF`):**

- Release: `rl<component>s.lib`
- Debug: `rl<component>sd.lib`

### Linux Library Naming

**Shared Libraries:**

- `librl<component>.so.0.7.0` (full version)
- `librl<component>.so` (unversioned symlink → `.so.0.7.0`)

**Static Libraries:**

- `librl<component>.a`

---

## Verification

After building, verify the libraries were created:

**Linux:**

```bash
ls build/lib/*.so
```

**Windows:**

```powershell
dir build\bin\*.dll
dir build\lib\*.lib
```

Run the test suite:

```bash
cd build && ctest --output-on-failure
```

---

## Advanced Configuration

### Custom Dependency Paths

If dependencies are installed in non-standard locations:

```bash
cmake -B build \
  -DBoost_ROOT=/path/to/boost \
  -DEigen3_DIR=/path/to/eigen3/share/eigen3/cmake \
  -DCoin_DIR=/path/to/coin/lib/cmake/Coin \
  -DLIBXML2_ROOT=/path/to/libxml2
```

### Building Only Specific Targets

```bash
# Linux
cmake --build build --target rlplan rlkin rlsg

# Windows
cmake --build build --config Release --target rlplan rlkin rlsg
```

---

## Package Generation

**Linux (.tar.xz):**

```bash
cpack -B build -G TXZ
```

**Windows (.7z):**

```powershell
cpack -B build -G 7Z
```

---

## Troubleshooting

### Common Issues

1. **CMake can't find dependencies:**
   - Use `-D<Package>_ROOT` or `-DCMAKE_PREFIX_PATH` to specify install locations.

2. **`Could NOT find LibLZMA`:**
   - Install `liblzma-dev` (Ubuntu/Debian) or `xz-devel` (Fedora/RHEL). This is a required transitive dependency of libxml2.

3. **Link errors on Windows:**
   - Ensure all DLLs are in PATH or the same directory as the executable.

4. **Missing symbols on Linux:**
   - Set `LD_LIBRARY_PATH` to include `build/lib/` or run `sudo ldconfig` after installing.

5. **Qt/SoQt not found:**
   - Install Qt development packages and set `Qt5_DIR` if installed in a custom location.
   - To build without GUI demos: `-DRL_BUILD_DEMOS=OFF`

6. **GUI demos don't display (WSL 2):**
   - Windows 11: verify WSLg is active (`echo $DISPLAY`).
   - Windows 10: start your X11 server and set `DISPLAY` manually.

### Linux/WSL 2: Permission errors

Use `sudo` for system-wide installation, or install to a user directory:

```bash
cmake --install build --prefix ~/local
```
