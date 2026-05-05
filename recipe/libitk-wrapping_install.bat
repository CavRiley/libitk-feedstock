set BUILD_DIR=%SRC_DIR%\bld

cmake -DCOMPONENT=PythonWrappingRuntimeLibraries -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
