# LLVM Basics

This document provides a concise overview of LLVM for audio plugin development with JUCE.

## What is LLVM?

LLVM is a collection of modular and reusable compiler and toolchain technologies. It provides tools for compiling,
optimizing, and analyzing C++ code. LLVM includes `clang`, a C/C++/Objective-C compiler used for building JUCE projects
and formatting code with `clang-format`.

## Key Components

- **clang**: C/C++ compiler front-end.
- **clang-format**: Automatic code formatter for C++ source files.
- **llvm-ar, llvm-nm, llvm-objdump**: Tools for inspecting and managing compiled binaries.

## Installation

- **Windows**: Download LLVM from
  [https://github.com/llvm/llvm-project/releases](https://github.com/llvm/llvm-project/releases). Add the `bin`
  directory to your system `PATH`.
- **macOS**: Install via Homebrew: `brew install llvm`. Add LLVM binaries to your `PATH` if needed.
- **Linux**: Install via package manager: `sudo apt-get install llvm clang`.

## Usage in JUCE Projects

- **Building**: CMake can use `clang` as the compiler for JUCE plugins.
- **Formatting**: Use `clang-format` to format C++ source files. The project provides scripts for cross-platform
  formatting.
- **CI Integration**: CI pipelines use LLVM tools for building and formatting code on all platforms.

## Troubleshooting

- Ensure LLVM binaries are in your system `PATH`.
- On Windows, verify the install location matches documentation in `WINDOWS_LLVM_SETUP.md`.
- If `clang-format` is not found, check your installation and update the formatting script as needed.

## References

- [LLVM Project](https://llvm.org/)
- [Clang Documentation](https://clang.llvm.org/)
- [JUCE Documentation](https://juce.com/learn/documentation)
