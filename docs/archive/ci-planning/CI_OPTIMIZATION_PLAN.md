# CI Optimization Implementation Plan

> **⚠️ ARCHIVED PLANNING DOCUMENT**
>
> This document represents historical planning from the CI optimization project.
> The implementation has been **completed** and differs from these original plans.
>
> **For current CI documentation, see:**
>
> - **[CI_GUIDE.md](../../CI_GUIDE.md)** - Current CI/CD strategy and usage
> - **[CI_IMPLEMENTATION.md](../../CI_IMPLEMENTATION.md)** - Technical implementation details
> - **[Archive README](README.md)** - Context on planning evolution
>
> **Status indicators below (⏳, ✅, ❌) reflect planning phase state, not current implementation.**

---

Based on analysis in `CI_TRIGGERS.md`, this document outlines concrete changes to make CI runs smarter and more efficient.

## Current Problems

### Problem 1: Documentation-Only Changes Trigger Full Builds

**Current Behavior:** Changing a markdown file triggers 7 jobs (4 full cross-platform builds + 2 CodeQL + 1 lint)

**Cost:** ~35-45 CI minutes for a typo fix

**Example Wasteful Scenario:**

```bash
# User fixes typo in README.md
git commit -m "docs: Fix typo"
# Triggers: ubuntu Debug build, ubuntu Release, Windows Release, macOS Release, 2x CodeQL
# Result: 35 minutes of unnecessary compilation
```

### Problem 2: CodeQL Runs on Non-Code Changes

**Current Behavior:** Security analysis runs even when only markdown or config files change

**Cost:** ~10-15 extra CI minutes per PR

### Problem 3: Debug Builds Run on Every PR

**Current Behavior:** Ubuntu Debug build runs on all PRs, even when not needed

**Cost:** ~6-8 minutes per PR, limited value vs Release builds

### Problem 4: No Build Artifact Reuse

**Current Behavior:** Each workflow builds from scratch, no caching between jobs

**Cost:** Repeated JUCE downloads and compilation

---

## Optimization Strategy

### Phase 1: Path-Based Filtering (High Impact, Low Risk)

#### Change 1.1: Skip Builds for Documentation-Only Changes

**Target Workflow:** `ci.yml` - Build job

**Implementation:**

```yaml
build:
  name: Build
  runs-on: ${{ matrix.os }}
  # Add path-based filtering
  if: |
    contains(github.event.pull_request.labels.*.name, 'build-required') ||
    !contains(fromJSON('["**.md", ".github/workflows/*.yml", "docs/**", "*.md", ".gitignore", "LICENSE", ".editorconfig"]'), github.event.pull_request.files[*].filename)
```

**Alternative Approach (Recommended):**

```yaml
on:
  pull_request:
    branches: [ main, develop ]
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.github/**/*.md'
      - 'LICENSE'
      - '.gitignore'
      - '.editorconfig'
```

**Expected Savings:** 30-40 CI minutes per documentation PR

---

#### Change 1.2: Path-Based CodeQL Triggers

**Target Workflow:** `codeql.yml`

**Implementation:**

```yaml
on:
  pull_request:
    branches: [ main, develop ]
    paths:
      - '**.cpp'
      - '**.h'
      - 'src/**'
      - 'CMakeLists.txt'
      - '**.js'
      - '**.ts'
      - 'package.json'
      - '.github/workflows/codeql.yml'
  push:
    branches: [ "main" ]
    paths:
      - '**.cpp'
      - '**.h'
      - 'src/**'
      - 'CMakeLists.txt'
      - '**.js'
      - '**.ts'
```

**Expected Savings:** 10-15 CI minutes per non-code PR

---

### Phase 2: Conditional Matrix Optimization (Medium Impact, Low Risk)

#### Change 2.1: Make Debug Builds Optional

**Target Workflow:** `ci.yml`

**Implementation:**

```yaml
build:
  name: Build
  runs-on: ${{ matrix.os }}
  strategy:
    fail-fast: false
    matrix:
      os: [ubuntu-latest, windows-latest, macos-latest]
      build_type: [Release]
      # Only run Debug build when label present or on specific paths
      include:
        - os: ubuntu-latest
          build_type: Debug
          # Only run if:
          # 1. Label 'debug-build' is present, OR
          # 2. Core source files changed
      if: |
        contains(github.event.pull_request.labels.*.name, 'debug-build') ||
        contains(fromJSON('["src/**/*.cpp", "src/**/*.h", "CMakeLists.txt"]'), github.event.pull_request.files[*].filename)
```

**Expected Savings:** 6-8 CI minutes per PR (when not needed)

---

#### Change 2.2: Platform-Specific Build Triggers

**Target Workflow:** `ci.yml`

**Implementation:**

```yaml
strategy:
  matrix:
    include:
      - os: ubuntu-latest
        build_type: Release
        # Always run Linux
      
      - os: windows-latest
        build_type: Release
        # Skip if only Unix-specific files changed
        condition: |
          !contains(fromJSON('["scripts/*.sh", ".github/workflows/*.yml"]'), github.event.pull_request.files[*].filename)
      
      - os: macos-latest
        build_type: Release
        # Skip if only Windows-specific files changed
        condition: |
          !contains(fromJSON('["scripts/*.bat", ".github/workflows/*.yml"]'), github.event.pull_request.files[*].filename)
```

