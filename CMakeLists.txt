cmake_minimum_required(VERSION 3.22)

# Simple JUCE Project
project(JuceProject VERSION 0.0.1 LANGUAGES C CXX)

# Set C++ standard - using C++20 for modern language features
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable modern CMake policies
cmake_policy(SET CMP0063 NEW) # Honor visibility properties
cmake_policy(SET CMP0077 NEW) # option() honors normal variables

# Compiler-specific options
if(MSVC)
    # MSVC compiler options
    # /EHsc: Enable C++ exception handling (required by JUCE)
    # /W4: Warning level 4
    # /permissive-: Conformance mode for stricter C++ standards compliance
    # /Zc:__cplusplus: Enable correct __cplusplus macro value
    add_compile_options(/EHsc /W4 /permissive- /Zc:__cplusplus)
else()
    # GCC/Clang compiler options - enable comprehensive warnings
    add_compile_options(-Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -Wunused -Wformat=2)
    # Note: -Werror treats all warnings as errors and is best enabled only after the codebase is warning-free.
endif()

# Build type defaults
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to 'Debug' as none was specified.")
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Plugin installation directory (optional, for development convenience)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Install prefix" FORCE)
endif()

# Prefer JUCE from third_party/JUCE (git submodule). Fallback to FetchContent if not present.
if(EXISTS "${CMAKE_SOURCE_DIR}/third_party/JUCE/CMakeLists.txt")
    message(STATUS "Using JUCE from third_party/JUCE (submodule)")
    add_subdirectory("${CMAKE_SOURCE_DIR}/third_party/JUCE" EXCLUDE_FROM_ALL)
else()
    include(FetchContent)
    FetchContent_Declare(
        JUCE
        GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
        GIT_TAG 8.0.10
        GIT_SHALLOW TRUE
        GIT_PROGRESS TRUE
    )
    FetchContent_MakeAvailable(JUCE)
endif()

# =============================================================================
# PLUGIN METADATA - Single Source of Truth
# =============================================================================
# Edit these values to create a new plugin. All build outputs, scripts, and
# source code will automatically use these values.

set(PLUGIN_NAME "DSP-JUCE Plugin")        # User-facing product name (can contain spaces)
set(PLUGIN_TARGET "JucePlugin")        # CMake target name (no spaces, used for directories)
set(PLUGIN_VERSION "0.0.1")               # Semantic version number
set(PLUGIN_COMPANY_NAME "MyCompany")      # Company/developer name
set(PLUGIN_COMPANY_WEBSITE "https://mycompany.com")  # Company website URL
set(PLUGIN_DESCRIPTION "Advanced DSP audio processing plugin")  # Short description

# Plugin identification codes (JUCE/AU/AAX requirements)
# PLUGIN_MANUFACTURER_CODE: 4 characters, at least one uppercase letter
# PLUGIN_CODE: 4 characters, at least one uppercase letter (first char uppercase for GarageBand compatibility)
set(PLUGIN_MANUFACTURER_CODE "Mcmp")      # Manufacturer code
set(PLUGIN_CODE "Dsp1")                   # Plugin code

# Auto-generate bundle identifier in reverse-DNS format (com.company.plugin)
string(TOLOWER "${PLUGIN_COMPANY_NAME}" COMPANY_LOWER)
string(REPLACE " " "" COMPANY_LOWER "${COMPANY_LOWER}")
string(TOLOWER "${PLUGIN_TARGET}" TARGET_LOWER)
set(PLUGIN_BUNDLE_ID "com.${COMPANY_LOWER}.${TARGET_LOWER}")

# Validate manufacturer codes
string(LENGTH "${PLUGIN_MANUFACTURER_CODE}" MANUF_LEN)
string(LENGTH "${PLUGIN_CODE}" CODE_LEN)
if(NOT MANUF_LEN EQUAL 4)
    message(FATAL_ERROR "PLUGIN_MANUFACTURER_CODE must be exactly 4 characters, got ${MANUF_LEN}")
endif()
if(NOT CODE_LEN EQUAL 4)
    message(FATAL_ERROR "PLUGIN_CODE must be exactly 4 characters, got ${CODE_LEN}")
endif()

# Validate version consistency
if(NOT "${PLUGIN_VERSION}" STREQUAL "${PROJECT_VERSION}")
    message(FATAL_ERROR
        "Version mismatch detected!\n"
        "  PLUGIN_VERSION: ${PLUGIN_VERSION}\n"
        "  PROJECT_VERSION: ${PROJECT_VERSION}\n"
        "  Please ensure both versions match in CMakeLists.txt:\n"
        "    project(...) VERSION sets PROJECT_VERSION\n"
        "    set(PLUGIN_VERSION ...) sets PLUGIN_VERSION\n"
        "PLUGIN_VERSION and PROJECT_VERSION must match for consistency"
    )
endif()

