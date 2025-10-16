# Clang in JUCE Project Template

This document explains how Clang is used for code formatting and quality enforcement in this JUCE project template.

## Purpose

Clang provides automated code formatting and static analysis for C++ source files. It ensures consistent style and helps
catch errors early.

## Formatting with clang-format

- The project uses a `.clang-format` file with LLVM-based style and project-specific adjustments.
- All C++ source files (`src/*.cpp`, `src/*.h`) must be formatted before committing.
- Line length is limited to 120 characters.
- Consistent brace and indentation styles are enforced.

**Format all files:**

```bash
clang-format -i src/*.cpp src/*.h
```

## Static Analysis

- Clang provides comprehensive compiler warnings for early error detection.
- Modern C++20 features are supported and recommended.
- Platform-specific warning flags are enabled in `CMakeLists.txt`.

## Integration

- Formatting is required before every commit (see CONTRIBUTING.md).
- CI/CD workflows verify code formatting and build correctness.
- Clang is compatible with Visual Studio, Xcode, and Linux toolchains.

## Troubleshooting

- If formatting fails, check the `.clang-format` configuration.
- Ensure Clang is installed and available in your system PATH.
- For Windows, use the version bundled with Visual Studio or install via LLVM.

### Verifying Clang Installation

To check if Clang is installed and available in your PATH, run:

```bash
clang --version
## References

- [Clang documentation](https://clang.llvm.org/docs/)
- [LLVM project](https://llvm.org/)
- See `.clang-format` in the project root for configuration details.
```