**Expected Savings:** 5-10 CI minutes per platform-specific PR

---

### Phase 3: Cache Optimization (Medium Impact, Medium Risk)

#### Change 3.1: Better JUCE Caching Strategy

**Current Issue:** Cache key includes all CMakeLists.txt changes, causing frequent cache misses

**Target Workflow:** All workflows

**Implementation:**

```yaml
- name: Cache JUCE
  uses: actions/cache@v4
  with:
    path: |
      ${{ github.workspace }}/.juce_cache
      ${{ github.workspace }}/third_party/JUCE
    key: ${{ runner.os }}-juce-8.0.10-${{ hashFiles('CMakeLists.txt:1-50') }}
    restore-keys: |
      ${{ runner.os }}-juce-8.0.10-
      ${{ runner.os }}-juce-
```

**Expected Savings:** 30-60 seconds per job (faster JUCE downloads)

---

#### Change 3.2: Build Artifact Caching Between Jobs

**Target Workflow:** `ci.yml`

**Implementation:**

```yaml
- name: Cache CMake build directory
  uses: actions/cache@v4
  with:
    path: ${{ steps.set_vars.outputs.build_dir }}
    key: ${{ runner.os }}-${{ matrix.build_type }}-${{ hashFiles('src/**', 'CMakeLists.txt') }}
    restore-keys: |
      ${{ runner.os }}-${{ matrix.build_type }}-
```

**Expected Savings:** 2-5 minutes per incremental build

---

### Phase 4: Lint-Only Workflow (High Impact, Low Risk)

#### Change 4.1: Create Fast-Path for Documentation

**New Workflow:** `.github/workflows/docs-lint.yml`

**Implementation:**

```yaml
name: Documentation Lint

on:
  pull_request:
    branches: [ main, develop ]
    paths:
      - '**.md'
      - 'docs/**'
      - '.markdownlint.json'
      - '.github/workflows/docs-lint.yml'

jobs:
  lint:
    name: Lint Documentation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      
      - name: Setup Node.js
        uses: actions/setup-node@v5
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm install
      
      - name: Run markdown linting
        run: npm test
```

**Note:** Move lint job from ci.yml to this workflow

**Expected Savings:** Documentation PRs complete in <1 minute instead of 35-45 minutes

---

## Implementation Roadmap

### Week 1: Quick Wins (Phase 1 + Phase 4)

1. ✅ Create `CI_TRIGGERS.md` documentation
2. ⏳ Add `docs-lint.yml` workflow
3. ⏳ Add `paths-ignore` to `ci.yml` build job
4. ⏳ Add `paths` filters to `codeql.yml`
5. ⏳ Test with documentation-only PR

**Expected Impact:** 80% reduction in CI time for documentation changes

---

### Week 2: Refinements (Phase 2)

1. ⏳ Make Debug builds conditional
2. ⏳ Add platform-specific build logic
3. ⏳ Test with various PR types

**Expected Impact:** 15-20% reduction in CI time for typical PRs

---

### Week 3: Advanced Optimization (Phase 3)

1. ⏳ Improve JUCE caching strategy
2. ⏳ Add build directory caching
3. ⏳ Monitor cache hit rates
4. ⏳ Fine-tune cache keys

**Expected Impact:** 10-15% faster builds overall

---

## Success Metrics

### Before Optimization

- Documentation PR: ~35-45 minutes (7 jobs)
- Code PR: ~35-45 minutes (7 jobs)
- Average PR: ~40 minutes

### After Phase 1 (Target)

- Documentation PR: ~1 minute (lint only)
- Code PR: ~35-45 minutes (full builds)
- Average PR: ~20 minutes (50% reduction)

### After All Phases (Target)

- Documentation PR: ~1 minute
- Code PR: ~25-30 minutes (cache + conditional)
- Average PR: ~12-15 minutes (70% reduction)

---

## Risk Assessment

### Low Risk Changes

✅ Path-based filtering (easy to revert)
✅ Documentation workflow split (isolated)
✅ Cache key improvements (backwards compatible)

### Medium Risk Changes

⚠️ Conditional matrix builds (may miss edge cases)
⚠️ Platform-specific skipping (needs thorough testing)

### Mitigation Strategies

1. Always run full builds on `main` branch pushes
2. Add manual trigger for full CI run (workflow_dispatch)
3. Keep `release.yml` unchanged (full builds on tags)
4. Monitor for false negatives (missed build failures)

---

## Rollback Plan

If optimization causes issues:

1. Revert workflow files to previous commit
2. Re-run failed PR checks
3. Document failure scenario
4. Adjust filters and re-deploy

All changes are git-reversible with no infrastructure dependencies.

---

## Manual Override Mechanism

Add workflow_dispatch to allow manual full builds:

```yaml
on:
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      force_full_build:
        description: 'Run all builds regardless of changes'
        required: false
        type: boolean
        default: false
```

---

**Created:** October 12, 2025
**Status:** Ready for implementation
**Branch:** `feature/smarter-ci-runs`
