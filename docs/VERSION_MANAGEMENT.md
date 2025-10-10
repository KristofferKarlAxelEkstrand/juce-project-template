# Version Management Guide

This document explains how versioning works in the DSP-JUCE project and how to create releases.

## Version Sources (Must Match!)

The version is defined in **two places** in `CMakeLists.txt`:

```cmake
# Line 4: CMake project version
project(SimpleJuceApp VERSION 1.0.0 LANGUAGES C CXX)

# Line 61: Plugin version
set(PLUGIN_VERSION "1.0.0")
```

**⚠️ Critical**: These MUST match or CMake will fail with an error.

## Semantic Versioning

Use [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (e.g., 1.0.0 → 2.0.0)
- **MINOR**: New features, backward compatible (e.g., 1.0.0 → 1.1.0)
- **PATCH**: Bug fixes, backward compatible (e.g., 1.0.0 → 1.0.1)

## How to Release a New Version

### Step 1: Update Version in CMakeLists.txt

Edit **both** lines:

```cmake
# Line 4
project(SimpleJuceApp VERSION 2.0.0 LANGUAGES C CXX)

# Line 61
set(PLUGIN_VERSION "2.0.0")
```

### Step 2: Verify Version Validation

Run CMake to ensure versions match:

```bash
cmake --preset=vs2022  # Windows
cmake --preset=release # Linux/macOS
```

If versions don't match, you'll see:

```text
CMake Error: Version mismatch detected!
  PLUGIN_VERSION: 2.0.0
  PROJECT_VERSION: 1.0.0
  Please ensure both versions match in CMakeLists.txt
```

### Step 3: Test Build

```bash
# Configure
cmake --preset=vs2022

# Build Release
cmake --build build/vs2022 --config Release

# Validate artifacts
bash scripts/validate-builds.sh Release
```

### Step 4: Commit Version Change

```bash
git add CMakeLists.txt
git commit -m "chore: bump version to 2.0.0"
git push origin feature/release-zips
```

### Step 5: Create Git Tag

**This triggers the release workflow!**

```bash
# Create annotated tag (recommended)
git tag -a v2.0.0 -m "Release version 2.0.0"

# Push tag to trigger release
git push origin v2.0.0
```

### Step 6: Automated Release

GitHub Actions will automatically:

1. ✅ Build for Windows, Linux, macOS
2. ✅ Run validation scripts
3. ✅ Create ZIP files: `DSP-JUCE-Plugin-v2.0.0-windows.zip`
4. ✅ Create GitHub Release with all artifacts
5. ✅ Attach ZIPs to release

## Version Propagation

When you update `PLUGIN_VERSION`, it automatically propagates to:

| Location | Variable/Macro | Example Output |
|----------|---------------|----------------|
| CMake status | `${PLUGIN_VERSION}` | "Plugin: DSP-JUCE Plugin v2.0.0" |
| JUCE plugin | `JucePlugin_VersionString` | "2.0.0" |
| Metadata file | `PROJECT_VERSION` | `export PROJECT_VERSION="2.0.0"` |
| CI/CD | `$PROJECT_VERSION` | Used in workflow logic |
| ZIP filename | Sanitized in workflow | `DSP-JUCE-Plugin-v2.0.0-windows.zip` |
| DAW display | `JucePlugin_VersionString` | Shows in plugin info |

## Release Workflow Trigger

The `.github/workflows/release.yml` triggers on version tags:

```yaml
on:
  push:
    tags:
      - 'v*.*.*'  # Matches v1.0.0, v2.5.1, etc.
```

**Tag Format**: Must start with `v` followed by semantic version (e.g., `v2.0.0`)

## Checking Current Version

### From CMake

```bash
cmake --preset=vs2022 | grep "Plugin:"
# Output: -- Plugin: DSP-JUCE Plugin v1.0.0
```

### From Metadata File

```bash
cat build/vs2022/plugin_metadata.sh | grep VERSION
# Output: export PROJECT_VERSION="1.0.0"
```

### From Git Tags

```bash
git tag --list 'v*'
# Output: v1.0.0
```

### Latest Release

```bash
git describe --tags --abbrev=0
# Output: v1.0.0
```

## Version Consistency Checklist

Before releasing, verify:

- [ ] `project(VERSION ...)` matches `set(PLUGIN_VERSION ...)`
- [ ] CMake configuration succeeds without warnings
- [ ] Build completes successfully
- [ ] Validation script passes
- [ ] Git tag matches CMakeLists.txt version
- [ ] Tag pushed to remote

## Troubleshooting

### "Version mismatch detected!"

**Problem**: `PLUGIN_VERSION` and `PROJECT_VERSION` don't match.

**Solution**: Edit both lines in `CMakeLists.txt` to the same version.

### Release workflow didn't trigger

**Problem**: Tag doesn't match pattern or wasn't pushed.

**Solution**:

```bash
# Check tag format (must be v*.*.*)
git tag --list

# Ensure tag is pushed
git push origin v2.0.0
```

### Wrong version in ZIP filename

**Problem**: CMake not reconfigured after version change.

**Solution**:

```bash
# Reconfigure to regenerate plugin_metadata.sh
cmake --preset=vs2022
```

## Example: Complete Release Process

```bash
# 1. Update version in CMakeLists.txt (both lines to 2.1.0)

# 2. Test locally
cmake --preset=vs2022
cmake --build build/vs2022 --config Release
bash scripts/validate-builds.sh Release

# 3. Commit changes
git add CMakeLists.txt
git commit -m "chore: bump version to 2.1.0"
git push origin feature/release-zips

# 4. Merge to main (via PR)
gh pr create --title "Release v2.1.0" --base main

# 5. After merge, create tag on main
git checkout main
git pull
git tag -a v2.1.0 -m "Release version 2.1.0

Features:
- Added feature X
- Improved performance Y
- Fixed bug Z"

# 6. Push tag (triggers release workflow)
git push origin v2.1.0

# 7. Monitor release at:
# https://github.com/KristofferKarlAxelEkstrand/dsp-juce/releases
```

## Best Practices

1. **Always use annotated tags**: `git tag -a v1.0.0 -m "message"`
2. **Keep versions synchronized**: Use the CMake validation check
3. **Test before tagging**: Build and validate locally first
4. **Document changes**: Include release notes in tag message
5. **Follow semantic versioning**: Communicate breaking changes clearly
6. **One version per tag**: Don't reuse or move tags
