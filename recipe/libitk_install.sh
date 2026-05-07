#!/bin/bash
set -euo pipefail
BUILD_DIR=${SRC_DIR}/build
components="Runtime RuntimeLibraries Libraries Unspecified libraries"
for component in ${components}; do
    cmake -DCOMPONENT=${component} -P ${BUILD_DIR}/cmake_install.cmake
done

# ITK's wrapping install rules do not cleanly partition by COMPONENT — pieces
# of the Python wrapping payload land in Unspecified / libraries even when
# WRAP_ITK_INSTALL_COMPONENT_IDENTIFIER is set. Evict the wrapping payload
# from libitk so it can be claimed by libitk-wrapping instead.
rm -rf "${PREFIX}"/lib/python*/site-packages/itk
rm -f  "${PREFIX}"/lib/python*/site-packages/itkConfig.py
rm -f  "${PREFIX}"/lib/python*/site-packages/__pycache__/itkConfig*.pyc