# Export metadata to shell script for build validation scripts
file(WRITE "${CMAKE_BINARY_DIR}/plugin_metadata.sh"
    "#!/bin/bash\n"
    "# Auto-generated plugin metadata - DO NOT EDIT\n"
    "# Generated from CMakeLists.txt on ${CMAKE_SYSTEM_NAME}\n\n"
    "export PROJECT_NAME_TARGET=\"${PLUGIN_TARGET}\"\n"
    "export PROJECT_NAME_PRODUCT=\"${PLUGIN_NAME}\"\n"
    "export PROJECT_VERSION=\"${PLUGIN_VERSION}\"\n"
    "export PROJECT_COMPANY=\"${PLUGIN_COMPANY_NAME}\"\n"
    "export PROJECT_BUNDLE_ID=\"${PLUGIN_BUNDLE_ID}\"\n"
)

message(STATUS "Plugin: ${PLUGIN_NAME} v${PLUGIN_VERSION}")
message(STATUS "Company: ${PLUGIN_COMPANY_NAME}")
message(STATUS "Bundle ID: ${PLUGIN_BUNDLE_ID}")
message(STATUS "Target: ${PLUGIN_TARGET}")

# Note: JUCE uses British spelling "artefacts" for output directories
# The build system will create ${PLUGIN_TARGET}_artefacts/ automatically

# =============================================================================
# JUCE PLUGIN CONFIGURATION
# =============================================================================
# Create a JUCE plugin using the metadata defined above

# Define plugin formats based on platform
if(APPLE)
    set(PLUGIN_FORMATS VST3 Standalone AU)
    message(STATUS "Building for macOS: VST3, Standalone, AU")
else()
    set(PLUGIN_FORMATS VST3 Standalone)
    message(STATUS "Building for ${CMAKE_SYSTEM_NAME}: VST3, Standalone")
endif()

juce_add_plugin(${PLUGIN_TARGET}
    VERSION ${PLUGIN_VERSION}
    COMPANY_NAME "${PLUGIN_COMPANY_NAME}"
    COMPANY_WEBSITE "${PLUGIN_COMPANY_WEBSITE}"
    PRODUCT_NAME "${PLUGIN_NAME}"
    DESCRIPTION "${PLUGIN_DESCRIPTION}"
    BUNDLE_ID ${PLUGIN_BUNDLE_ID}
    PLUGIN_MANUFACTURER_CODE ${PLUGIN_MANUFACTURER_CODE}
    PLUGIN_CODE ${PLUGIN_CODE}
    FORMATS ${PLUGIN_FORMATS}
    IS_SYNTH FALSE
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT FALSE
    IS_MIDI_EFFECT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE
    COPY_PLUGIN_AFTER_BUILD FALSE
    MICROPHONE_PERMISSION_ENABLED TRUE
    MICROPHONE_PERMISSION_TEXT "This app needs microphone access for audio input"
)

# Add source files
target_sources(${PLUGIN_TARGET} PRIVATE
    src/Main.cpp
    src/MainComponent.cpp
    src/MainComponent.h
    src/PluginEditor.cpp
    src/PluginEditor.h
)

# Set target properties
set_target_properties(${PLUGIN_TARGET} PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN TRUE
)

# Link JUCE modules
target_link_libraries(${PLUGIN_TARGET} PRIVATE
    juce::juce_audio_basics
    juce::juce_audio_devices
    juce::juce_audio_formats
    juce::juce_audio_processors
    juce::juce_audio_utils
    juce::juce_core
    juce::juce_data_structures
    juce::juce_dsp
    juce::juce_events
    juce::juce_graphics
    juce::juce_gui_basics
    juce::juce_gui_extra
)

# Compile definitions
target_compile_definitions(${PLUGIN_TARGET} PRIVATE
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_REPLACE_VST2=0
    JUCE_APPLICATION_NAME_STRING="$<TARGET_PROPERTY:${PLUGIN_TARGET},JUCE_PRODUCT_NAME>"
    JUCE_APPLICATION_VERSION_STRING="$<TARGET_PROPERTY:${PLUGIN_TARGET},JUCE_VERSION>"
)

# Platform-specific settings
if(WIN32)
    target_compile_definitions(${PLUGIN_TARGET} PRIVATE
        JUCE_WIN32_LEAN_AND_MEAN=1
    )
elseif(APPLE)
    target_compile_definitions(${PLUGIN_TARGET} PRIVATE
        JUCE_USE_OBJC_ARC=1
    )
endif()

# Debug-specific settings
target_compile_definitions(${PLUGIN_TARGET} PRIVATE
    $<$<CONFIG:Debug>:JUCE_DEBUG=1>
    $<$<CONFIG:Debug>:DEBUG=1>
    $<$<CONFIG:Debug>:_DEBUG=1>
)

# Release-specific settings  
target_compile_definitions(${PLUGIN_TARGET} PRIVATE
    $<$<CONFIG:Release>:JUCE_DEBUG=0>
    $<$<CONFIG:Release>:NDEBUG=1>
)