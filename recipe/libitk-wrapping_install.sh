#!/bin/bash
BUILD_DIR=${SRC_DIR}/build

cmake -DCOMPONENT=PythonWrappingRuntimeLibraries -P ${BUILD_DIR}/cmake_install.cmake

python "${RECIPE_DIR}/generate_cmake_shim.py" \
    --build-dir "${BUILD_DIR}" \
    --prefix "${PREFIX}"
