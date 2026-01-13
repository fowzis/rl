#!/bin/bash
# Bash script to build Robotics Library (RL)
# Usage: ./build-rl.sh [--install-prefix <path>] [--third-party-prefix <path>] [--build-type <Release|Debug>] [--skip-build] [--skip-install] [--jobs <N>]

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_PREFIX="${RL_ROOT}/install"
THIRD_PARTY_PREFIX="$(cd "${RL_ROOT}/../rl-3rdparty" && pwd)/install"
BUILD_TYPE="Release"
SKIP_BUILD=false
SKIP_INSTALL=false
PARALLEL_JOBS=$(nproc)
BUILD_DEMOS=true
BUILD_EXTRAS=true
BUILD_MATH=true
BUILD_TESTS=false
BUILD_UTIL=true
BUILD_XML=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --third-party-prefix)
            THIRD_PARTY_PREFIX="$2"
            shift 2
            ;;
        --build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-install)
            SKIP_INSTALL=true
            shift
            ;;
        --jobs)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        --build-demos)
            BUILD_DEMOS=true
            shift
            ;;
        --no-build-demos)
            BUILD_DEMOS=false
            shift
            ;;
        --build-extras)
            BUILD_EXTRAS=true
            shift
            ;;
        --no-build-extras)
            BUILD_EXTRAS=false
            shift
            ;;
        --build-tests)
            BUILD_TESTS=true
            shift
            ;;
        --no-build-tests)
            BUILD_TESTS=false
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --install-prefix <path>      Installation prefix (default: \$RL_ROOT/install)"
            echo "  --third-party-prefix <path>  Third-party dependencies prefix (default: \$RL_ROOT/../rl-3rdparty/install)"
            echo "  --build-type <type>          Build type: Release, Debug, RelWithDebInfo, MinSizeRel (default: Release)"
            echo "  --skip-build                 Skip building, only configure"
            echo "  --skip-install               Skip installation"
            echo "  --jobs <N>                   Number of parallel jobs (default: all available cores)"
            echo "  --build-demos                Build demos (default: enabled)"
            echo "  --no-build-demos             Don't build demos"
            echo "  --build-tests                Build tests (default: disabled)"
            echo "  --no-build-tests             Don't build tests"
            echo "  -h, --help                   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "Robotics Library Build Script"
echo "========================================"
echo ""

# Check CMake version
echo "Checking CMake version..."
if ! command -v cmake &> /dev/null; then
    echo "ERROR: CMake not found. Please install CMake 3.1 or later."
    exit 1
fi

CMAKE_VERSION=$(cmake --version | head -n1)
echo "Found: $CMAKE_VERSION"

# Verify third-party dependencies exist
echo "Checking third-party dependencies..."
if [ ! -d "$THIRD_PARTY_PREFIX" ]; then
    echo "ERROR: Third-party dependencies not found at: $THIRD_PARTY_PREFIX"
    echo "Please build rl-3rdparty first using build-3rdparty.sh"
    exit 1
fi
echo "Found third-party dependencies at: $THIRD_PARTY_PREFIX"
echo ""

echo "Build Configuration:"
echo "  Build Type: $BUILD_TYPE"
echo "  Install Prefix: $INSTALL_PREFIX"
echo "  Third-Party Prefix: $THIRD_PARTY_PREFIX"
echo "  Parallel Jobs: $PARALLEL_JOBS"
echo "  Build Demos: $BUILD_DEMOS"
echo "  Build Extras: $BUILD_EXTRAS"
echo "  Build Math: $BUILD_MATH"
echo "  Build Tests: $BUILD_TESTS"
echo "  Build Util: $BUILD_UTIL"
echo "  Build XML: $BUILD_XML"
echo ""

# Create build directory
BUILD_DIR="${RL_ROOT}/build"
if [ ! -d "$BUILD_DIR" ]; then
    echo "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Configure CMake
echo "Configuring CMake..."
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_PREFIX_PATH="$THIRD_PARTY_PREFIX" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.1 \
    -DRL_BUILD_DEMOS="$([ "$BUILD_DEMOS" = true ] && echo "ON" || echo "OFF")" \
    -DRL_BUILD_EXTRAS="$([ "$BUILD_EXTRAS" = true ] && echo "ON" || echo "OFF")" \
    -DRL_BUILD_MATH="$([ "$BUILD_MATH" = true ] && echo "ON" || echo "OFF")" \
    -DRL_BUILD_TESTS="$([ "$BUILD_TESTS" = true ] && echo "ON" || echo "OFF")" \
    -DRL_BUILD_UTIL="$([ "$BUILD_UTIL" = true ] && echo "ON" || echo "OFF")" \
    -DRL_BUILD_XML="$([ "$BUILD_XML" = true ] && echo "ON" || echo "OFF")"

if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed!"
    exit 1
fi

echo "Configuration successful!"
echo ""

# Build RL
if [ "$SKIP_BUILD" = false ]; then
    echo "Building Robotics Library (this may take some time)..."
    cmake --build . --parallel "$PARALLEL_JOBS"
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Build failed!"
        exit 1
    fi
    
    echo "Build successful!"
    echo ""
else
    echo "Skipping build (--skip-build specified)"
    echo ""
fi

# Install RL
if [ "$SKIP_INSTALL" = false ]; then
    echo "Installing Robotics Library..."
    cmake --build . --target install
    
    if [ $? -ne 0 ]; then
        echo "WARNING: Install failed, but build artifacts are in the build directory"
    else
        echo "Installation successful!"
        echo ""
        echo "Robotics Library installed to: $INSTALL_PREFIX"
    fi
else
    echo "Skipping install (--skip-install specified)"
fi

echo ""
echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""
