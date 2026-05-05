#!/bin/bash
set -euo pipefail
BUILD_DIR=${SRC_DIR}/build
cmake -DCOMPONENT=Development -P ${BUILD_DIR}/cmake_install.cmake
cmake -DCOMPONENT=Headers -P ${BUILD_DIR}/cmake_install.cmake

# CMake module-build helpers not covered by Development/Headers components.
# Required so external (remote-module) projects can find_package(ITK) and then
# include(ITKModuleExternal). See ITK CMakeLists.txt:836–850 for the upstream
# install set, which excludes these.
ITK_CMAKE_DEST="${PREFIX}/lib/cmake/ITK-6.0"
KWSTYLE_DEST="${PREFIX}/lib/cmake/Utilities/KWStyle"
mkdir -p "${ITK_CMAKE_DEST}"
mkdir -p "${KWSTYLE_DEST}"
for f in \
    ITKModuleExternal.cmake \
    ITKModuleMacros.cmake \
    ITKModuleDoxygen.cmake \
    ITKModuleHeaderTest.cmake \
    ITKModuleKWStyleTest.cmake \
    ITKModuleCPPCheckTest.cmake \
    ITKModuleTest.cmake \
    ITKExternalData.cmake \
    ITKDownloadSetup.cmake \
    ITKInitializeBuildType.cmake \
    ExternalData.cmake \
    ExternalData_config.cmake.in \
    ITKModuleInfo.cmake.in \
    ITKKWStyleConfig.cmake.in \
    CppcheckTargets.cmake \
    TopologicalSort.cmake
do
    cp "${SRC_DIR}/CMake/${f}" "${ITK_CMAKE_DEST}/${f}"
done

# ITKModuleKWStyleTest.cmake unconditionally includes
# ${ITK_CMAKE_DIR}/../Utilities/KWStyle/BuildKWStyle.cmake. Ship the file even
# when KWStyle isn't available at build time (the consumer's cmake will warn
# and skip the test, but the include must succeed).
cp "${SRC_DIR}/Utilities/KWStyle/BuildKWStyle.cmake" "${KWSTYLE_DEST}/BuildKWStyle.cmake"
cp "${SRC_DIR}/Utilities/KWStyle/KWStyle.cmake"      "${KWSTYLE_DEST}/KWStyle.cmake"

# itk_module_test header generation calls BuildHeaderTest.py via the same
# ${ITK_CMAKE_DIR}/../Utilities/Maintenance/ path convention.
MAINT_DEST="${PREFIX}/lib/cmake/Utilities/Maintenance"
mkdir -p "${MAINT_DEST}"
cp "${SRC_DIR}/Utilities/Maintenance/BuildHeaderTest.py" "${MAINT_DEST}/BuildHeaderTest.py"
