# Robotics Library Executables - Complete Dependency Analysis

**Build Date:** January 13, 2025  
**Version:** 0.7.0  
**Install Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\`

---

## 📋 Executive Summary

This document provides a complete list of all executables created by the Robotics Library build and their runtime dependencies. All executables require the dependencies to be available in the system PATH or in the same directory as the executable.

---

## 🔗 Dependency Categories

### 1. **Microsoft Visual C++ Runtime (MSVC)**
All executables require the MSVC 2015-2022 runtime libraries (v140-v143).

### 2. **Robotics Library Core DLLs**
Internal libraries that must be present for executables to run.

### 3. **Third-Party Libraries**
External dependencies from the rl-3rdparty build.

### 4. **Qt Framework** (for GUI applications)
Required for executables with graphical user interfaces.

### 5. **OpenGL**
Required for 3D visualization applications.

---

## 📦 Complete Executable List and Dependencies

### Core Library DLLs

These are the foundation libraries that other executables depend on:

#### 1. **rlkin.dll**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlkin.dll`

**Dependencies:**
- ✅ MSVC Runtime (vcruntime140.dll, msvcp140.dll, etc.)
- ✅ Boost (header-only, no DLL)
- ✅ Eigen3 (header-only, no DLL)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

**Used by:** All executables that use kinematics functionality

---

#### 2. **rlhal.dll**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlhal.dll`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ Boost (header-only)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

**Used by:** All executables that use hardware abstraction layer

---

#### 3. **rlmdl.dll**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlmdl.dll`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ Boost (header-only)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ NLopt (`nlopt.dll`) - if RL_BUILD_MDL_NLOPT is enabled
- ✅ rlkin.dll (depends on kinematics)

**Used by:** All executables that use robot modeling and dynamics

---

#### 4. **rlsg.dll**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlsg.dll`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ Boost (header-only)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ Coin3D (`Coin4.dll`) - for scene graph visualization
- ✅ Bullet Physics (`BulletCollision.dll`, `BulletDynamics.dll`, `BulletSoftBody.dll`, `LinearMath.dll`) - if RL_BUILD_SG_BULLET
- ✅ FCL (`fcl.dll`) - if RL_BUILD_SG_FCL
- ✅ ODE (`ode_double.dll`) - if RL_BUILD_SG_ODE
- ✅ PQP (`pqp.dll`) - if RL_BUILD_SG_PQP
- ✅ SOLID (`solid3.dll`) - if RL_BUILD_SG_SOLID
- ✅ rlkin.dll
- ✅ rlmdl.dll

**Used by:** All executables that use scene graph and collision detection

---

#### 5. **rlplan.dll**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlplan.dll`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ Boost (header-only)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ rlkin.dll
- ✅ rlmdl.dll
- ✅ rlsg.dll

**Used by:** All executables that use path planning

---

## 🎮 Executable Dependencies

### Simple Console Applications (No GUI)

These executables have minimal dependencies and can run without Qt or OpenGL:

#### 1. **rlDenavitHartenbergDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlDenavitHartenbergDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 2. **rlEulerAnglesDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlEulerAnglesDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 3. **rlQuaternionDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlQuaternionDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 4. **rlRotationConverterDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlRotationConverterDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 5. **rlPolynomialRootsDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlPolynomialRootsDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 6. **rlInterpolatorDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlInterpolatorDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 7. **rlTrapezoidalVelocityDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlTrapezoidalVelocityDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 8. **rlLowPassDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlLowPassDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 9. **rlPcaDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlPcaDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 10. **rlKalmanDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlKalmanDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 11. **rlKalmanDemo2.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlKalmanDemo2.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll (or math library)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 12. **rlTimerDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlTimerDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlutil.dll (if exists) or static linking
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 13. **rlThreadsDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlThreadsDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ Windows Threads (system library)
- ✅ rlutil.dll (if exists)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 14. **rlLoadXmlDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlLoadXmlDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlxml.dll (if exists) or static linking
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 15. **rlDynamics1Demo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlDynamics1Demo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlmdl.dll
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ nlopt.dll (if NLopt support enabled)

---

#### 16. **rlDynamics1Planar2Demo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlDynamics1Planar2Demo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlmdl.dll
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ nlopt.dll (if NLopt support enabled)

---

#### 17. **rlDynamics2Demo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlDynamics2Demo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlmdl.dll
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ nlopt.dll (if NLopt support enabled)

