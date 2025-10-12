@echo off
REM run-standalone.bat
REM Launch standalone application using metadata from CMake configuration
REM This script reads plugin metadata dynamically to avoid hardcoded names

setlocal enabledelayedexpansion

REM Check for help flag
if "%~1"=="/?" goto :help
if "%~1"=="/help" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-h" goto :help

REM Determine build configuration and directory
set "BUILD_CONFIG=%~1"
set "BUILD_DIR=%~2"

if "%BUILD_CONFIG%"=="" set "BUILD_CONFIG=Debug"
if "%BUILD_DIR%"=="" set "BUILD_DIR=build\ninja"

REM Get project root (parent of scripts directory)
set "PROJECT_ROOT=%~dp0.."
cd /d "%PROJECT_ROOT%"

REM Construct path to metadata file
set "METADATA_FILE=%BUILD_DIR%\plugin_metadata.sh"

if not exist "%METADATA_FILE%" (
    echo [ERROR] Metadata file not found: %METADATA_FILE%
    echo Run configure-ninja.bat or cmake --preset=default first.
    exit /b 1
)

REM Parse metadata file (simplified for batch)
REM Read PROJECT_NAME_TARGET and PROJECT_NAME_PRODUCT from metadata file
for /f "tokens=2 delims==" %%a in ('findstr "PROJECT_NAME_TARGET=" "%METADATA_FILE%"') do (
    set "PROJECT_NAME_TARGET=%%a"
    REM Remove quotes and export prefix
    set "PROJECT_NAME_TARGET=!PROJECT_NAME_TARGET:"=!"
)

for /f "tokens=2 delims==" %%a in ('findstr "PROJECT_NAME_PRODUCT=" "%METADATA_FILE%"') do (
    set "PROJECT_NAME_PRODUCT=%%a"
    REM Remove quotes and export prefix
    set "PROJECT_NAME_PRODUCT=!PROJECT_NAME_PRODUCT:"=!"
)

if "%PROJECT_NAME_TARGET%"=="" (
    echo [ERROR] Could not read PROJECT_NAME_TARGET from metadata file
    exit /b 1
)

if "%PROJECT_NAME_PRODUCT%"=="" (
    echo [ERROR] Could not read PROJECT_NAME_PRODUCT from metadata file
    exit /b 1
)

REM Construct path to standalone application
set "STANDALONE_APP=%BUILD_DIR%\%PROJECT_NAME_TARGET%_artefacts\%BUILD_CONFIG%\Standalone\%PROJECT_NAME_PRODUCT%.exe"

if not exist "%STANDALONE_APP%" (
    echo [ERROR] Standalone app not found: %STANDALONE_APP%
    echo Build the project first with build-ninja.bat
    exit /b 1
)

echo Launching %PROJECT_NAME_PRODUCT% ^(%BUILD_CONFIG%^)...
start "" "%STANDALONE_APP%"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to launch application
    exit /b 1
)

echo Launched successfully.
exit /b 0

:help
echo Usage: %~nx0 [BUILD_CONFIG] [BUILD_DIR]
echo.
echo Launch the standalone application using metadata from CMake.
echo.
echo Arguments:
echo     BUILD_CONFIG    Build configuration (Debug or Release, default: Debug)
echo     BUILD_DIR       Build directory (default: build\ninja)
echo.
echo Options:
echo     /?, /help, --help, -h    Show this help message
echo.
echo Examples:
echo     %~nx0                        # Launch Debug build from build\ninja
echo     %~nx0 Release                # Launch Release build from build\ninja
echo     %~nx0 Debug build\default    # Launch Debug build from build\default
echo.
echo Note:
echo     This script reads plugin metadata from the generated plugin_metadata.sh
echo     file in the build directory, so it works regardless of plugin name changes.
exit /b 0
