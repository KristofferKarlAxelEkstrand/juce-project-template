@echo off
REM build-ninja.bat
REM Builds the CMake project using Ninja with MSVC compiler.
REM This script sets up the Visual Studio environment before running the build.

echo Initializing Visual Studio 2022 x64 environment...

REM Try common Visual Studio 2022 installation paths
REM Supports Community, Professional, and Enterprise editions
set "VCVARSALL="

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
)

if not defined VCVARSALL (
    echo ERROR: Visual Studio 2022 not found.
    echo Please install Visual Studio 2022 (Community, Professional, or Enterprise) with C++ Desktop Development workload.
    echo Checked paths:
    echo   - C:\Program Files\Microsoft Visual Studio\2022\Community\
    echo   - C:\Program Files\Microsoft Visual Studio\2022\Professional\
    echo   - C:\Program Files\Microsoft Visual Studio\2022\Enterprise\
    exit /b 1
)

REM Initialize Visual Studio environment
call "%VCVARSALL%" x64

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to initialize Visual Studio environment.
    exit /b 1
)

echo Building with Ninja...
cmake --build build/ninja

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed.
    exit /b 1
)

echo.
echo Build successful! Artifacts are in: build/ninja/JucePlugin_artefacts/
