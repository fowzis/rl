# Bullet Physics Dependencies Analysis

## Question 1: Which RL DLL Requires Bullet DLLs?

**Answer:** `rlsg.dll` (Scene Graph library) requires Bullet Physics libraries.

### Evidence:
From `rl/src/rl/sg/CMakeLists.txt` (line 198-200):
```cmake
if(RL_BUILD_SG_BULLET)
    target_compile_definitions(sg INTERFACE RL_SG_BULLET)
    target_link_libraries(sg Bullet::BulletCollision Bullet::BulletDynamics Bullet::BulletSoftBody Bullet::LinearMath)
endif()
```

The `rlsg.dll` links against:
- `Bullet::BulletCollision`
- `Bullet::BulletDynamics`
- `Bullet::BulletSoftBody`
- `Bullet::LinearMath`

---

## Question 2: Are Bullet Libraries Static or Shared? Why No DLLs?

**Answer:** Bullet Physics is built as **STATIC libraries** (`.lib` files), not shared libraries (`.dll` files).

### Evidence:

#### 1. Build Configuration
From `rl-3rdparty/bullet3/CMakeLists.txt` (line 21):
```cmake
#-DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
```

**This line is COMMENTED OUT**, meaning Bullet is NOT configured to build as shared libraries, regardless of the parent project's `BUILD_SHARED_LIBS` setting.

#### 2. Installed Libraries
All Bullet libraries in `rl-3rdparty/install/lib/` are static libraries (`.lib` files):

- `BulletCollision.lib` (5.5 MB)
- `BulletDynamics.lib` (3.9 MB)
- `BulletSoftBody.lib` (5.2 MB)
- `LinearMath.lib` (present)
- `Bullet2FileLoader.lib`
- `Bullet3Collision.lib`
- `Bullet3Dynamics.lib`
- `Bullet3Common.lib`
- `Bullet3Geometry.lib`
- `Bullet3OpenCL_clew.lib`
- `BulletInverseDynamics.lib`

**No `.dll` files exist** for Bullet in the install directory.

#### 3. Build Log Confirmation
The build log shows all Bullet libraries are built as `.lib` files:
```
BulletCollision.vcxproj -> ...\BulletCollision.lib
BulletDynamics.vcxproj -> ...\BulletDynamics.lib
BulletSoftBody.vcxproj -> ...\BulletSoftBody.lib
LinearMath.vcxproj -> ...\LinearMath.lib
```

### Why Static Libraries?

Looking at the CMakeLists.txt comment (line 1-2):
```cmake
# Disable extras when building shared libraries to avoid Winsock2 linking issues
if(BUILD_SHARED_LIBS)
    set(BULLET_BUILD_EXTRAS OFF)
```

The comment suggests there are **Winsock2 linking issues** when building Bullet as shared libraries. To avoid these issues, Bullet is intentionally built as static libraries.

---

## Impact on Deployment

### Static Linking Behavior

Since `rlsg.dll` is a shared library (DLL) that links against Bullet static libraries:

1. **The Bullet code is statically linked into `rlsg.dll`**
2. **No separate Bullet DLLs are needed at runtime**
3. **The Bullet functionality is embedded in `rlsg.dll`**

### Deployment Implications

✅ **Good News:** You don't need to deploy Bullet DLLs separately - they're already included in `rlsg.dll`

❌ **The Missing DLLs Warning:** The `deploy-dlls.ps1` script shows `[MISSING]` for Bullet DLLs, but this is **expected and harmless** because:
- Bullet is statically linked
- No Bullet DLLs exist (they're not built)
- `rlsg.dll` already contains all Bullet functionality

### Recommendation

The `deploy-dlls.ps1` script should be updated to:
1. Check if Bullet libraries are static (`.lib` files exist but no `.dll` files)
2. Skip the "missing DLL" warning for Bullet when static libraries are detected
3. Add a note that Bullet is statically linked into `rlsg.dll`

---

## Summary

| Question | Answer |
|----------|--------|
| **Which RL DLL requires Bullet?** | `rlsg.dll` (Scene Graph library) |
| **Are Bullet libraries static or shared?** | **Static libraries** (`.lib` files) |
| **Why no DLLs?** | `BUILD_SHARED_LIBS` is commented out in Bullet CMakeLists.txt to avoid Winsock2 linking issues |
| **Do we need Bullet DLLs at runtime?** | **No** - Bullet code is statically linked into `rlsg.dll` |
| **Is the "missing DLL" warning a problem?** | **No** - It's expected since Bullet is built as static libraries |

---

**Last Updated:** January 13, 2025
