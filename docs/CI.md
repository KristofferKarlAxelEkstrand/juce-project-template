# CI/CD Guide

Comprehensive guide to the CI/CD system, workflows, and developer usage.

## Overview

CI uses tiered validation to balance speed and thoroughness:

- **PRs to `develop`**: Fast feedback (15 min) - lint, debug build, Windows Release build
- **PRs to `main`**: Full validation (40 min) - all platforms, all configs, security scans
- **Tags `v*.*.*`**: Automated releases with cross-platform builds

This approach provides 90% issue coverage on develop with 2.7x faster iteration, while maintaining 100%
validation before production releases.

## CI Workflows

### Build Workflow (`.github/workflows/ci.yml`)

Main build workflow that runs on pull requests:

- Lint documentation (markdown)
- Build on multiple platforms (Ubuntu, Windows, macOS)
- Build in multiple configurations (Debug, Release)
- Validate build artifacts

### Security Scanning (`.github/workflows/codeql.yml`)

CodeQL security analysis:

- Scans C++ code for security vulnerabilities
- Scans JavaScript/TypeScript for security issues
- Only runs on PRs to `main` branch

### Release Workflow (`.github/workflows/release.yml`)

Automated release process triggered by version tags:

- Builds for Windows, Linux, macOS
- Runs validation scripts
- Creates ZIP files of build artifacts
- Creates GitHub Release with downloadable artifacts

## What Runs When

### Pull Requests to `develop`

Fast iteration with essential validation (3 jobs, ~15 minutes):

- **Lint** (documentation)
- **Build ubuntu Debug**
- **Build Windows Release**

Coverage: ~90% of common issues

**Resource Impact:**

- 62.5% reduction in CI time vs full validation
- 2.7x faster PR feedback
- Catches most platform-specific issues (Windows)

### Pull Requests to `main`

Full validation before production (7 jobs, ~40 minutes):

- **Lint**
- **Build ubuntu Debug**
- **Build ubuntu Release**
- **Build Windows Release**
- **Build macOS Release**
- **CodeQL security scan (C++)**
- **CodeQL security scan (JavaScript/TypeScript)**

Coverage: 100%

**Implementation Details:**

Build matrix uses explicit include list with `run_on_develop` flags:

- Jobs marked `run_on_develop: true` run on all PRs
- Jobs marked `run_on_develop: false` run only on main PRs
- Skip logic at job start checks branch and flag
- All build steps respect skip flag

### Tags (`v*.*.*`)

Automated release workflow (4 jobs):

- Build for Windows, Linux, macOS
- Run validation scripts
- Create ZIP files
- Create GitHub Release with artifacts

Triggered by pushing version tags (see [VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md)).

## Developer Workflow

### Working on Feature

1. Create branch from `develop`
2. Push commits - CI runs on each push (3 jobs, ~15 min)
3. Fix lint/build failures
4. Merge to `develop` when CI passes

### Preparing Release

1. Update version in `CMakeLists.txt` (see [VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md))
2. Merge `develop` to `main` via PR
3. Full CI validation runs (7 jobs, ~40 min)
4. After merge, create version tag (`v1.0.0`)
5. Release workflow runs automatically

### Local Validation

Run CI checks locally before pushing to catch issues early.

#### Lint Documentation

```bash
npm install
npm run lint:md
```

Fix errors automatically:

```bash
npm run lint:md:fix
```

#### Build Debug

```bash
cmake --preset=default
cmake --build --preset=default
./scripts/validate-builds.sh Debug
```

#### Build Release

```bash
cmake --preset=release
cmake --build --preset=release
./scripts/validate-builds.sh Release
```

#### Test Cross-Platform

Use VS Code tasks or scripts:

```bash
# Windows
scripts\configure-ninja.bat
scripts\build-ninja.bat

# macOS/Linux
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
```

## Troubleshooting

### CI Build Fails But Succeeds Locally

Common causes:

- **Different CMake version**: CI may use different version than local
- **Missing dependencies**: Linux CI has specific library versions
- **Platform-specific code issues**: Code works on your platform but not others

**Solution:** Check CI logs for exact error messages and reproduce locally with same CMake version.

