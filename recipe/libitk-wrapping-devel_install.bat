set BUILD_DIR=%SRC_DIR%\bld
set ITK_CMAKE_DEST=%LIBRARY_PREFIX%\lib\cmake\ITK-6.0
set WRAP_CMAKE_DEST=%LIBRARY_PREFIX%\lib\cmake\Wrapping
set TYPEDEFS_DEST=%LIBRARY_PREFIX%\lib\cmake\ITK-6.0\Wrapping\Typedefs
set INCLUDE_DEST=%LIBRARY_PREFIX%\include\ITK-6.0

if not exist "%ITK_CMAKE_DEST%" mkdir "%ITK_CMAKE_DEST%"
if not exist "%WRAP_CMAKE_DEST%" mkdir "%WRAP_CMAKE_DEST%"

copy "%SRC_DIR%\CMake\WrappingConfigCommon.cmake" "%ITK_CMAKE_DEST%\WrappingConfigCommon.cmake"
if errorlevel 1 exit 1
copy "%SRC_DIR%\CMake\ITKSetPython3Vars.cmake" "%ITK_CMAKE_DEST%\ITKSetPython3Vars.cmake"
if errorlevel 1 exit 1

xcopy /E /I /Y "%SRC_DIR%\Wrapping" "%WRAP_CMAKE_DEST%"
if errorlevel 1 exit 1

REM Per-module wrapping/ subdirs (recursive find).
pushd "%SRC_DIR%"
setlocal enabledelayedexpansion
for /d /r "Modules" %%d in (wrapping) do (
    if exist "%%d" (
        set "_src=%%d"
        set "_rel=!_src:%SRC_DIR%\=!"
        if not exist "%INCLUDE_DEST%\!_rel!" mkdir "%INCLUDE_DEST%\!_rel!"
        xcopy /E /I /Y "!_src!" "%INCLUDE_DEST%\!_rel!"
    )
)
endlocal
popd

REM Build-tree wrapping artifacts (.i, .idx, .mdx, pyBase.i, python/*_ext.i)
REM not installed by upstream ITK. Required by SWIG at consumer build time.
if not exist "%TYPEDEFS_DEST%" mkdir "%TYPEDEFS_DEST%"
xcopy /E /I /Y "%BUILD_DIR%\Wrapping\Typedefs" "%TYPEDEFS_DEST%"
