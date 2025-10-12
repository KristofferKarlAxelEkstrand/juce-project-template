@echo off
REM configure-ninja.bat
REM Configures the CMake project using the Ninja generator with MSVC compiler.
REM This script sets up the Visual Studio environment before running CMake.

REM Check for help flag
if "%~1"=="/?" goto :help
if "%~1"=="/help" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-h" goto :help

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
    echo [ERROR] Visual Studio 2022 not found.
    echo.
    echo Please install Visual Studio 2022 (Community, Professional, or Enterprise^)
    echo with C++ Desktop Development workload.
    echo.
    echo Checked paths:
    echo   - C:\Program Files\Microsoft Visual Studio\2022\Community\
    echo   - C:\Program Files\Microsoft Visual Studio\2022\Professional\
    echo   - C:\Program Files\Microsoft Visual Studio\2022\Enterprise\
    echo.
    echo Download from: https://visualstudio.microsoft.com/downloads/
    exit /b 1
)

REM Initialize Visual Studio environment
call "%VCVARSALL%" x64 >nul

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to initialize Visual Studio environment.
    echo.
    echo Try running this command manually:
    echo   "%VCVARSALL%" x64
    exit /b 1
)

echo Configuring CMake with Ninja preset...
cmake --preset=ninja

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] CMake configuration failed.
    echo.
    echo Common fixes:
    echo   - Ensure CMake is installed and in PATH
    echo   - Check CMakeLists.txt for errors
    echo   - Review error messages above for specific issues
    exit /b 1
)

echo.
echo Configuration successful! Build directory: build\ninja
echo You can now build with: scripts\build-ninja.bat
exit /b 0

:help
echo Usage: %~nx0 [OPTIONS]
echo.
echo Configure the CMake project using Ninja build system with MSVC compiler.
echo.
echo Options:
echo     /?, /help, --help, -h    Show this help message
echo.
echo Examples:
echo     %~nx0                    # Configure project
echo.
echo Prerequisites:
echo     - Visual Studio 2022 with C++ Desktop Development workload
echo     - CMake 3.22 or higher
echo     - Ninja build system
echo.
echo Output:
echo     CMake configuration in build\ninja directory
echo.
echo Next Steps:
echo     Build the project with: scripts\build-ninja.bat
exit /b 0
