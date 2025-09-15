cmake_minimum_required(VERSION 3.22)

# Simple JUCE Project
project(SimpleJuceApp VERSION 1.0.0 LANGUAGES C CXX)

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
    add_compile_options(/W4 /permissive- /Zc:__cplusplus)
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

# Fetch JUCE automatically (not added to git)
include(FetchContent)
FetchContent_Declare(
    JUCE
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG 8.0.9
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
)

# Make JUCE available
FetchContent_MakeAvailable(JUCE)

# Create a simple audio application
juce_add_plugin(DSPJucePlugin
    VERSION 1.0.0
    COMPANY_NAME "MyCompany"
    PRODUCT_NAME "DSP-JUCE Plugin"
    BUNDLE_ID com.mycompany.dspjuceplugin
    MICROPHONE_PERMISSION_ENABLED TRUE
    MICROPHONE_PERMISSION_TEXT "This app needs microphone access for audio input"
    PLUGIN_FORMATS VST3 AU Standalone
)

# Add source files
target_sources(DSPJucePlugin PRIVATE
    src/Main.cpp
    src/MainComponent.cpp
    src/MainComponent.h
)

# Set target properties
set_target_properties(DSPJucePlugin PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN TRUE
)

# Link JUCE modules
target_link_libraries(DSPJucePlugin PRIVATE
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
target_compile_definitions(DSPJucePlugin PRIVATE
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_APPLICATION_NAME_STRING="$<TARGET_PROPERTY:DSPJucePlugin,JUCE_PRODUCT_NAME>"
    JUCE_APPLICATION_VERSION_STRING="$<TARGET_PROPERTY:DSPJucePlugin,JUCE_VERSION>"
)

# Platform-specific settings
if(WIN32)
    target_compile_definitions(DSPJucePlugin PRIVATE
        JUCE_WIN32_LEAN_AND_MEAN=1
    )
elseif(APPLE)
    target_compile_definitions(DSPJucePlugin PRIVATE
        JUCE_USE_OBJC_ARC=1
    )
endif()

# Debug-specific settings
target_compile_definitions(DSPJucePlugin PRIVATE
    $<$<CONFIG:Debug>:JUCE_DEBUG=1>
    $<$<CONFIG:Debug>:DEBUG=1>
    $<$<CONFIG:Debug>:_DEBUG=1>
)

# Release-specific settings  
target_compile_definitions(DSPJucePlugin PRIVATE
    $<$<CONFIG:Release>:JUCE_DEBUG=0>
    $<$<CONFIG:Release>:NDEBUG=1>
)