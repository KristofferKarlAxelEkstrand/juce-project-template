# Audit Action Items - Quick Reference

**Audit Date:** October 12, 2025  
**Full Report:** See [AUDIT_REPORT.md](AUDIT_REPORT.md)

## Overview

This document provides prioritized action items from the comprehensive audit. All items are categorized by priority and estimated effort.

## Phase 1: Immediate Improvements (High Priority, 1-2 days)

### 1. Make VS Code Tasks Dynamic

**Problem:** Tasks hard-code plugin names, break when user customizes template  
**Files:** `.vscode/tasks.json`  
**Impact:** High - core developer workflow

**Solution:**

- Create wrapper scripts that read from `plugin_metadata.sh`
- Update tasks to use wrappers instead of hard-coded paths
- Support both Debug and Release configurations

**Implementation:**

```json
// Instead of:
"command": "build\\ninja\\JucePlugin_artefacts\\Debug\\Standalone\\DSP-JUCE Plugin.exe"

// Use:
"command": "${workspaceFolder}\\scripts\\run-standalone.bat"
```

**Acceptance Criteria:**

- [ ] Tasks work with any PLUGIN_NAME/PLUGIN_TARGET
- [ ] No hard-coded paths in tasks.json
- [ ] Debug and Release configurations supported
- [ ] Tested on Windows, macOS, Linux

### 2. Add Configuration Flag Support to Build Scripts

**Problem:** Cannot specify Debug/Release from scripts or VS Code  
**Files:** `scripts/build-ninja.sh`, `scripts/build-ninja.bat`  
**Impact:** High - blocks Release builds from IDE

**Solution:**

```bash
# Accept --config flag
./scripts/build-ninja.sh --config Release
./scripts/build-ninja.bat --config Debug
```

**Implementation:**

```bash
# In build-ninja.sh
CONFIG=${1:-Debug}  # Default to Debug
cmake --build build/ninja --config $CONFIG
```

**Acceptance Criteria:**

- [ ] Scripts accept --config Debug|Release
- [ ] Default to Debug if no flag provided
- [ ] Help message documents flag
- [ ] Tested on all platforms

### 3. Create Template Customization Guide

**Problem:** New users don't know what to change first  
**Files:** New `CUSTOMIZATION.md`  
**Impact:** High - first-time user experience

**Solution:**

Create step-by-step checklist for customizing template:

1. Update plugin metadata in CMakeLists.txt
2. Rename source files if desired
3. Configure build and test
4. Customize DSP and GUI
5. Test in DAW

**Implementation:**

```markdown
# Template Customization Guide

Follow these steps to customize the template for your plugin.

## Step 1: Update Plugin Metadata

Edit `CMakeLists.txt`:

1. Set `PLUGIN_NAME` - User-facing name (can have spaces)
2. Set `PLUGIN_TARGET` - CMake target (no spaces)
3. Set `PLUGIN_VERSION` - Semantic version
...
```

**Acceptance Criteria:**

- [ ] Complete checklist from clone to custom plugin
- [ ] Each step has clear instructions
- [ ] References relevant documentation
- [ ] Linked from README.md

### 4. Enhance Windows Script Help Messages

**Problem:** Windows .bat scripts lack detailed help like .sh scripts  
**Files:** `scripts/configure-ninja.bat`, `scripts/build-ninja.bat`  
**Impact:** Medium - Windows developer experience

**Solution:**

Add comprehensive help to batch scripts matching Unix format:

```batch
if "%1"=="/?" goto :help
if "%1"=="/help" goto :help
goto :main

:help
echo Usage: %~n0 [OPTIONS]
echo.
echo Build the project using Ninja build system.
echo.
echo Options:
echo     /?, /help      Show this help message
echo.
echo Examples:
echo     %~n0
...
exit /b 0
```

**Acceptance Criteria:**

- [ ] /? and /help flags supported
- [ ] Help format matches Unix scripts
- [ ] Includes usage, examples, prerequisites
- [ ] Output is clear and helpful

## Phase 2: Enhanced Developer Experience (Medium Priority, 3-5 days)

### 5. Create VS Code Integration Guide

**Problem:** No documentation for VS Code debugging, extensions  
**Files:** New `docs/VSCODE_SETUP.md`  
**Impact:** Medium - IDE productivity

**Topics to Cover:**

- Recommended extensions (CMake Tools, C/C++, clangd)
- Debugging configuration (launch.json)
- Tasks customization
- IntelliSense setup
- Keyboard shortcuts

### 6. Add Release Build Task to VS Code

