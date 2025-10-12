# CI/CD Trigger Matrix

This document shows which GitHub Actions workflows and jobs run for different events.

## Trigger Event Matrix

| Event | Lint | Build (ubuntu, Debug) | Build (ubuntu, Release) | Build (windows, Release) | Build (macos, Release) | CodeQL (C++) | CodeQL (JS/TS) | Release Jobs |
|-------|------|----------------------|------------------------|-------------------------|------------------------|--------------|----------------|--------------|
| **PR → `develop`** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **PR → `main`** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Push → `main`** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Tag `v*.*.*`** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Weekly Schedule** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |

---

## Workflow Breakdown by Trigger

### Pull Requests to `main` or `develop`

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

**Purpose:** Comprehensive validation before merging

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
| **CodeQL Security** (`codeql.yml`) | PRs to `main`/`develop`, Pushes to `main`, Weekly schedule |
| **Release** (`release.yml`) | Version tags (`v*.*.*`) |

### Total CI Job Count by Event

- **PR to `main` or `develop`:** 7 jobs
- **Push to `main`:** 2 jobs
- **Version tag:** 4 jobs
- **Weekly schedule:** 2 jobs

### Resource Usage Estimate

**Most expensive event:** Pull Requests (7 jobs with full cross-platform builds)

**Approximate CI minutes per event:**

- PR: ~35-45 minutes (7 jobs × 5-6 min average)
- Push to `main`: ~10-15 minutes (2 jobs × 5-7 min)
- Version tag: ~20-25 minutes (3 parallel builds + release)
- Weekly: ~10-15 minutes (2 jobs × 5-7 min)

---

## Optimization Opportunities

### Current Behavior

- **Every PR** runs full cross-platform builds (ubuntu Debug + 3× Release)
- **CodeQL runs on every PR** regardless of code changes
- **No path-based filtering** - even markdown-only changes trigger full builds

### Potential Improvements

1. **Path-based triggers** - Skip C++ builds for documentation-only changes
2. **Conditional matrix** - Run Debug builds only when requested
3. **Incremental CodeQL** - Skip security scans for non-code changes
4. **Cache optimization** - Better JUCE dependency caching

**See:** `feature/smarter-ci-runs` branch for proposed optimizations

---

**Last Updated:** October 12, 2025
