# CI/CD Trigger Matrix

This document shows which GitHub Actions workflows and jobs run for different events.

## Trigger Event Matrix

| Event | Lint | Build (ubuntu, Debug) | Build (ubuntu, Release) | Build (windows, Release) | Build (macos, Release) | CodeQL (C++) | CodeQL (JS/TS) | Release Jobs |
|-------|------|----------------------|------------------------|-------------------------|------------------------|--------------|----------------|--------------|
| **PR → `develop`** | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **PR → `main`** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Push → `main`** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Tag `v*.*.*`** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Weekly Schedule** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |

---

## Workflow Breakdown by Trigger

### Pull Requests to `develop`

**Workflows:** CI Build only (minimal fast validation)

**Jobs Running:**

1. ✅ **Lint** (ubuntu-latest) - Markdown linting
2. ✅ **Build** (ubuntu-latest, Debug) - Debug build validation
3. ✅ **Build** (windows-latest, Release) - Windows release build

#### Total: 3 parallel jobs

**Purpose:** Fastest possible feedback for feature development

**What's NOT running:**

- ❌ Linux Release build (validated at `main` gate)
- ❌ macOS Release build (validated at `main` gate)
- ❌ CodeQL security scans (validated at `main` gate)

---

### Pull Requests to `main`

**Workflows:** CI Build + CodeQL Security Analysis

**Jobs Running:**

1. ✅ **Lint** (ubuntu-latest) - Markdown linting
2. ✅ **Build** (ubuntu-latest, Debug) - Debug build validation
3. ✅ **Build** (ubuntu-latest, Release) - Linux release build
4. ✅ **Build** (windows-latest, Release) - Windows release build
5. ✅ **Build** (macos-latest, Release) - macOS release build
6. ✅ **CodeQL Analyze** (ubuntu-latest, c-cpp) - C++ security scan
7. ✅ **CodeQL Analyze** (ubuntu-latest, javascript-typescript) - JS/TS security scan

#### Total: 7 parallel jobs

**Purpose:** Comprehensive validation before production merge

---

### Push to `main` Branch

**Workflows:** CodeQL Security Analysis only

**Jobs Running:**

1. ✅ **CodeQL Analyze** (ubuntu-latest, c-cpp) - C++ security scan
2. ✅ **CodeQL Analyze** (ubuntu-latest, javascript-typescript) - JS/TS security scan

#### Total: 2 parallel jobs (CodeQL only)

**Purpose:** Post-merge security validation

---

### Version Tags (`v*.*.*`)

**Workflows:** Create Plugin Release

**Jobs Running:**

1. ✅ **Build for Linux** (ubuntu-latest, Release)
2. ✅ **Build for Windows** (windows-latest, Release)
3. ✅ **Build for macOS** (macos-latest, Release)
4. ✅ **Create GitHub Release** (ubuntu-latest) - Runs after builds complete

#### Total: 4 jobs (3 parallel builds + 1 sequential release)

**Purpose:** Create distributable plugin releases

---

### Weekly Schedule (Mondays at 3:34 AM)

**Workflows:** CodeQL Security Analysis

**Jobs Running:**

1. ✅ **CodeQL Analyze** (ubuntu-latest, c-cpp) - C++ security scan
2. ✅ **CodeQL Analyze** (ubuntu-latest, javascript-typescript) - JS/TS security scan

#### Total: 2 parallel jobs (weekly scan)

**Purpose:** Regular security monitoring

---

## Quick Reference

### When does each workflow run?

| Workflow | Triggers |
|----------|----------|
| **CI Build** (`ci.yml`) | PRs to `main` or `develop` |
| **CodeQL Security** (`codeql.yml`) | PRs to `main` only, Pushes to `main`, Weekly schedule |
| **Release** (`release.yml`) | Version tags (`v*.*.*`) |

### Total CI Job Count by Event

- **PR to `develop`:** 3 jobs (lint + Debug + Windows only)
- **PR to `main`:** 7 jobs (builds + lint + security)
- **Push to `main`:** 2 jobs (security only)
- **Version tag:** 4 jobs (release builds)
- **Weekly schedule:** 2 jobs (security scan)

### Resource Usage Estimate

**Most expensive event:** Pull Requests to `main` (7 jobs with full cross-platform builds)

**Approximate CI minutes per event:**

- PR to `develop`: ~12-18 minutes (3 jobs × 4-6 min average)
- PR to `main`: ~35-45 minutes (7 jobs × 5-6 min average)
- Push to `main`: ~10-15 minutes (2 jobs × 5-7 min)
- Version tag: ~20-25 minutes (3 parallel builds + release)
- Weekly: ~10-15 minutes (2 jobs × 5-7 min)

---

## Optimization Opportunities

### Current Behavior

- **PRs to `develop`** run minimal builds (Debug + Windows only)
- **PRs to `main`** run full cross-platform builds (ubuntu Debug + 3× Release)
- **CodeQL runs on PRs to `main`** and pushes to `main` (not on PRs to `develop`)
- **No path-based filtering** - even markdown-only changes trigger builds

### Rationale

**Why only Windows Release on `develop`?**

- Most developers use Windows for JUCE development
- Catches Windows-specific issues early
- Linux/macOS validated at `main` gate before production
- Saves ~10-15 CI minutes per PR (2 fewer builds)

**Why Debug build on `develop`?**

- Validates developer workflow (most devs build Debug locally)
- Debug assertions catch issues Release builds miss
- Fast compilation (< Release build time)

**Why skip Linux/macOS Release on `develop`?**

- Cross-platform issues caught at `main` gate
- Release builds are slower than Debug
- Develop branch is for iteration, not release validation

### Potential Improvements

1. **Path-based triggers** - Skip C++ builds for documentation-only changes
2. **Conditional matrix** - Run Debug builds only when requested
3. **Incremental CodeQL** - Skip security scans for non-code changes
4. **Cache optimization** - Better JUCE dependency caching

**See:** `feature/smarter-ci-runs` branch for proposed optimizations

---

**Last Updated:** October 12, 2025
