#!/usr/bin/env python3
"""Write a relocatable cmake_install.cmake shim for ITKPythonPackage compatibility.

ITKPythonPackage calls include("${ITK_BINARY_DIR}/cmake_install.cmake") with
COMPONENT=ITKCommonPythonWheelRuntimeLibraries (suffix PythonWheel).
This feedstock builds with WRAP_ITK_INSTALL_COMPONENT_IDENTIFIER=PythonWrapping
(suffix PythonWrapping), so names don't match.  The shim maps PythonWheel*
requests to files already installed in the conda prefix.
"""
import argparse
import os
import re
import sys


def find_itk_version(build_dir):
    # ITK generates ITKConfigVersion.cmake at the build root during cmake configure.
    # Each output gets its own isolated staging prefix, so the prefix cannot be used.
    version_file = os.path.join(build_dir, "ITKConfigVersion.cmake")
    if not os.path.exists(version_file):
        sys.exit(f"ERROR: {version_file} not found")
    with open(version_file) as f:
        content = f.read()
    m = re.search(r'set\s*\(\s*PACKAGE_VERSION\s+"([^"]+)"\s*\)', content)
    if not m:
        sys.exit(f"ERROR: PACKAGE_VERSION not found in {version_file}")
    full_version = m.group(1)  # e.g. "6.0.0"
    parts = full_version.split(".")
    return f"ITK-{parts[0]}.{parts[1]}"  # e.g. "ITK-6.0"


SHIM_TEMPLATE = r"""# Relocatable cmake_install.cmake — conda libitk-wrapping.
# Maps *PythonWheelRuntimeLibraries component names to pre-installed conda files.

get_filename_component(_ipp_itk_cmake_dir "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
get_filename_component(_ipp_cmake_dir     "${_ipp_itk_cmake_dir}" DIRECTORY)
get_filename_component(_ipp_lib_dir       "${_ipp_cmake_dir}"     DIRECTORY)
get_filename_component(_ipp_conda_prefix  "${_ipp_lib_dir}"       DIRECTORY)

if(DEFINED CMAKE_INSTALL_COMPONENT AND NOT CMAKE_INSTALL_COMPONENT STREQUAL "")
  set(_ipp_component "${CMAKE_INSTALL_COMPONENT}")
elseif(DEFINED COMPONENT AND NOT COMPONENT STREQUAL "")
  set(_ipp_component "${COMPONENT}")
else()
  return()
endif()

if(NOT _ipp_component MATCHES "PythonWheelRuntimeLibraries$")
  return()
endif()

# Strip ITKPythonPackage's suffix (PythonWheelRuntimeLibraries) to get the module name.
# Note: this feedstock uses WRAP_ITK_INSTALL_COMPONENT_IDENTIFIER=PythonWrapping (not PythonWheel).
# The shim intentionally maps PythonWheel* → installed files so ITKPythonPackage can use
# the conda prefix as a build cache without recompiling ITK.
string(REGEX REPLACE "PythonWheelRuntimeLibraries$" "" _ipp_module "${_ipp_component}")

set(_ipp_sentinel "${CMAKE_INSTALL_PREFIX}/itk/.conda_global_done")
if(NOT EXISTS "${_ipp_sentinel}")
  file(GLOB _g "${_ipp_conda_prefix}/lib/python*/site-packages/itkConfig.py")
  if(_g)
    file(INSTALL ${_g} DESTINATION "${CMAKE_INSTALL_PREFIX}" USE_SOURCE_PERMISSIONS)
  endif()
  file(GLOB _g "${_ipp_conda_prefix}/lib/python*/site-packages/itk/__init__.py")
  if(_g)
    file(INSTALL ${_g} DESTINATION "${CMAKE_INSTALL_PREFIX}/itk" USE_SOURCE_PERMISSIONS)
  endif()
  file(GLOB _support_dir LIST_DIRECTORIES true
    "${_ipp_conda_prefix}/lib/python*/site-packages/itk/support")
  if(_support_dir)
    file(INSTALL ${_support_dir} DESTINATION "${CMAKE_INSTALL_PREFIX}/itk" USE_SOURCE_PERMISSIONS)
  endif()
  file(GLOB _g
    "${_ipp_conda_prefix}/lib/python*/site-packages/itk/Configuration/__init__.py")
  if(_g)
    file(INSTALL ${_g} DESTINATION "${CMAKE_INSTALL_PREFIX}/itk/Configuration"
         USE_SOURCE_PERMISSIONS)
  endif()
  file(WRITE "${_ipp_sentinel}" "done\n")
  message(STATUS "conda cmake_install: installed global itk package files")
endif()

file(GLOB _so
  "${_ipp_conda_prefix}/lib/python*/site-packages/itk/_${_ipp_module}Python.abi3.so"
  "${_ipp_conda_prefix}/lib/python*/site-packages/itk/_${_ipp_module}Python*.so")
if(_so)
  file(INSTALL ${_so} DESTINATION "${CMAKE_INSTALL_PREFIX}/itk" USE_SOURCE_PERMISSIONS)
endif()

file(GLOB _py
  "${_ipp_conda_prefix}/lib/python*/site-packages/itk/${_ipp_module}Python.py")
if(_py)
  file(INSTALL ${_py} DESTINATION "${CMAKE_INSTALL_PREFIX}/itk" USE_SOURCE_PERMISSIONS)
endif()

file(GLOB _cfg
  "${_ipp_conda_prefix}/lib/python*/site-packages/itk/Configuration/${_ipp_module}Config.py"
  "${_ipp_conda_prefix}/lib/python*/site-packages/itk/Configuration/${_ipp_module}_snake_case.py")
if(_cfg)
  file(INSTALL ${_cfg} DESTINATION "${CMAKE_INSTALL_PREFIX}/itk/Configuration"
       USE_SOURCE_PERMISSIONS)
endif()

list(LENGTH _so _ipp_n)
message(STATUS "conda cmake_install: ${_ipp_component}: ${_ipp_n} .so file(s) installed")
"""


def write_shim(prefix, itk_version):
    cmake_dir = os.path.join(prefix, "lib", "cmake", itk_version)
    os.makedirs(cmake_dir, exist_ok=True)
    shim_path = os.path.join(cmake_dir, "cmake_install.cmake")
    with open(shim_path, "w") as f:
        f.write(SHIM_TEMPLATE)
    print(f"Generated {shim_path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-dir", required=True,
                        help="CMake build directory (SRC_DIR/build)")
    parser.add_argument("--prefix", required=True,
                        help="Conda install prefix (PREFIX on Unix, LIBRARY_PREFIX on Windows)")
    args = parser.parse_args()
    write_shim(args.prefix, find_itk_version(args.build_dir))


if __name__ == "__main__":
    main()
