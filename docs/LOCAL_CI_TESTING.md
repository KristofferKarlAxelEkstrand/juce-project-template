# Local CI Testing Guide

Test your changes locally before pushing to avoid CI failures and iterate faster.

## Overview

This guide shows how to replicate CI checks on your local machine. Running these checks before pushing saves time and reduces failed CI runs.

## Quick Validation

Run all validation checks in sequence:

```bash
# 1. Validate development environment
./scripts/validate-setup.sh

# 2. Lint documentation
npm test

# 3. Configure and build
./scripts/configure-ninja.sh
./scripts/build-ninja.sh

# 4. Validate build artifacts
./scripts/validate-builds.sh Debug

# 5. Build Release configuration
./scripts/build-ninja.sh --config Release
./scripts/validate-builds.sh Release
```

**Expected time**: 5-10 minutes (first run with JUCE download), 2-3 minutes for subsequent runs.

## Individual Validation Steps

### Step 1: Environment Validation

Check that development tools are installed:

```bash
./scripts/validate-setup.sh
```

**Checks**:
- CMake version (3.22+)
- C++ compiler availability
- Git configuration
- Platform-specific dependencies

**Expected output**:
```
Checking development environment...
[OK] CMake version: 3.22.0
[OK] C++ compiler: g++ 11.4.0
[OK] Git configuration
All checks passed!
```

**If checks fail**: Install missing dependencies (see BUILD.md)

### Step 2: Documentation Linting

Validate markdown documentation:

```bash
npm test
```

**Checks**:
- Markdown syntax
- Link validity
- Style consistency

**Expected output**:
```
> juce-project-template@0.0.1 test
> markdownlint-cli2 "**/*.md"

markdownlint-cli2 v0.x.x
All files passed
```

**If linting fails**: Fix markdown errors or run `npm run lint:md:fix` for auto-fixes

### Step 3: Build Configuration

Configure CMake with Ninja:

**Windows**:
```cmd
scripts\configure-ninja.bat
```

**macOS/Linux**:
```bash
./scripts/configure-ninja.sh
```

**Expected output**:
```
Configuring CMake with Ninja preset...
-- Plugin: DSP-JUCE Plugin v0.0.1
-- Build files written to: build/ninja
Configuration successful!
```

**If configuration fails**: Check CMakeLists.txt syntax and CMake version

### Step 4: Debug Build

Build Debug configuration:

**Windows**:
```cmd
scripts\build-ninja.bat
```

**macOS/Linux**:
```bash
./scripts/build-ninja.sh
```

**Expected output**:
```
Building with Ninja (Debug configuration)...
[100%] Built target JucePlugin
Build successful!
```

**Expected time**: 2-5 minutes (full build), 1-3 seconds (incremental)

### Step 5: Validate Debug Artifacts

Check that all build artifacts exist:

```bash
./scripts/validate-builds.sh Debug
```

**Checks**:
- VST3 plugin bundle
- Standalone application
- Shared library
- Platform-specific formats (AU on macOS)

**Expected output**:
```
Build artifacts validation (Debug):
[OK] VST3 plugin
[OK] Standalone application
[OK] Shared library
All artifacts found!
```

### Step 6: Release Build

Build Release configuration:

**Windows**:
```cmd
scripts\build-ninja.bat --config Release
```

**macOS/Linux**:
```bash
./scripts/build-ninja.sh --config Release
```

**Expected time**: 3-7 minutes

### Step 7: Validate Release Artifacts

Check Release build artifacts:

```bash
./scripts/validate-builds.sh Release
```

Same checks as Debug validation, different output directory.

## Platform-Specific Testing

### Windows Testing

Full Windows CI simulation:

```cmd
REM Environment check
scripts\validate-setup.sh

REM Documentation
npm test

REM Debug build
scripts\configure-ninja.bat
scripts\build-ninja.bat
scripts\validate-builds.sh Debug

REM Release build
scripts\build-ninja.bat --config Release
scripts\validate-builds.sh Release

REM Test standalone app
scripts\run-standalone.bat Debug
```

### macOS Testing

Full macOS CI simulation:

```bash
# Environment check
./scripts/validate-setup.sh

# Documentation
npm test

# Debug build
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
./scripts/validate-builds.sh Debug

# Release build  
./scripts/build-ninja.sh --config Release
./scripts/validate-builds.sh Release

# Test standalone app
./scripts/run-standalone.sh Debug
```

### Linux Testing

Full Linux CI simulation (same as macOS):

```bash
# Environment check
./scripts/validate-setup.sh

# Documentation
npm test

# Debug build
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
./scripts/validate-builds.sh Debug

# Release build
./scripts/build-ninja.sh --config Release
./scripts/validate-builds.sh Release

# Test standalone app
./scripts/run-standalone.sh Debug
```

## Code Quality Checks

### Format Check

Check code formatting (does not modify files):

```bash
clang-format --dry-run --Werror src/*.cpp src/*.h
```

