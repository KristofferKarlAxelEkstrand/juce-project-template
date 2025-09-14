cmake_minimum_required(VERSION 3.22)

# Simple JUCE Project
project(SimpleJuceApp VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Fetch JUCE automatically (not added to git)
include(FetchContent)
FetchContent_Declare(
    JUCE
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG 8.0.9
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(JUCE)

# Create a simple audio application
juce_add_gui_app(SimpleJuceApp
    VERSION 1.0.0
    COMPANY_NAME "MyCompany"
    PRODUCT_NAME "Simple JUCE App"
    BUNDLE_ID com.mycompany.simplejuceapp
)

# Add source files
target_sources(SimpleJuceApp PRIVATE
    src/Main.cpp
    src/MainComponent.cpp
    src/MainComponent.h
)

# Link JUCE modules
target_link_libraries(SimpleJuceApp PRIVATE
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
target_compile_definitions(SimpleJuceApp PRIVATE
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
)