# CI/CD Guide

CI/CD strategy and what runs when.

## Overview

CI uses tiered validation:

- **PRs to `develop`**: Fast feedback (15 min) - lint, debug build, Windows release
- **PRs to `main`**: Full validation (40 min) - all platforms, all configs, security scans
- **Tags `v*.*.*`**: Automated releases with cross-platform builds

## What Runs When

### Pull Requests to `develop`

Fast iteration with essential validation (3 jobs, ~15 minutes):

- Lint (documentation)
- Build ubuntu Debug
- Build Windows Release

Coverage: ~90% of common issues

### Pull Requests to `main`

Full validation before production (7 jobs, ~40 minutes):

- Lint
- Build ubuntu Debug
- Build ubuntu Release
- Build Windows Release
- Build macOS Release
- CodeQL security scan (C++)
- CodeQL security scan (JavaScript/TypeScript)

Coverage: 100%

### Tags (`v*.*.*`)

Automated release workflow (4 jobs):

- Build for Windows, Linux, macOS
- Run validation scripts
- Create ZIP files
- Create GitHub Release with artefacts

## Developer Workflow

### Working on Feature

1. Create branch from `develop`
2. Push commits - CI runs on each push
3. Fix lint/build failures
4. Merge to `develop` when CI passes

### Preparing Release

1. Update version in `CMakeLists.txt` (see [VERSION_MANAGEMENT.md](docs/VERSION_MANAGEMENT.md))
2. Merge `develop` to `main` via PR
3. Full CI validation runs
4. After merge, create version tag (`v1.0.0`)
5. Release workflow runs automatically

## Local Validation

Run CI checks locally before pushing.

### Lint Documentation

```bash
npm install
npm run lint:md
```

Fix errors:

```bash
npm run lint:md:fix
```

### Build Debug

```bash
cmake --preset=default
cmake --build --preset=default
./scripts/validate-builds.sh Debug
```

### Build Release

```bash
cmake --preset=release
cmake --build --preset=release
./scripts/validate-builds.sh Release
```

### Test Cross-Platform

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

### CI Build Fails Locally Succeeds

Common causes:

- Different CMake version
- Missing dependencies (Linux)
- Platform-specific code issues

Solution: Check CI logs for exact error.

### Lint Failures

Run lint locally:

```bash
npm run lint:md:fix
```

Then commit fixes.

### CodeQL Security Issues

CodeQL only runs on `main` PRs. Review security findings in GitHub Security tab.

Address findings before merging to `main`.

## CI Configuration Files

- `.github/workflows/build.yml` - Main build workflow
- `.github/workflows/codeql.yml` - Security scanning
- `.github/workflows/release.yml` - Release automation

## See Also

- [VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md) - Version and release process
- [BUILD.md](../BUILD.md) - Build setup
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow
