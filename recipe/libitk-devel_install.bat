set BUILD_DIR=%SRC_DIR%\bld
cmake -DCOMPONENT=Development -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=DebugDevel -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=cpplibraries  -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1
cmake -DCOMPONENT=Headers -P %BUILD_DIR%\cmake_install.cmake
if errorlevel 1 exit 1

set ITK_CMAKE_DEST=%LIBRARY_PREFIX%\lib\cmake\ITK-6.0
set KWSTYLE_DEST=%LIBRARY_PREFIX%\lib\cmake\Utilities\KWStyle
if not exist "%ITK_CMAKE_DEST%" mkdir "%ITK_CMAKE_DEST%"
if not exist "%KWSTYLE_DEST%" mkdir "%KWSTYLE_DEST%"
for %%f in (^
    ITKModuleExternal.cmake ^
    ITKModuleMacros.cmake ^
    ITKModuleDoxygen.cmake ^
    ITKModuleHeaderTest.cmake ^
    ITKModuleKWStyleTest.cmake ^
    ITKModuleCPPCheckTest.cmake ^
    ITKModuleTest.cmake ^
    ITKExternalData.cmake ^
    ITKDownloadSetup.cmake ^
    ITKInitializeBuildType.cmake ^
    ExternalData.cmake ^
    ExternalData_config.cmake.in ^
    ITKModuleInfo.cmake.in ^
    ITKKWStyleConfig.cmake.in ^
    CppcheckTargets.cmake ^
    TopologicalSort.cmake^
) do (
    copy "%SRC_DIR%\CMake\%%f" "%ITK_CMAKE_DEST%\%%f"
    if errorlevel 1 exit 1
)
copy "%SRC_DIR%\Utilities\KWStyle\BuildKWStyle.cmake" "%KWSTYLE_DEST%\BuildKWStyle.cmake"
if errorlevel 1 exit 1
copy "%SRC_DIR%\Utilities\KWStyle\KWStyle.cmake" "%KWSTYLE_DEST%\KWStyle.cmake"
if errorlevel 1 exit 1

set MAINT_DEST=%LIBRARY_PREFIX%\lib\cmake\Utilities\Maintenance
if not exist "%MAINT_DEST%" mkdir "%MAINT_DEST%"
copy "%SRC_DIR%\Utilities\Maintenance\BuildHeaderTest.py" "%MAINT_DEST%\BuildHeaderTest.py"
if errorlevel 1 exit 1
