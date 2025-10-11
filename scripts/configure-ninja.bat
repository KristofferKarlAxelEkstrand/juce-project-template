@echo off
REM configure-ninja.bat
REM Configures the CMake project using the Ninja generator with MSVC compiler.
REM This script sets up the Visual Studio environment before running CMake.

echo Initializing Visual Studio 2022 x64 environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to initialize Visual Studio environment.
    echo Make sure Visual Studio 2022 with C++ Desktop Development is installed.
    exit /b 1
)

echo Configuring CMake with Ninja preset...
cmake --preset=ninja

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake configuration failed.
    exit /b 1
)

echo.
echo Configuration successful! Build directory: build/ninja
echo You can now build with: cmake --build build/ninja