**Expected**: No output (all files formatted correctly)

**If formatting issues found**: Auto-format with:

```bash
clang-format -i src/*.cpp src/*.h
```

### Format All Files

Auto-format all source files:

```bash
# Format C++ files
find src -name "*.cpp" -o -name "*.h" | xargs clang-format -i

# Format markdown files
npm run lint:md:fix
```

## Testing Workflow Integration

### Before Committing

Run fast checks before committing:

```bash
# Quick validation (30 seconds)
npm test                        # Lint documentation
./scripts/build-ninja.sh        # Incremental build
```

### Before Pushing

Run full validation before pushing:

```bash
# Full validation (2-3 minutes)
./scripts/validate-setup.sh
npm test
./scripts/build-ninja.sh
./scripts/validate-builds.sh Debug
```

### Before Creating PR

Run comprehensive checks before creating pull request:

```bash
# Comprehensive validation (5-10 minutes)
./scripts/validate-setup.sh
npm test
clang-format --dry-run --Werror src/*.cpp src/*.h
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
./scripts/validate-builds.sh Debug
./scripts/build-ninja.sh --config Release
./scripts/validate-builds.sh Release
```

## Continuous Testing During Development

### Watch Mode (Documentation)

Auto-lint documentation on file changes:

**Not built-in**, but you can use:

```bash
# Install nodemon globally
npm install -g nodemon

# Watch markdown files
nodemon --watch "**/*.md" --exec "npm test"
```

### Fast Build-Test Loop

Fastest iteration cycle:

```bash
# 1. Edit code
# 2. Build (1-3 seconds)
./scripts/build-ninja.sh

# 3. Test
./scripts/run-standalone.sh Debug

# 4. Repeat
```

## Troubleshooting Local Tests

### validate-setup.sh Fails

**Issue**: Missing dependencies

**Fix**: Install required tools (see BUILD.md)

**Platform-specific**:
- Windows: Install Visual Studio 2022 with C++ workload
- macOS: Install Xcode Command Line Tools
- Linux: Install build-essential, CMake, JUCE dependencies

### npm test Fails

**Issue**: Markdown linting errors

**Fix**: Auto-fix most issues:

```bash
npm run lint:md:fix
```

**Manual fixes**: Review error messages and fix markdown syntax

### Build Fails Locally But Passes in CI

**Issue**: Different compiler versions or configurations

**Fix**:
1. Check CMake version matches CI (3.22+)
2. Use same compiler as CI (MSVC 2022 on Windows, Clang on macOS, GCC on Linux)
3. Clean build: Delete `build/` directory and reconfigure

### Build Passes Locally But Fails in CI

**Issue**: Local cache or missing files

**Fix**:
1. Clean build: `rm -rf build/`
2. Reconfigure and rebuild
3. Run `./scripts/validate-builds.sh` to check all artifacts
4. Check that all source files are committed to Git

## CI Workflow Reference

### GitHub Actions Matrix

CI runs on three platforms:

- **Ubuntu 22.04**: Latest LTS Linux
- **macOS 12**: Latest stable macOS
- **Windows 2022**: Latest Windows Server

### CI Checks (Pull Requests)

When you create a PR to `main` or `develop`, CI runs:

1. Checkout code
2. Setup platform dependencies
3. Configure CMake
4. Build Debug configuration
5. Validate artifacts
6. Run documentation linting
7. Security scanning (CodeQL on main branch)

### CI Checks (Main Branch)

Additional checks on `main` branch:

- Release build
- CodeQL security analysis
- Dependency scanning

## Local Testing Best Practices

### Before Every Commit

Minimum checks:
- Build succeeds: `./scripts/build-ninja.sh`
- Documentation lints: `npm test`

### Before Every Push

Recommended checks:
- Environment valid: `./scripts/validate-setup.sh`
- Build succeeds: `./scripts/build-ninja.sh`
- Artifacts valid: `./scripts/validate-builds.sh Debug`
- Documentation lints: `npm test`

### Before Every Pull Request

Comprehensive checks:
- All validation scripts pass
- Both Debug and Release builds succeed
- Code formatted: `clang-format --dry-run --Werror src/**`
- Documentation accurate and up-to-date

## Performance Benchmarks

Expected times for local testing:

| Check | Time (First Run) | Time (Incremental) |
|-------|------------------|-------------------|
| validate-setup.sh | 5 seconds | 5 seconds |
| npm test | 2 seconds | 2 seconds |
| configure-ninja | 90 seconds | 1 second |
| build-ninja (Debug) | 2-5 minutes | 1-3 seconds |
| build-ninja (Release) | 3-7 minutes | 2-5 seconds |
| validate-builds.sh | 1 second | 1 second |
| **Full Validation** | **5-10 minutes** | **2-3 minutes** |

## See Also

- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow
- [BUILD.md](../BUILD.md) - Build system documentation
- [docs/CI.md](CI.md) - CI/CD pipeline details
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
