set BUILD_DIR=%SRC_DIR%\bld
cmake -DCOMPONENT=Runtime -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=RuntimeLibraries -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=Libraries -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=Unspecified -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=libraries -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1

REM Evict Python wrapping payload from libitk; it belongs in libitk-wrapping.
for /d %%P in ("%LIBRARY_PREFIX%\Lib\site-packages\itk") do (
    if exist "%%P" rmdir /S /Q "%%P"
)
if exist "%LIBRARY_PREFIX%\Lib\site-packages\itkConfig.py" del /Q "%LIBRARY_PREFIX%\Lib\site-packages\itkConfig.py"
