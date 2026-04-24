set BUILD_DIR=%SRC_DIR%\bld

cmake -DCOMPONENT=PythonWrappingRuntimeLibraries -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1

python "%RECIPE_DIR%\generate_cmake_shim.py" ^
    --build-dir "%BUILD_DIR%" ^
    --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
