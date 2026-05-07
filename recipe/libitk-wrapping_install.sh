#!/bin/bash
set -euo pipefail
BUILD_DIR=${SRC_DIR}/build

# ITK's wrapping install rules do not cleanly partition by COMPONENT, so a
# narrow `cmake -DCOMPONENT=PythonWrappingRuntimeLibraries` install only
# captures itkConfig.py. Sweep all components that may carry wrapping payload
# into our prefix, then prune to keep only the Python wrapping content.
for component in PythonWrappingRuntimeLibraries Runtime RuntimeLibraries Libraries Unspecified libraries; do
    cmake -DCOMPONENT="${component}" -P "${BUILD_DIR}/cmake_install.cmake" || true
done

# Identify the python site-packages directory under PREFIX.
PYSITE=$(ls -d "${PREFIX}"/lib/python*/site-packages 2>/dev/null | head -1)
if [ -z "${PYSITE}" ]; then
    echo "ERROR: no lib/python*/site-packages directory under PREFIX" >&2
    exit 1
fi

# Stash the wrapping payload, wipe everything else, restore.
TMP=$(mktemp -d)
[ -d "${PYSITE}/itk" ]          && mv "${PYSITE}/itk"          "${TMP}/"
[ -f "${PYSITE}/itkConfig.py" ] && mv "${PYSITE}/itkConfig.py" "${TMP}/"

rm -rf "${PREFIX}/lib" "${PREFIX}/bin" "${PREFIX}/include" "${PREFIX}/share"

mkdir -p "${PYSITE}"
[ -d "${TMP}/itk" ]          && mv "${TMP}/itk"          "${PYSITE}/"
[ -f "${TMP}/itkConfig.py" ] && mv "${TMP}/itkConfig.py" "${PYSITE}/"
rmdir "${TMP}" 2>/dev/null || true
