# Dependency Update Notes

This document summarizes the dependency updates performed on the dsp-juce project as part of the modernization effort.

## Update Summary

All dependencies have been updated to their latest stable versions as of October 2024.

### JUCE Framework

**Current Version**: 8.0.10

The project already uses JUCE 8.0.10 in CMakeLists.txt. Documentation has been updated to consistently reference
version 8.0.10 instead of the previously mentioned 8.0.9.

**Files Updated**:

- `docs/MODERNIZATION_SUMMARY.md`: Updated 2 occurrences from 8.0.9 to 8.0.10
- `docs/cmake/basics-cmake.md`: Updated 2 occurrences from 8.0.9 to 8.0.10

**No Breaking Changes**: JUCE 8.0.10 is fully compatible with the existing codebase. All builds tested
successfully.

### GitHub Actions Workflows

**Updated Actions**:

- `github/codeql-action@v3` → `github/codeql-action@v4` (in `.github/workflows/codeql.yml`)

**Already Up-to-Date Actions**:

- `actions/checkout@v5` (latest)
- `actions/setup-node@v5` (latest)
- `actions/cache@v4` (latest)
- `actions/upload-artifact@v4` (latest)

**No Breaking Changes**: CodeQL v4 is a drop-in replacement for v3 with improved performance and analysis capabilities.

### NPM Dependencies

**Status**: All NPM packages are up to date.

Packages verified current:

- `husky@^9.1.7`
- `lint-staged@^16.2.3`
- `markdownlint-cli2@^0.18.1`
- `prettier@^3.6.2`

**No Updates Needed**: All packages are on their latest stable versions.

### CMake Configuration

**Current Version**: CMake 3.22 (minimum required)

No changes to CMake version requirements or CMakePresets.json were necessary.

## Validation Results

### Documentation Linting

```bash
npm test
```

**Result**: ✅ All documentation passes linting with 0 errors.

### Build Validation

```bash
cmake --preset=default
cmake --build --preset=default
```

**Results**:

- ✅ CMake configuration successful (94.5s)
- ✅ JUCE 8.0.10 downloaded successfully via FetchContent
- ✅ Build completed successfully
- ✅ VST3 plugin built: `build/DSPJucePlugin_artefacts/Debug/VST3/DSP-JUCE Plugin.vst3`
- ✅ Standalone app built: `build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin`

**Build Warnings**: Minor warnings from JUCE's bundled VST3 SDK are expected and do not affect functionality.
These are upstream warnings from the VST3 SDK and not related to the project code.

## Breaking Changes

**None**. All updates are backward compatible with the existing codebase.

## Migration Steps

No migration steps required. The updates are transparent to developers:

1. Documentation now consistently references JUCE 8.0.10
2. GitHub Actions workflows use latest action versions for improved performance
3. All existing build commands and workflows remain unchanged

## Verification Checklist

- [x] JUCE version updated to 8.0.10 in all documentation
- [x] GitHub Actions updated to latest stable versions
- [x] NPM packages verified up to date
- [x] Documentation linting passes
- [x] CMake configuration successful
- [x] Build completes without errors
- [x] VST3 plugin builds successfully
- [x] Standalone application builds successfully
- [x] No breaking changes introduced

## Future Maintenance

**Automated Dependency Updates**: The project uses Dependabot (configured in `.github/dependabot.yml`)
to automatically check for and propose updates to:

- NPM packages (weekly on Mondays)
- GitHub Actions (weekly on Mondays)

**Manual JUCE Updates**: JUCE version updates should be performed manually by updating the `GIT_TAG` in
`CMakeLists.txt` and testing thoroughly, as JUCE may introduce breaking changes between versions.

## References

- [JUCE Documentation](https://juce.com/learn/documentation)
- [GitHub Actions Changelog](https://github.com/actions)
- [CMake Documentation](https://cmake.org/documentation/)
