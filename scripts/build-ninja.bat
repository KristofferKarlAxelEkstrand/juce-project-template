@echo off
REM build-ninja.bat
REM Builds the CMake project using Ninja with MSVC compiler.
REM This script sets up the Visual Studio environment before running the build.

echo Initializing Visual Studio 2022 x64 environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

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
echo Build successful! Artifacts are in: build/ninja/JucePlugin_artefacts/Debug/
