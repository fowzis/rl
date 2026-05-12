# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The **Robotics Library (RL)** is a C++11 library (v0.7.0) for rigid body kinematics, dynamics, motion planning, and control. BSD 2-clause licensed.

## Build Commands

```bash
# Configure (Release build, from repo root)
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build (using Ninja is recommended)
cmake --build build

# Install
cmake --install build

# Package (.tar.xz)
cpack -B build -G TXZ
```

The provided shell script handles dependency lookup and common options:
```bash
./scripts/build-rl.sh [--install-prefix <path>] [--build-type Release|Debug] [--jobs N]
```

### Selective Builds

Disable unused components to speed up iteration:
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug \
  -DRL_BUILD_DEMOS=OFF \
  -DRL_BUILD_EXTRAS=OFF \
  -DRL_BUILD_PLAN=OFF   # also disables sg dependency chain
```

Key CMake options (all ON by default unless noted):
- `RL_BUILD_MATH`, `RL_BUILD_UTIL`, `RL_BUILD_XML`, `RL_BUILD_STD`
- `RL_BUILD_HAL`, `RL_BUILD_KIN`, `RL_BUILD_MDL`, `RL_BUILD_SG`, `RL_BUILD_PLAN`
- `RL_BUILD_DEMOS`, `RL_BUILD_EXTRAS`, `RL_BUILD_TESTS`
- `RL_USE_QT5`, `RL_USE_QT6`

## Tests

Tests use CTest directly (no external framework — assertions are plain `assert()`/custom logic):
```bash
# Run all tests
cd build && ctest --output-on-failure

# Run a single test by name
ctest -R rlMathDeltaTest --output-on-failure

# Verbose output
ctest -V
```

Tests are under [tests/](tests/) and organized by component (math, kinematics, dynamics, planning, collision, HAL).

## Architecture

### Component Dependency Layers

```
rlplan  (motion planning)
  └── rlsg    (scene graph / collision detection)
  └── rlmdl   (rigid body dynamics)
  └── rlkin   (DH kinematics)
  └── rlhal   (hardware abstraction)
        └── rlmath  (Eigen wrappers — header-only)
        └── rlutil  (threading/timing — header-only)
        └── rlxml   (libxml2/libxslt wrapper)
```

Upper layers depend on all layers below. `rlmath` and `rlutil` are CMake INTERFACE (header-only) libraries; the others produce compiled `.so`/`.dll` targets.

### Namespaces

All code lives under `rl::`. Component sub-namespaces:
- `rl::math` — vectors, matrices, rotations, spatial algebra, splines, PID, Kalman
- `rl::util` — real-time threads, timers
- `rl::xml` — DOM/XPath wrappers
- `rl::kin` — DH chains, joints, end-effector Jacobians
- `rl::mdl` — rigid-body model, forward/inverse kinematics and dynamics
- `rl::hal` — sensors, actuators, serial/socket comms
- `rl::sg` — scene graph bodies, pluggable collision backends (Bullet, FCL, ODE, PQP, SOLID3)
- `rl::plan` — sampling-based planners (PRM, RRT, …)

### Key Patterns

- **XML-driven robot loading**: Kinematics/dynamics models are loaded from XML files via factory classes (`rl::kin::XmlFactory`, `rl::mdl::XmlFactory`). The schema mirrors the DH convention.
- **Pluggable collision backends**: `rl::sg` defines an abstract scene interface; concrete backends (Bullet, FCL, etc.) are selected at compile time via CMake options and linked as optional sub-targets.
- **Eigen throughout**: All math types are Eigen-based. `rl::math` provides thin type aliases and algorithm headers on top of Eigen — prefer them over raw Eigen types within RL code.
- **Hardware abstraction**: `rl::hal` classes follow a uniform open/read/write/close lifecycle; device-specific adapters (cifX, Comedi, dc1394, ATIDAQ) are conditionally compiled.

### Demos vs Examples vs Tests

| Directory | Purpose |
|-----------|---------|
| [demos/](demos/) | 33 GUI/CLI applications (Qt-based visualizers, simulators) |
| [examples/](examples/) | Minimal usage examples per component |
| [tests/](tests/) | Correctness tests; run via CTest |

### CMake Modules

[cmake/](cmake/) contains `Find*.cmake` modules for optional dependencies (Bullet, FCL, ODE, PQP, SOLID3, SoQt, NLopt, ATIDAQ, Comedi, cifX, dc1394). When adding new optional dependencies, follow the existing pattern there.

## Platform Notes

- **Linux**: Expects system packages; use apt/dnf/pacman for Boost, Eigen3, libxml2, libxslt.
- **Windows**: CI downloads pre-built 3rdparty binaries from GitHub releases and passes them via `CMAKE_PREFIX_PATH`. Deployment scripts ([scripts/deploy-dlls.ps1](scripts/deploy-dlls.ps1), [scripts/deploy-exe.ps1](scripts/deploy-exe.ps1)) copy required DLLs next to executables.
- **CI**: Multiplatform GitHub Actions — see [.github/workflows/ci.yml](.github/workflows/ci.yml). Builds with Ninja + ccache on macOS, Windows MSVC (Qt5 & Qt6 matrix), and Windows MSYS2.