---

#### 18. **rlJacobianDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlJacobianDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 19. **rlInversePositionDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlInversePositionDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 20. **rlPumaDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlPumaDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 21. **rlAxisControllerDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlAxisControllerDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 22. **rlPrmDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlPrmDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlplan.dll
- ✅ rlkin.dll
- ✅ rlmdl.dll
- ✅ rlsg.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ Coin4.dll (if using scene graph)
- ✅ Collision detection DLLs (Bullet/FCL/ODE/PQP/SOLID) - depending on build configuration

---

#### 23. **rlRrtDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlRrtDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlplan.dll
- ✅ rlkin.dll
- ✅ rlmdl.dll
- ✅ rlsg.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ Coin4.dll (if using scene graph)
- ✅ Collision detection DLLs (Bullet/FCL/ODE/PQP/SOLID) - depending on build configuration

---

### GUI Applications (Require Qt and OpenGL)

These executables require Qt framework and OpenGL for graphical user interfaces:

#### 24. **rlPlanDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlPlanDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlplan.dll
- ✅ rlkin.dll
- ✅ rlsg.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ **SoQt1.dll** (SoQt library)
- ✅ **Coin4.dll** (Coin3D scene graph)
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5PrintSupport.dll` / `Qt6PrintSupport.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll** (system library, usually in Windows)
- ✅ Collision detection DLLs (Bullet/FCL/ODE/PQP/SOLID) - depending on build configuration

---

#### 25. **rlViewDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlViewDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlsg.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ **SoQt1.dll**
- ✅ **Coin4.dll**
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll**

---

#### 26. **rlCollisionDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlCollisionDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlsg.dll
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ **SoQt1.dll**
- ✅ **Coin4.dll**
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll**
- ✅ Collision detection DLLs (Bullet/FCL/ODE/PQP/SOLID) - depending on build configuration

---

#### 27. **rlSimulator.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlSimulator.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlplan.dll
- ✅ rlmdl.dll
- ✅ rlkin.dll
- ✅ rlsg.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ **SoQt1.dll**
- ✅ **Coin4.dll**
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll**
- ✅ Collision detection DLLs (Bullet/FCL/ODE/PQP/SOLID)
- ✅ nlopt.dll (if NLopt support enabled)

---

#### 28. **rlCoachKin.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlCoachKin.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ **SoQt1.dll**
- ✅ **Coin4.dll**
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll**

---

#### 29. **rlCoachMdl.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlCoachMdl.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlmdl.dll
- ✅ rlkin.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)
- ✅ **SoQt1.dll**
- ✅ **Coin4.dll**
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll**
- ✅ nlopt.dll (if NLopt support enabled)

---

### Hardware Abstraction Demos

#### 30. **rlGripperDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlGripperDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 31. **rlRobotiqModelCDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlRobotiqModelCDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 32. **rlLaserDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlLaserDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 33. **rlRangeSensorDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlRangeSensorDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 34. **rlSixAxisForceTorqueSensorDemo.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlSixAxisForceTorqueSensorDemo.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 35. **rlSocketDemoClient.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlSocketDemoClient.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ Boost (header-only, but may use Boost.Thread DLL: `boost_thread-vc143-mt-x64-1_88.dll`)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

#### 36. **rlSocketDemoServer.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\rlSocketDemoServer.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ rlhal.dll
- ✅ Boost (header-only, but may use Boost.Thread DLL: `boost_thread-vc143-mt-x64-1_88.dll`)
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

### Utility Executables

#### 37. **byu2wrl.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\byu2wrl.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ LibXml2 (`libxml2.dll`) - minimal
- ✅ LibXslt (`libxslt.dll`) - minimal
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`) - minimal

---

#### 38. **csv2wrl.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\csv2wrl.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ LibXml2 (`libxml2.dll`) - minimal
- ✅ LibXslt (`libxslt.dll`) - minimal
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`) - minimal

---

#### 39. **tris2wrl.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\tris2wrl.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ LibXml2 (`libxml2.dll`) - minimal
- ✅ LibXslt (`libxslt.dll`) - minimal
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`) - minimal

---

#### 40. **wrlview.exe**
**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\wrlview.exe`