### Lint Failures

Markdown linting failures can be fixed automatically:

```bash
npm run lint:md:fix
```

Then commit the fixes and push.

**Common lint issues:**

- Missing blank lines around headers
- Inconsistent list formatting
- Trailing whitespace
- Missing newline at end of file

### CodeQL Security Issues

CodeQL only runs on `main` PRs. Review security findings in GitHub Security tab.

**Process:**

1. Wait for CodeQL scan to complete on main PR
2. Review findings in Security tab
3. Address legitimate security issues
4. Mark false positives as such
5. Re-run CI after fixes

Address all findings before merging to `main`.

### Windows-Specific Build Failures

If Windows Release build fails on develop PR:

1. Check if issue is Release-specific or Windows-specific
2. Test locally with Windows + Release configuration
3. Common issues:
   - MSVC-specific warnings treated as errors
   - Platform-specific API usage
   - Path separator issues (backslash vs forward slash)

### macOS/Linux Release Failures on Main PR

If builds pass on develop but fail on main:

1. Usually macOS or Linux Release configuration issues
2. Test locally with matching configuration
3. Common issues:
   - Clang/GCC-specific warnings
   - Library linking differences in Release mode
   - Optimization-related bugs

## Configuration Reference

### Caching Strategy

The CI/CD workflows use multiple cache layers to optimize build times:

#### JUCE Download Cache

Caches the JUCE framework download to avoid repeated fetches from GitHub.

**Cache Configuration**:

```yaml
path: ${{ github.workspace }}/.juce_cache
key: ${{ runner.os }}-juce-8.0.10-${{ hashFiles('CMakeLists.txt') }}
restore-keys: |
  ${{ runner.os }}-juce-8.0.10-
  ${{ runner.os }}-juce-
```

**Cache Invalidation**:

- Automatically invalidates when JUCE version changes in CMakeLists.txt
- Manual invalidation: Delete cache via GitHub UI (Actions > Caches)

**Benefit**: Saves 2-3 minutes per build by avoiding JUCE re-download

#### Why This Strategy

The cache key includes:

1. **Runner OS**: Different platforms need different binaries
2. **JUCE Version**: Ensures correct version after upgrades
3. **CMakeLists.txt hash**: Detects configuration changes that affect JUCE

**Note**: We cache the FetchContent base directory, not the JUCE submodule directory. This works
whether JUCE is provided as a submodule or downloaded by FetchContent.

### Workflow Files

- **`.github/workflows/ci.yml`** - Main build workflow
  - Conditional build matrix with `run_on_develop` flags
  - Skip logic for develop vs main PRs
  - Cross-platform build validation

- **`.github/workflows/codeql.yml`** - Security scanning
  - Triggers only on PRs to `main`
  - Analyzes C++ and JavaScript/TypeScript code
  - Reports findings to GitHub Security tab

- **`.github/workflows/release.yml`** - Release automation
  - Triggers on version tags (`v*.*.*`)
  - Creates cross-platform builds
  - Packages and uploads release artifacts

### CI Strategy Implementation

The current CI strategy was implemented in October 2025 to optimize resource usage while maintaining comprehensive validation.

**Key Design Decisions:**

- Fast develop PRs enable rapid iteration
- Windows Release on develop catches most platform issues early
- Full validation on main ensures production quality
- CodeQL on main prevents security issues in production

**Metrics Targets:**

- Develop PR time: <20 minutes (target: ~15 minutes)
- Main PR failure rate: <15% (target: ~10%)
- Resource savings: >40% (target: 52%)
- Zero production escapes

**Testing Strategy:**

Monitor these metrics over time:

- PR durations and completion rates
- Types of issues caught at each gate
- Developer feedback on iteration speed
- Resource consumption vs predictions

**Rollback Plan:**

If strategy causes issues, simple rollback available:

```bash
# Revert workflow changes to restore full validation on all PRs
git checkout main -- .github/workflows/ci.yml .github/workflows/codeql.yml
git commit -m "revert: Restore full CI validation on develop"
```

## See Also

- [VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md) - Version and release process
- [BUILD.md](../BUILD.md) - Build setup and platform requirements
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow and best practices
