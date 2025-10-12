# CI Strategy Summary - Ultra-Minimal Approach

**Branch:** `feature/smarter-ci-runs`
**Status:** Planning complete, implementation pending
**Last Updated:** October 12, 2025

## The Strategy in One Sentence

**`develop` = ultra-fast iteration (lint + Debug only), `main` = production gate (everything)**

---

## Visual Comparison

### Current State (what's actually running now)

| Trigger | Jobs | Time | What Runs |
|---------|------|------|-----------|
| PR → `develop` | 7 | ~40 min | Lint + 4 builds + 2 CodeQL |
| PR → `main` | 7 | ~40 min | Lint + 4 builds + 2 CodeQL |

### Planned State (this branch's strategy)

| Trigger | Jobs | Time | What Runs |
|---------|------|------|-----------|
| PR → `develop` | 2 | ~7 min | ✅ Lint + ✅ Debug (ubuntu) |
| PR → `main` | 7 | ~40 min | ✅ Everything |

**Speed improvement: 5.7x faster on `develop` PRs**

---

## What Changes

### PR to `develop` - BEFORE (current)

```yaml
jobs:
  ✅ Lint (ubuntu)
  ✅ Build (ubuntu, Debug)
  ✅ Build (ubuntu, Release)     ← REMOVE
  ✅ Build (windows, Release)    ← REMOVE
  ✅ Build (macos, Release)      ← REMOVE
  ✅ CodeQL (C++)                ← REMOVE
  ✅ CodeQL (JS/TS)              ← REMOVE
```

### PR to `develop` - AFTER (planned)

```yaml
jobs:
  ✅ Lint (ubuntu)               ← KEEP
  ✅ Build (ubuntu, Debug)       ← KEEP
```

### PR to `main` - NO CHANGE

```yaml
jobs:
  ✅ All 7 jobs run (unchanged)
```

---

## Resource Impact

### Weekly CI Usage (assuming 10 develop PRs, 2 main PRs)

**Before:**

- Develop PRs: 10 × 40 min = 400 minutes
- Main PRs: 2 × 40 min = 80 minutes
- **Total: 480 minutes/week**

**After:**

- Develop PRs: 10 × 7 min = 70 minutes
- Main PRs: 2 × 40 min = 80 minutes
- **Total: 150 minutes/week**

#### Savings: 330 CI minutes/week (69% reduction!)

---

## The Philosophy

### `develop` Branch Philosophy

**Question:** "Does it compile? Are the docs clean?"
**Focus:** Speed and iteration
**Validation:** Minimal - just enough to catch obvious breaks
**Time:** 5-8 minutes

### `main` Branch Philosophy

**Question:** "Is it production-ready? Secure? Works everywhere?"
**Focus:** Comprehensive validation
**Validation:** Everything - all platforms, all configs, security scans
**Time:** 35-45 minutes

---

## Risk Assessment

### What Could Go Wrong?

**Risk 1: Release-specific issues not caught until `main` PR**

- **Likelihood:** Low (JUCE Debug/Release differences are minimal)
- **Impact:** Medium (delays `main` PR, but doesn't reach production)
- **Mitigation:** `main` gate catches it, no production impact

**Risk 2: Platform-specific issues not caught until `main` PR**

- **Likelihood:** Very Low (JUCE abstracts platform differences well)
- **Impact:** Medium (delays `main` PR)
- **Mitigation:** JUCE's cross-platform design makes this rare

**Risk 3: Developers frustrated by `main` PR failures**

- **Likelihood:** Low (if strategy communicated clearly)
- **Impact:** Low (just re-push after fix)
- **Mitigation:** Clear documentation, optional manual full-build trigger

### What Makes This Safe?

✅ **Two-gate validation** - Nothing reaches production without passing `main`
✅ **JUCE's design** - Cross-platform abstraction layer makes platform issues rare
✅ **Debug assertions** - Most logic errors caught in Debug builds
✅ **Reversible** - Can revert workflow changes instantly if issues arise

---

## Success Metrics

### Developer Experience Targets

- **`develop` PR feedback time:** <10 minutes (target: 7 minutes)
- **`main` PR feedback time:** <45 minutes
- **False negative rate:** <5% (PRs that pass `develop` but fail `main`)
- **Developer satisfaction:** Faster iteration improves productivity

### Resource Efficiency Targets

- **Weekly CI usage:** <200 minutes (target: 150 minutes)
- **Cost per `develop` PR:** <10 minutes (target: 7 minutes)
- **Cost per `main` PR:** <45 minutes (unchanged)

---

## When to Reconsider This Strategy

### Red Flags

🚩 **>10% of `main` PRs fail** due to issues that passed `develop`
🚩 **Developer complaints** about wasted time on `main` PR fixes
🚩 **Platform-specific bugs** reaching production despite `main` gate
🚩 **Release-specific issues** frequently caught only at `main`

### Green Lights

✅ **<5% `main` PR failure rate** - Strategy working as designed
✅ **Faster iteration** - Developers making smaller, more frequent PRs
✅ **No production escapes** - `main` gate successfully catches all issues
✅ **High developer satisfaction** - Fast feedback appreciated

---

## Implementation Checklist

### Phase 1: Update Workflows (not done yet)

- [ ] Modify `.github/workflows/ci.yml`:
  - [ ] Add condition to skip Release builds on `develop` PRs
  - [ ] Keep all builds for `main` PRs
- [ ] Modify `.github/workflows/codeql.yml`:
  - [ ] Change trigger from `branches: [main, develop]` to `branches: [main]`
  - [ ] Keep weekly schedule unchanged

### Phase 2: Testing

- [ ] Create test PR to `develop` - verify only 2 jobs run
- [ ] Create test PR to `main` - verify all 7 jobs run
- [ ] Monitor first week of real usage

### Phase 3: Documentation

- [x] `CI_TRIGGERS.md` - Visual matrix updated
- [x] `CI_STRATEGY.md` - Philosophy documented
- [x] `CI_OPTIMIZATION_PLAN.md` - Implementation roadmap
- [ ] Update `CONTRIBUTING.md` with new CI expectations

### Phase 4: Communication

- [ ] Team announcement about new CI strategy
- [ ] Explain `develop` = fast, `main` = comprehensive
- [ ] Set expectations for `main` PR potentially catching issues

---

## Rollback Plan

If the strategy causes problems:

```bash
# Revert workflow changes
git revert <commit-hash>
git push origin main

# Or manually edit workflows to restore full builds on develop
```

All changes are confined to `.github/workflows/*.yml` - no code changes, fully reversible.

---

## Quick Reference Card for Developers

```text
┌─────────────────────────────────────────────────────────┐
│  CI Strategy Quick Reference                             │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  PR to `develop`:                                        │
│    ✅ Fast feedback (~7 minutes)                         │
│    ✅ Lint + Debug build only                            │
│    ❌ No Release builds, no security scans               │
│    💡 Goal: Does it compile? Docs clean?                 │
│                                                          │
│  PR to `main`:                                           │
│    ✅ Full validation (~40 minutes)                      │
│    ✅ All platforms, all configs, security               │
│    ✅ Production-ready check                             │
│    💡 Goal: Ready to ship?                               │
│                                                          │
│  Expect: Some PRs pass develop but fail main            │
│  This is OK! Main is the production gate.               │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

**Status:** Planning complete ✅  
**Next Step:** Implement workflow changes when ready  
**Estimated Effort:** 30 minutes to modify workflows + 1 week monitoring
