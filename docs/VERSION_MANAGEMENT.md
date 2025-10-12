# Version Management

How to manage versions and create releases.

## Version Definition

Version is defined in two places in `CMakeLists.txt` (must match):

```cmake
project(JuceProject VERSION 1.0.0 LANGUAGES C CXX)
set(PLUGIN_VERSION "1.0.0")
```

CMake build fails if versions do not match.

## Semantic Versioning

Use `MAJOR.MINOR.PATCH` format:

- `MAJOR`: Breaking changes (1.0.0 → 2.0.0)
- `MINOR`: New features, backward compatible (1.0.0 → 1.1.0)
- `PATCH`: Bug fixes (1.0.0 → 1.0.1)

## Release Process

### 1. Update Version

Edit both lines in `CMakeLists.txt`:

```cmake
project(JuceProject VERSION 2.0.0 LANGUAGES C CXX)
set(PLUGIN_VERSION "2.0.0")
```

### 2. Test Build

```bash
# Configure
cmake --preset=default

# Build Release
cmake --preset=release
cmake --build --preset=release

# Validate
./scripts/validate-builds.sh Release
```

### 3. Commit

```bash
git add CMakeLists.txt
git commit -m "chore: bump version to 2.0.0"
git push
```

### 4. Create Tag

Tag triggers release workflow:

```bash
git tag -a v2.0.0 -m "Release version 2.0.0"
git push origin v2.0.0
```

### 5. Automated Release

GitHub Actions automatically:

- Builds for Windows, Linux, macOS
- Runs validation
- Creates ZIP files
- Creates GitHub Release with artefacts

## Version Propagation

Version from `CMakeLists.txt` flows to:

| Target | Variable | Example |
|--------|----------|---------|
| CMake | `${PLUGIN_VERSION}` | "1.0.0" |
| JUCE | `JucePlugin_VersionString` | "1.0.0" |
| Metadata | `PROJECT_VERSION` | `export PROJECT_VERSION="1.0.0"` |
| CI/CD | `$PROJECT_VERSION` | Workflow variable |
| ZIP | Sanitized in workflow | `DSP-JUCE-Plugin-v1.0.0-windows.zip` |
| DAW | Plugin info | Displayed in DAW |

## Check Current Version

### CMake Output

```bash
cmake --preset=default | grep "Plugin:"
# Output: -- Plugin: DSP-JUCE Plugin v1.0.0
```

### Metadata File

```bash
cat build/plugin_metadata.sh | grep VERSION
# Output: export PROJECT_VERSION="1.0.0"
```

### Git Tags

```bash
git tag --list 'v*'
# Output: v1.0.0

git describe --tags --abbrev=0
# Output: v1.0.0
```


## Troubleshooting

### Version Mismatch Error

CMake error: "Version mismatch detected!"

Fix: Edit both version lines in `CMakeLists.txt` to match:

```cmake
project(JuceProject VERSION 2.0.0 LANGUAGES C CXX)
set(PLUGIN_VERSION "2.0.0")
```

### Release Workflow Not Triggered

Tag format must be `v*.*.*` (e.g., `v2.0.0`).

Check tag was pushed:

```bash
git tag --list
git push origin v2.0.0
```

### Wrong Version in ZIP

Reconfigure CMake to regenerate metadata:

```bash
cmake --preset=default
```

