@echo off
REM build-ninja.bat
REM Builds the CMake project using Ninja with MSVC compiler.
REM This script sets up the Visual Studio environment before running the build.

setlocal enabledelayedexpansion

REM Default build configuration
set "BUILD_CONFIG=Debug"

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :start_build
if "%~1"=="/?" goto :help
if "%~1"=="/help" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-h" goto :help
if "%~1"=="--config" (
    if "%~2"=="" (
        echo [ERROR] --config requires an argument (Debug or Release)
        exit /b 1
    )
    set "BUILD_CONFIG=%~2"
    shift
    shift
    goto :parse_args
)
echo [ERROR] Unknown option: %~1
echo Use /? or --help for usage information
exit /b 1

:help
echo Usage: %~nx0 [OPTIONS]
echo.
echo Build the project using Ninja build system for fast incremental builds.
echo.
echo Options:
echo     --config CONFIG    Build configuration (Debug or Release, default: Debug)
echo     /?, /help, --help, -h    Show this help message
echo.
echo Examples:
echo     %~nx0                    # Build Debug configuration
echo     %~nx0 --config Release   # Build Release configuration
echo.
echo Prerequisites:
echo     Run 'scripts\configure-ninja.bat' first to configure the build.
echo.
echo Output:
echo     Build artifacts in build\ninja\JucePlugin_artefacts\[Debug^|Release]\
exit /b 0

:start_build

REM Validate build configuration
if not "%BUILD_CONFIG%"=="Debug" if not "%BUILD_CONFIG%"=="Release" (
    echo [ERROR] Invalid build configuration: %BUILD_CONFIG%
    echo Must be 'Debug' or 'Release'
    exit /b 1
)

echo Initializing Visual Studio x64 environment...

REM Try Visual Studio installation paths (2026, 2022, 2019 - newest first)
REM Supports Community, Professional, and Enterprise editions
set "VCVARSALL="
set "VS_VERSION="

REM Try VS 2026 first
if exist "C:\Program Files\Microsoft Visual Studio\2026\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2026\Community\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2026"
) else if exist "C:\Program Files\Microsoft Visual Studio\2026\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2026\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2026"
) else if exist "C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2026\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2026"
)

REM Try VS 2022 if 2026 not found
if not defined VCVARSALL (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2022"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2022"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2022"
    )
)

REM Try VS 2019 if 2022 not found (check both Program Files locations)
if not defined VCVARSALL (
    if exist "C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
    ) else if exist "C:\Program Files\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
    ) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
    )
)

if not defined VCVARSALL (
    echo [ERROR] Visual Studio 2019, 2022, or 2026 not found.
    echo.
    echo Please install Visual Studio (Community, Professional, or Enterprise^)
    echo with C++ Desktop Development workload.
    echo.
    echo Download from: https://visualstudio.microsoft.com/downloads/
    exit /b 1
)

echo Using Visual Studio %VS_VERSION%

REM Initialize Visual Studio environment
call "%VCVARSALL%" x64 >nul

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to initialize Visual Studio environment.
    echo.
    echo Try running this command manually:
    echo   "%VCVARSALL%" x64
    exit /b 1
)

echo Building with Ninja (%BUILD_CONFIG% configuration^)...
cmake --build build/ninja --config %BUILD_CONFIG%

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed.
    echo.
    echo Common fixes:
    echo   - Run configure-ninja.bat first to configure the build
    echo   - Check that build/ninja directory exists
    echo   - Review error messages above for specific issues
    exit /b 1
)

echo.
echo Build successful! Artifacts are in: build\ninja\JucePlugin_artefacts\%BUILD_CONFIG%\
