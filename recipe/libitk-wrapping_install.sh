#!/bin/bash
set -euo pipefail
BUILD_DIR=${SRC_DIR}/build

cmake -DCOMPONENT=PythonWrappingRuntimeLibraries -P "${BUILD_DIR}/cmake_install.cmake"
