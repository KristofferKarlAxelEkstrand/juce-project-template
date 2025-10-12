# CI Strategy & Philosophy

This document explains the **why** behind the CI configuration choices.

## Core Philosophy

### Development Velocity vs. Security Trade-offs

The CI system uses a **tiered validation approach**:

1. **Fast feedback on `develop`** - Build quality only
2. **Comprehensive validation on `main`** - Build quality + security
3. **Post-merge monitoring** - Continuous security scanning
4. **Release confidence** - Full cross-platform release builds

---

## Workflow Strategy by Branch

### PRs to `develop` - Fast Feedback Loop

**Goal:** Maximize developer velocity during feature development

**Jobs:** 5 parallel jobs (~25-30 minutes)

- ✅ Lint (documentation quality)
- ✅ Build ubuntu Debug (developer build validation)
- ✅ Build ubuntu Release (Linux production build)
- ✅ Build Windows Release (Windows production build)
- ✅ Build macOS Release (macOS production build)

**Rationale:**

- **No CodeQL security scans** - Security happens at `main` gate, not during iteration
- **Focus on build success** - Does the code compile and pass basic quality checks?
- **Cross-platform confidence** - Catch platform-specific issues early
- **Debug build included** - Validates developer workflow and debug symbols

**Why skip security on `develop`?**

- Security scanning adds 10-15 minutes but provides little value during feature iteration
- Features are reviewed and scanned when promoted to `main`
- Weekly schedule catches long-running security issues
- Faster PRs encourage smaller, more frequent commits

---

### PRs to `main` - Production Gate

**Goal:** Comprehensive validation before production merge

**Jobs:** 7 parallel jobs (~35-45 minutes)

- ✅ All 5 build jobs from `develop`
- ✅ CodeQL C++ security analysis
- ✅ CodeQL JavaScript/TypeScript security analysis

**Rationale:**

- **Security gate** - All code entering `main` must pass security scans
- **Production-ready validation** - `main` should always be releasable
- **Final quality check** - Last chance to catch issues before production
- **Compliance requirement** - Security scanning required for production code

**Why full security on `main`?**

- `main` represents production-ready code
- Security vulnerabilities must be caught before release
- Compliance and audit trail for security practices
- Slower CI acceptable for production gate (not used for iteration)

---

### Push to `main` - Post-Merge Monitoring

**Goal:** Continuous security monitoring without blocking merges

**Jobs:** 2 parallel jobs (~10-15 minutes)

- ✅ CodeQL C++ analysis
- ✅ CodeQL JavaScript/TypeScript analysis

**Rationale:**

- **No builds** - Already validated in PR, don't waste CI minutes
- **Security-only** - Catch issues introduced by merge conflicts
- **Audit trail** - Continuous compliance monitoring
- **Non-blocking** - Results inform but don't prevent deployment

---

### Weekly Schedule - Background Monitoring

**Goal:** Catch newly-discovered vulnerabilities in dependencies

**Jobs:** 2 parallel jobs (~10-15 minutes, Mondays at 3:34 AM)

- ✅ CodeQL C++ analysis
- ✅ CodeQL JavaScript/TypeScript analysis

**Rationale:**

- **Fresh vulnerability detection** - CodeQL database updates weekly
- **Zero-day monitoring** - Catch new CVEs in JUCE or dependencies
- **No code change required** - Scans even when no commits
- **Off-peak execution** - Runs when developers aren't waiting

---

### Version Tags - Release Pipeline

**Goal:** Create distributable production artifacts

**Jobs:** 4 jobs (~20-25 minutes)

- ✅ Build Linux (Release)
- ✅ Build Windows (Release)
- ✅ Build macOS (Release)
- ✅ Create GitHub Release with all artifacts

**Rationale:**

- **Clean release builds** - No debug artifacts, no lint checks
- **Cross-platform distribution** - All platforms built from same tag
- **Automated publishing** - Zero-touch release to GitHub Releases
- **Artifact archival** - Permanent record of shipped binaries

---

## Resource Optimization Strategy

### Current Resource Usage (per week estimate)

Assuming:

- 10 PRs to `develop` per week
- 2 PRs to `main` per week
- 5 pushes to `main` per week
- 1 weekly scheduled scan
- 0.25 releases per week (1 per month)

**Weekly CI Minutes:**

- PRs to `develop`: 10 × 25 min = 250 minutes
- PRs to `main`: 2 × 40 min = 80 minutes
- Pushes to `main`: 5 × 12 min = 60 minutes
- Weekly scan: 1 × 12 min = 12 minutes
- Releases: 0.25 × 22 min = 5.5 minutes

**Total: ~410 CI minutes/week** (~7 hours)

### Value Delivered

**Time Saved by Skipping CodeQL on `develop`:**

- 10 PRs × 10 minutes saved = 100 CI minutes/week saved
- **24% reduction in CI usage** vs. running security on all PRs
- **Faster feedback** encourages more frequent, smaller PRs

**When This Strategy Works Best:**

- Active feature development with many small PRs to `develop`
- Git Flow-style workflow (`develop` → `main` → production)
- Team culture of frequent commits and PR reviews
- Security review concentrated at production gate

**When to Reconsider:**

- Regulatory requirement for security scan on every commit
- Very infrequent PRs to `main` (security debt builds up)
- External contributors without review process
- Direct pushes to `develop` bypassing PR flow

---

## Design Decisions