**Problem:** Only Debug builds available in VS Code  
**Files:** `.vscode/tasks.json`  
**Impact:** Medium - distribution workflow

**Solution:**

```json
{
    "label": "Build Standalone (Ninja Release)",
    "type": "shell",
    "windows": {
        "command": "${workspaceFolder}\\scripts\\build-ninja.bat --config Release"
    }
}
```

### 7. Document Local CI Testing

**Problem:** Developers can't easily replicate CI builds  
**Files:** `CONTRIBUTING.md`, new `docs/LOCAL_CI.md`  
**Impact:** Medium - pre-PR validation

**Topics:**

- Run builds matching CI matrix
- Validate artifacts locally
- Test documentation linting
- Platform-specific commands

### 8. Consolidate Ninja Documentation

**Problem:** Ninja setup scattered across multiple files  
**Files:** New `docs/NINJA_SETUP.md`  
**Impact:** Medium - new user friction

**Content:**

- Installation per platform
- Why use Ninja (speed comparison)
- Troubleshooting
- Integration with VS Code

## Phase 3: Polish and Refinement (Low Priority, 2-3 days)

### 9. Remove Emoji from Scripts

**Problem:** Validates-setup.sh uses emoji, violates style guide  
**Files:** `scripts/validate-setup.sh`  
**Impact:** Low - style consistency

**Change:**

```bash
# From:
echo "✅ CMake found"

# To:
echo "[OK] CMake found"
```

### 10. Improve Script Error Messages

**Problem:** Error messages don't suggest fixes  
**Files:** All scripts in `scripts/`  
**Impact:** Low - troubleshooting experience

**Enhancement:**

```bash
# Current:
echo "ERROR: CMake configuration failed."

# Improved:
echo "ERROR: CMake configuration failed."
echo "SUGGESTED FIX: Check that all dependencies are installed."
echo "See: BUILD.md for platform-specific requirements."
```

### 11. Standardize JUCE Cache Paths

**Problem:** Different cache directories in different workflows  
**Files:** `.github/workflows/*.yml`  
**Impact:** Low - cache efficiency

**Change:**

Use `.juce_cache` consistently across ci.yml, codeql.yml, release.yml.

### 12. Document Plugin Formats

**Problem:** VST3, AU, Standalone not explained  
**Files:** New section in `docs/JUCE/`  
**Impact:** Low - educational

**Content:**

- VST3: Cross-platform, industry standard
- AU: macOS only, required for Logic Pro
- Standalone: Independent application
- DAW compatibility matrix

## Implementation Checklist

### Phase 1 (Week 1)

- [ ] Dynamic VS Code tasks with wrapper scripts
- [ ] Configuration flags in build scripts
- [ ] CUSTOMIZATION.md guide
- [ ] Windows batch script help messages
- [ ] Test all Phase 1 changes on Windows/macOS/Linux

### Phase 2 (Week 2)

- [ ] VS Code integration guide
- [ ] Release build VS Code task
- [ ] Local CI testing documentation
- [ ] Consolidated Ninja documentation
- [ ] Update cross-references in docs

### Phase 3 (Week 3)

- [ ] Remove emoji from validate-setup.sh
- [ ] Enhance error messages in all scripts
- [ ] Standardize workflow cache paths
- [ ] Plugin formats documentation
- [ ] Final documentation review

## Success Metrics

**Phase 1 Complete:**

- New users can customize template without editing tasks.json
- Release builds available from VS Code on all platforms
- First-time setup time reduced by 30%

**Phase 2 Complete:**

- VS Code users have debugging configured
- Developers can replicate CI builds locally
- Ninja setup questions reduced

**Phase 3 Complete:**

- All scripts follow style guide
- Error messages include fixes
- Cache hit rate improved in CI

## Non-Goals (Explicitly Out of Scope)

These were considered but not recommended:

- **Add unit testing framework** - Should be separate issue/feature
- **Automated plugin name propagation** - Current manual system is clear
- **Multi-language support** - Template is intentionally English-only
- **GUI framework alternatives** - JUCE GUI is core to template
- **Alternative build systems** - CMake is well-established choice

## Questions for Discussion

1. Should Phase 1 be implemented as single PR or separate PRs per item?
2. Is PowerShell support worth the maintenance burden for Windows?
3. Should validation scripts use colored output or plain text?
4. How aggressively should we template-ize documentation (placeholders vs examples)?

## Resources

- **Full Audit Report:** [AUDIT_REPORT.md](AUDIT_REPORT.md)
- **Contributing Guide:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Current Workflow:** [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)
- **Build Instructions:** [BUILD.md](BUILD.md)