**Dependencies:**
- ✅ MSVC Runtime
- ✅ **SoQt1.dll**
- ✅ **Coin4.dll**
- ✅ **Qt5/Qt6 DLLs:**
  - `Qt5Core.dll` / `Qt6Core.dll`
  - `Qt5Gui.dll` / `Qt6Gui.dll`
  - `Qt5OpenGL.dll` / `Qt6OpenGL.dll`
  - `Qt5Widgets.dll` / `Qt6Widgets.dll`
- ✅ **OpenGL32.dll**
- ✅ LibXml2 (`libxml2.dll`)
- ✅ LibXslt (`libxslt.dll`)
- ✅ Iconv (`libiconv.dll`, `libcharset.dll`)

---

## 📚 Complete Dependency Reference

### Microsoft Visual C++ Runtime (Required by ALL executables)

**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\` (installed with RL)

| DLL | Description |
|-----|-------------|
| `vcruntime140.dll` | Visual C++ Runtime Library |
| `vcruntime140_1.dll` | Visual C++ Runtime Library (extended) |
| `msvcp140.dll` | Microsoft Visual C++ Standard Library |
| `msvcp140_1.dll` | Microsoft Visual C++ Standard Library (extended) |
| `msvcp140_2.dll` | Microsoft Visual C++ Standard Library (extended) |
| `msvcp140_atomic_wait.dll` | Atomic wait functions |
| `msvcp140_codecvt_ids.dll` | Code conversion functions |
| `concrt140.dll` | Concurrency Runtime |

**Alternative:** Install [Microsoft Visual C++ Redistributable 2015-2022](https://aka.ms/vs/17/release/vc_redist.x64.exe)

---

### Robotics Library Core DLLs

**Location:** `C:\Tools\RoboticLibrary\GitHub\rl\install\bin\`

| DLL | Description |
|-----|-------------|
| `rlkin.dll` | Kinematics library |
| `rlhal.dll` | Hardware abstraction layer |
| `rlmdl.dll` | Robot modeling and dynamics |
| `rlsg.dll` | Scene graph and collision detection |
| `rlplan.dll` | Path planning algorithms |

---

### Third-Party Libraries

**Location:** `C:\Tools\RoboticLibrary\GitHub\rl-3rdparty\install\bin\`

#### XML Processing
| DLL | Description |
|-----|-------------|
| `libxml2.dll` | XML parsing library |
| `libxslt.dll` | XSLT transformation library |
| `libexslt.dll` | Extended XSLT functions |

#### Character Encoding
| DLL | Description |
|-----|-------------|
| `libiconv.dll` | Character encoding conversion |
| `libcharset.dll` | Character set detection |

#### Optimization
| DLL | Description |
|-----|-------------|
| `nlopt.dll` | Nonlinear optimization library |

#### Scene Graph & Visualization
| DLL | Description |
|-----|-------------|
| `Coin4.dll` | Coin3D scene graph library |
| `SoQt1.dll` | SoQt (Qt bindings for Coin3D) |
| `simage1.dll` | Image loading library (used by Coin3D) |

#### Collision Detection & Physics
| DLL | Description | Used By |
|-----|-------------|---------|
| `ccd.dll` | Continuous Collision Detection | FCL backend |
| `fcl.dll` | Flexible Collision Library | FCL backend |
| `ode_double.dll` | Open Dynamics Engine (double precision) | ODE backend |
| `solid3.dll` | SOLID collision detection | SOLID backend |
| `BulletCollision.dll` | Bullet Physics - Collision | Bullet backend |
| `BulletDynamics.dll` | Bullet Physics - Dynamics | Bullet backend |
| `BulletSoftBody.dll` | Bullet Physics - Soft Body | Bullet backend |
| `LinearMath.dll` | Bullet Physics - Math | Bullet backend |

#### Boost Libraries (if using DLLs)
| DLL | Description |
|-----|-------------|
| `boost_atomic-vc143-mt-x64-1_88.dll` | Atomic operations |
| `boost_chrono-vc143-mt-x64-1_88.dll` | Time utilities |
| `boost_date_time-vc143-mt-x64-1_88.dll` | Date/time handling |
| `boost_filesystem-vc143-mt-x64-1_88.dll` | File system operations |
| `boost_iostreams-vc143-mt-x64-1_88.dll` | I/O streams |
| `boost_locale-vc143-mt-x64-1_88.dll` | Localization |
| `boost_program_options-vc143-mt-x64-1_88.dll` | Command-line parsing |
| `boost_random-vc143-mt-x64-1_88.dll` | Random number generation |
| `boost_serialization-vc143-mt-x64-1_88.dll` | Serialization |
| `boost_system-vc143-mt-x64-1_88.dll` | System utilities |
| `boost_thread-vc143-mt-x64-1_88.dll` | Threading support |
| `boost_timer-vc143-mt-x64-1_88.dll` | Timer utilities |
| `boost_wave-vc143-mt-x64-1_88.dll` | C++ preprocessor |

**Note:** Most Boost libraries are header-only, but some components require DLLs.

---

### Qt Framework (Required for GUI applications)

**Location:** Qt installation directory (typically `C:\Qt\` or system PATH)

#### Qt5 Components
| DLL | Description |
|-----|-------------|
| `Qt5Core.dll` | Core Qt functionality |
| `Qt5Gui.dll` | GUI framework |
| `Qt5OpenGL.dll` | OpenGL integration |
| `Qt5PrintSupport.dll` | Printing support |
| `Qt5Widgets.dll` | Widget library |

#### Qt6 Components
| DLL | Description |
|-----|-------------|
| `Qt6Core.dll` | Core Qt functionality |
| `Qt6Gui.dll` | GUI framework |
| `Qt6OpenGL.dll` | OpenGL integration |
| `Qt6PrintSupport.dll` | Printing support |
| `Qt6Widgets.dll` | Widget library |

**Note:** Qt also requires platform plugins (usually in `plugins/platforms/` directory)

---

### System Libraries

| Library | Description | Location |
|---------|-------------|----------|
| `OpenGL32.dll` | OpenGL implementation | Windows System32 |
| `opengl32.dll` | OpenGL wrapper | Windows System32 |

---

## 🔍 Dependency Resolution

### How to Ensure All Dependencies Are Available

1. **Add to PATH:**
   - `C:\Tools\RoboticLibrary\GitHub\rl\install\bin`
   - `C:\Tools\RoboticLibrary\GitHub\rl-3rdparty\install\bin`
   - Qt bin directory (if using Qt)

2. **Copy DLLs to Executable Directory:**
   - Copy all required DLLs to the same directory as the executable
   - This is the most reliable method for distribution

3. **Use Dependency Walker or similar tools:**
   - Tools like `Dependency Walker` or `Dependencies` can analyze executable dependencies
   - Helps identify missing DLLs

---

## 📊 Dependency Matrix

### Minimal Dependencies (Console Apps)
- MSVC Runtime
- rlkin.dll (or specific RL library)
- libxml2.dll
- libxslt.dll
- libiconv.dll
- libcharset.dll

### Standard Dependencies (Most Demos)
- All minimal dependencies
- Additional RL DLLs (rlmdl.dll, rlsg.dll, rlplan.dll, rlhal.dll)
- Collision detection DLLs (if using scene graph)

### Full Dependencies (GUI Apps)
- All standard dependencies
- SoQt1.dll
- Coin4.dll
- Qt5/Qt6 DLLs
- OpenGL32.dll

---

## ✅ Quick Checklist for Running Executables

### For Console Applications:
- [ ] MSVC Runtime installed or DLLs present
- [ ] RL core DLLs in PATH or same directory
- [ ] Third-party DLLs (libxml2, libxslt, libiconv) in PATH or same directory

### For GUI Applications:
- [ ] All console application requirements
- [ ] Qt framework installed and in PATH
- [ ] SoQt1.dll and Coin4.dll in PATH or same directory
- [ ] OpenGL drivers installed (usually pre-installed on Windows)

---

## 🚨 Common Issues and Solutions

### Issue: "The program can't start because XXX.dll is missing"
**Solution:** 
1. Check if the DLL is in the same directory as the executable
2. Check if the DLL path is in the system PATH
3. Verify the DLL exists in the third-party install directory

### Issue: Qt-related errors
**Solution:**
1. Verify Qt is installed and in PATH
2. Check Qt version matches (Qt5 vs Qt6)
3. Ensure Qt platform plugins are accessible

### Issue: OpenGL errors
**Solution:**
1. Update graphics drivers
2. Verify OpenGL32.dll is available (usually in System32)
3. Check OpenGL version compatibility

---

**Last Updated:** January 13, 2025  
**Build Version:** 0.7.0