### Why Debug Build Only on Ubuntu?

**Decision:** Run Debug build on Linux only, not Windows/macOS

**Rationale:**

- Debug symbols work consistently across platforms
- JUCE debug assertions are platform-independent
- Saves 10-15 CI minutes per PR
- Windows/macOS Debug builds rarely catch unique issues

**When to Add Platform-Specific Debug:**

- Platform-specific debug assertions found
- Debugger-specific issues (MSVC vs. lldb vs. gdb)
- Release vs. Debug ABI incompatibilities discovered

---

### Why Lint on Every PR?

**Decision:** Run markdown linting even on code-only changes

**Rationale:**

- Fast (<1 minute) so minimal cost
- Enforces documentation quality as first-class concern
- Catches accidental markdown in commit messages
- Consistent formatting across all PRs

**Future Optimization:**

- Could skip if `paths-ignore: ['**/*.md']` but risks missing docs updates

---

### Why Cross-Platform Builds on `develop`?

**Decision:** Run Windows/macOS builds on `develop`, not just `main`

**Rationale:**

- Platform-specific issues caught early (before `main` PR)
- JUCE has subtle platform differences (CoreAudio, WASAPI, ALSA)
- Windows/macOS developers benefit from their platform in PR checks
- Avoids "works on Linux but fails on macOS" surprises at `main` gate

**Alternative Considered:**

- Linux-only on `develop`, full matrix on `main`
- Rejected: Too late to catch platform issues

---

### Why No Builds on `main` Pushes?

**Decision:** Only run CodeQL after merge, skip rebuilding

**Rationale:**

- Already built and tested in PR (redundant)
- Merge conflicts are rare and caught quickly if they happen
- Saves significant CI minutes (4 builds × 5 min = 20 min)
- Security scanning is incremental and fast

**Exception Handling:**

- Manual workflow_dispatch available to force rebuild if needed
- Release tags trigger fresh builds anyway

---

## Comparison to Alternatives

### Alternative 1: Security on Every PR

**Approach:** Run CodeQL on all PRs to both `develop` and `main`

**Pros:**

- Maximum security coverage
- Earlier detection of vulnerabilities

**Cons:**

- +100 CI minutes/week (24% increase)
- Slower feedback loop during development
- Diminishing returns (most issues caught at `main` gate anyway)

**Verdict:** ❌ Not adopted - Cost exceeds benefit for active development

---

### Alternative 2: No Security in CI

**Approach:** Manual security reviews only, no automated scanning

**Pros:**

- Minimal CI time
- Maximum development velocity

**Cons:**

- Human error in security review
- No compliance audit trail
- Vulnerable to zero-day exploits

**Verdict:** ❌ Not adopted - Security is non-negotiable

---

### Alternative 3: Lint-Only on `develop`

**Approach:** Skip all builds on `develop`, only lint

**Pros:**

- Extremely fast PRs (<1 minute)
- Force all real validation to `main`

**Cons:**

- Breaks often at `main` gate (bad developer experience)
- Cross-platform issues discovered too late
- Debug build issues not caught until production promotion

**Verdict:** ❌ Not adopted - False velocity (fast PRs but slow merges)

---

## Future Optimization Ideas

### Path-Based Filtering (Not Yet Implemented)

Skip builds when only documentation changes:

**Potential Savings:** 25 minutes per docs-only PR

**Complexity:** Medium (needs careful path configuration)

**Risk:** Low (easy to force full build with label)

---

### Conditional Debug Builds (Not Yet Implemented)

Run Debug build only when label `debug-build` present:

**Potential Savings:** 6 minutes per PR × 80% of PRs = ~50 minutes/week

**Complexity:** Medium (label-based workflow dispatch)

**Risk:** Medium (might miss debug-specific issues)

---

### Better JUCE Caching (Not Yet Implemented)

Improve cache hit rate for JUCE dependencies:

**Potential Savings:** 30-60 seconds per job × 5 jobs = 2-5 minutes per PR

**Complexity:** Low (cache key tuning)

**Risk:** Low (cache invalidation is safe)

---

## Success Metrics

### Developer Experience

- **PR cycle time:** Median time from PR open to merge
- **CI wait time:** Time spent waiting for CI to complete
- **False positive rate:** PRs that pass CI but fail in production

**Target Metrics:**

- `develop` PR feedback: <30 minutes
- `main` PR feedback: <45 minutes
- False negative rate: <1% (builds pass but break production)

### Resource Efficiency

- **CI minutes per week:** Total GitHub Actions minutes consumed
- **Cost per PR:** Average CI time per pull request
- **Cache hit rate:** Percentage of JUCE dependency cache hits

**Target Metrics:**

- Weekly CI usage: <500 minutes (~8 hours)
- Average PR cost: <30 minutes
- JUCE cache hit: >80%

---

## Implementation Checklist

When modifying CI strategy:

- [ ] Update `CI_TRIGGERS.md` with new trigger matrix
- [ ] Update `CI_STRATEGY.md` with rationale
- [ ] Update `CI_OPTIMIZATION_PLAN.md` if optimization proposed
- [ ] Test on feature branch before merging to `main`
- [ ] Monitor CI minutes usage for 1 week after change
- [ ] Document any unexpected behavior or edge cases

---

**Last Updated:** October 12, 2025
**Status:** Current strategy (implemented)
**Review Cycle:** Quarterly or when CI usage exceeds budget
