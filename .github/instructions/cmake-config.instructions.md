---
applyTo:
  - '**/CMakeLists.txt'
  - '*.cmake'
---

# CMake Configuration Instructions

Use modern CMake 3.22+ practices with proper JUCE integration. Focus on maintainable, cross-platform build
configurations with C++20 support.

## Modern CMake Practices

- Use target-based approach (target_link_libraries, target_include_directories)
- Prefer FetchContent over ExternalProject for dependencies
- Use generator expressions for conditional compilation
- Set minimum required CMake version explicitly
- Use proper visibility keywords (PUBLIC, PRIVATE, INTERFACE)

## JUCE Integration

- Use FetchContent to download JUCE automatically
- Never commit JUCE source to repository
- Use juce_add_gui_app() or juce_add_plugin() for applications
- Link JUCE modules as targets (juce::juce_core, etc.)
- Set JUCE compile definitions appropriately

## Build Configuration

- Support Debug and Release configurations
- Use CMakePresets.json for VS Code integration
- Set appropriate compiler flags for each platform
- Configure proper install targets if needed
- Handle platform-specific requirements clearly

## Dependencies

- Use find_package() for system libraries
- Use FetchContent for header-only libraries
- Version pin all external dependencies
- Provide fallbacks for optional dependencies
- Document all required dependencies clearly

## Cross-Platform Support

- Test build configuration on all target platforms
- Use CMake's platform detection appropriately
- Handle platform-specific linker requirements
- Set correct runtime library linking (MSVC)
- Use proper file path separators and conventions
