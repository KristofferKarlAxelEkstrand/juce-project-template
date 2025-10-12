# Refactoring Checklist: JUCE Plugin Template

**Based on:** Comprehensive audit findings  
**Last Updated:** October 12, 2025  
**Status:** Planning complete, ready for implementation

## Quick Reference

- 📋 **Total Issues:** 42 identified
- ⏰ **Total Effort:** 45-60 hours (Phases 1-3)
- 🎯 **Priority:** Focus on Phase 1 (P0 items)
- ✅ **Current Status:** Audit complete, awaiting approval

## Phase 1: Critical Foundations (Week 1-2)

**Goal:** Address critical gaps preventing professional recommendation  
**Effort:** 10-15 hours  
**Risk:** Low

### Testing Infrastructure

- [ ] **Add JUCE UnitTest framework** (4h)
  - [ ] Update CMakeLists.txt to add test target
  - [ ] Create tests/CMakeLists.txt
  - [ ] Create src/Tests.cpp with 4 basic tests
  - [ ] Add ctest integration
  - [ ] Document how to write and run tests
  - **Files:** `CMakeLists.txt`, `tests/CMakeLists.txt`, `src/Tests.cpp`, `DEVELOPMENT_WORKFLOW.md`

- [ ] **Add CI test execution** (1h)
  - [ ] Update .github/workflows/ci.yml to run tests
  - [ ] Add test results reporting
  - [ ] Configure test timeout
  - **Files:** `.github/workflows/ci.yml`

### Documentation Consolidation

- [ ] **Consolidate CI documentation** (2h)
  - [ ] Create docs/CI.md (merge CI_GUIDE, CI_IMPLEMENTATION, CI_README)
  - [ ] Update all links to CI docs
  - [ ] Delete old CI docs
  - [ ] Verify no information lost
  - **Files:** `docs/CI.md` (new), delete 3 old files, update links in all docs

### Script Improvements

- [ ] **Add error handling to all scripts** (2h)
  - [ ] Add `set -euo pipefail` to configure-ninja.sh
  - [ ] Add `set -euo pipefail` to build-ninja.sh
  - [ ] Add `set -euo pipefail` to validate-builds.sh
  - [ ] Add `set -euo pipefail` to validate-setup.sh
  - [ ] Add `set -euo pipefail` to test-builds.sh
  - [ ] Add error trap handlers
  - **Files:** All `scripts/*.sh` files

- [ ] **Add --help to all scripts** (1h)
  - [ ] Add help function to each script
  - [ ] Document parameters and examples
  - [ ] Add usage message on error
  - **Files:** All `scripts/*.sh` and `scripts/*.bat` files

### Quick Start Guide

- [ ] **Create QUICKSTART.md** (3h)
  - [ ] Write 5-minute getting started guide
  - [ ] Add prerequisite checking steps
  - [ ] Add platform-specific instructions
  - [ ] Add common first-time issues section
  - [ ] Link to detailed docs
  - **Files:** `QUICKSTART.md` (new)

- [ ] **Update README.md** (1h)
  - [ ] Add prominent quick start link at top
  - [ ] Clarify audience (beginners vs experienced)
  - [ ] Add success metric (5-minute first build)
  - **Files:** `README.md`

### Validation

- [ ] **Test Phase 1 changes on all platforms**
  - [ ] Ubuntu Debug build and test
  - [ ] Windows Release build and test
  - [ ] macOS Release build and test
  - [ ] Verify all docs render correctly
  - [ ] Verify all links work

- [ ] **Review checkpoint**
  - [ ] Stakeholder review
  - [ ] Gather feedback
  - [ ] Go/no-go for Phase 2

---

## Phase 2: High-Value Improvements (Week 3-4)

**Goal:** Improve consistency and developer experience  
**Effort:** 15-20 hours  
**Risk:** Medium (breaking changes)

### Build System Standardization

- [ ] **Standardize build directories** (5h)
  - [ ] Update CMakePresets.json (default → build/default)
  - [ ] Update all scripts for new paths
  - [ ] Update .vscode/tasks.json
  - [ ] Update .github/workflows/ci.yml
  - [ ] Update all documentation
  - [ ] Add migration guide for existing users
  - [ ] Test on all platforms
  - **Files:** `CMakePresets.json`, all scripts, all workflows, all docs

### Developer Experience

- [ ] **Add debugger configurations** (3h)
  - [ ] Create .vscode/launch.json
  - [ ] Add standalone debug config
  - [ ] Add plugin-in-host configs
  - [ ] Add platform-specific variants
  - [ ] Document debugger usage
  - **Files:** `.vscode/launch.json` (new), `docs/IDE_SETUP.md`

- [ ] **Fix VS Code hardcoded paths** (1h)
  - [ ] Add prominent warning comment at top of tasks.json
  - [ ] Add inline comments on each hardcoded path
  - [ ] Document in DEVELOPMENT_WORKFLOW.md
  - **Files:** `.vscode/tasks.json`, `DEVELOPMENT_WORKFLOW.md`

- [ ] **Create IDE setup documentation** (3h)
  - [ ] Document CLion setup
  - [ ] Document Visual Studio setup
  - [ ] Document Xcode setup
  - [ ] Add screenshots for each IDE
  - [ ] Add troubleshooting per IDE
  - **Files:** `docs/IDE_SETUP.md` (new)

### Documentation Organization

- [ ] **Create documentation index** (2h)
  - [ ] Create docs/README.md as navigation hub
  - [ ] Categorize all docs (getting started, guides, reference)
  - [ ] Add clear learning path
  - [ ] Update main README to link to index
  - **Files:** `docs/README.md` (new), `README.md`

- [ ] **Clarify BUILD.md vs DEVELOPMENT_WORKFLOW.md** (1h)
  - [ ] Add clear scope statement to each
  - [ ] Remove overlapping content
  - [ ] Cross-reference appropriately
  - **Files:** `BUILD.md`, `DEVELOPMENT_WORKFLOW.md`

### CI/CD Optimization

- [ ] **Optimize CI caching** (3h)
  - [ ] Separate JUCE cache (fixed key)
  - [ ] Separate build artifact cache
  - [ ] Test cache hit rates
  - [ ] Update both ci.yml and release.yml
  - **Files:** `.github/workflows/ci.yml`, `.github/workflows/release.yml`

- [ ] **Add build time metrics** (2h)
  - [ ] Add timing to CI builds
  - [ ] Report in step summary
  - [ ] Add timing to local scripts
  - **Files:** `.github/workflows/ci.yml`, scripts

### Validation

- [ ] **Test Phase 2 changes**
  - [ ] Verify builds work with new directory structure
  - [ ] Test debugger on all platforms
  - [ ] Verify cache improvements (measure CI time)
  - [ ] Check all documentation links

- [ ] **Review checkpoint**
  - [ ] Stakeholder review
  - [ ] User testing
  - [ ] Go/no-go for Phase 3

---

## Phase 3: Professional Polish (Week 5-7)

**Goal:** Add industry-standard professional features  
**Effort:** 20-25 hours  
**Risk:** Medium

### Plugin Validation

- [ ] **Add Pluginval integration** (4h)
  - [ ] Add pluginval download step to CI
  - [ ] Run validation on Release builds
  - [ ] Upload validation results as artifacts
  - [ ] Document pluginval in CI.md
  - [ ] Set appropriate strictness level
  - **Files:** `.github/workflows/ci.yml`, `docs/CI.md`

### Parameter System Upgrade

- [ ] **Migrate to AudioProcessorValueTreeState** (6h)
  - [ ] Add APVTS to MainComponent.h
  - [ ] Update MainComponent.cpp to use APVTS
  - [ ] Update PluginEditor.cpp for parameter attachments
  - [ ] Test DAW automation
  - [ ] Test undo/redo
  - [ ] Add migration guide
  - [ ] Document APVTS usage
  - **Files:** `src/MainComponent.h`, `src/MainComponent.cpp`, `src/PluginEditor.cpp`, docs

### Preset Management

- [ ] **Add preset system example** (4h)
  - [ ] Add preset load/save buttons to GUI
  - [ ] Implement preset file I/O
  - [ ] Create example preset files
  - [ ] Document preset format
  - **Files:** `src/PluginEditor.cpp`, `presets/` (new directory)

### Integration Testing

- [ ] **Add integration tests** (5h)
  - [ ] Create tests/IntegrationTests.cpp
  - [ ] Test plugin loading
  - [ ] Test audio processing
  - [ ] Test parameter changes
  - [ ] Test state save/load
  - [ ] Add to CI
  - **Files:** `tests/IntegrationTests.cpp`, `tests/CMakeLists.txt`, `.github/workflows/ci.yml`

### Documentation Reorganization

- [ ] **Reorganize docs directory** (3h)
  - [ ] Create docs/getting-started/ directory
  - [ ] Create docs/guides/ directory
  - [ ] Create docs/reference/ directory
  - [ ] Move files to appropriate locations
  - [ ] Update all internal links
  - [ ] Update docs/README.md navigation
  - **Files:** Many doc files moved

- [ ] **Create central troubleshooting** (3h)
  - [ ] Create docs/TROUBLESHOOTING.md
  - [ ] Consolidate all troubleshooting sections
  - [ ] Add index by error message
  - [ ] Link from main docs
  - **Files:** `docs/TROUBLESHOOTING.md` (new)

### Validation

- [ ] **Test Phase 3 changes**
  - [ ] Run pluginval on all platforms
  - [ ] Test APVTS in multiple DAWs
  - [ ] Verify preset load/save
  - [ ] Run all integration tests
  - [ ] Check documentation completeness

- [ ] **Final review checkpoint**
  - [ ] Comprehensive QA
  - [ ] User acceptance testing
  - [ ] Prepare release notes

---

## Phase 4: Advanced Features (Week 8-9, Optional)

**Goal:** Add power-user features  
**Effort:** 15-20 hours  
**Risk:** Low

- [ ] **Dev container configuration** (4h)
  - [ ] Create .devcontainer/devcontainer.json
  - [ ] Create .devcontainer/Dockerfile
  - [ ] Test with VS Code Remote Containers
  - [ ] Document usage

- [ ] **CMake linting** (2h)
  - [ ] Add cmake-lint to CI
  - [ ] Add pre-commit hook
  - [ ] Fix any issues found

- [ ] **Performance benchmarks** (5h)
  - [ ] Add benchmark target
  - [ ] Measure processBlock timing
  - [ ] Track in CI
  - [ ] Set performance budgets

- [ ] **ccache integration** (3h)
  - [ ] Detect ccache in CMakeLists.txt
  - [ ] Enable in CI
  - [ ] Document setup

- [ ] **Multiple DSP examples** (6h)
  - [ ] Create examples/ directory
  - [ ] Add filter example
  - [ ] Add delay example
  - [ ] Add MIDI synth example
  - [ ] Document each example

---

## Tracking and Metrics

### Progress Metrics

- [ ] **Phase 1:** _____ / 5 tasks complete (___%)
- [ ] **Phase 2:** _____ / 7 tasks complete (___%)
- [ ] **Phase 3:** _____ / 6 tasks complete (___%)
- [ ] **Phase 4:** _____ / 5 tasks complete (___%)

### Success Metrics

- [ ] Test coverage >80% of DSP code
- [ ] CI time <15 min on develop
- [ ] CI time <40 min on main
- [ ] First build success >90%
- [ ] Documentation <3 clicks to any topic
- [ ] New user builds plugin in <10 minutes

### Quality Gates

- [ ] All tests pass on all platforms
- [ ] All documentation renders correctly
- [ ] All links work (no 404s)
- [ ] Pluginval passes (Phase 3+)
- [ ] No linting errors
- [ ] CI builds are green

---

## Issue Labels (for GitHub Project)

When creating issues, use these labels:

- `phase-1-critical` - P0 items, must fix
- `phase-2-high-value` - P1 items, high impact
- `phase-3-polish` - P2 items, professional features
- `phase-4-advanced` - P3 items, optional
- `breaking-change` - Requires migration guide
- `documentation` - Doc-only changes
- `ci-cd` - CI/CD changes
- `build-system` - CMake/build changes
- `testing` - Test infrastructure
- `good-first-issue` - Easy entry point

---

## Git Workflow

### Branch Strategy

- `main` - Production ready
- `develop` - Integration branch
- `refactor/phase-1` - Phase 1 work
- `refactor/phase-2` - Phase 2 work
- `refactor/phase-3` - Phase 3 work

### Commit Message Format

```
type(scope): Brief description

- Detailed change 1
- Detailed change 2

Relates to #<issue-number>
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `ci`, `build`

### PR Strategy

- Each phase gets one PR
- Breaking changes clearly documented
- All tests must pass
- Documentation updated
- Reviewer approval required

---

## Notes and Decisions

### Decisions Made

- [ ] Date: _____ - Approved Phase 1 implementation
- [ ] Date: _____ - Go/no-go for Phase 2
- [ ] Date: _____ - Go/no-go for Phase 3
- [ ] Date: _____ - Phase 4 scope decision

### Open Questions

- [ ] Should APVTS completely replace manual atomics or show both?
- [ ] Should basics-*.md docs be kept or replaced with external links?
- [ ] What strictness level for pluginval (5 or 10)?
- [ ] Should tests run on every CI build or only PRs to main?

### Risks Being Monitored

- [ ] Breaking changes impact on existing users
- [ ] CI stability during caching changes
- [ ] Scope creep beyond planned phases

---

## Completion Checklist

### Phase 1 Complete When

- [ ] All P0 tasks checked off above
- [ ] Tests pass on all platforms
- [ ] Documentation complete and linked
- [ ] CI green on all jobs
- [ ] Stakeholder review approved
- [ ] Tag: `v2.0.0-phase1`

### Phase 2 Complete When

- [ ] All P1 tasks checked off above
- [ ] Build directory changes tested
- [ ] All IDEs documented
- [ ] CI optimizations validated
- [ ] Breaking changes documented
- [ ] Tag: `v2.0.0-phase2`

### Phase 3 Complete When

- [ ] All P2 tasks checked off above
- [ ] Pluginval passing
- [ ] APVTS migration complete
- [ ] Integration tests green
- [ ] Documentation reorganized
- [ ] Tag: `v2.0.0` (final)

### Phase 4 Complete When

- [ ] Optional features implemented as desired
- [ ] All features documented
- [ ] Tag: `v2.1.0` (feature release)

---

**Last Updated:** October 12, 2025  
**Next Review:** After Phase 1 completion  
**Template Version Target:** 2.0.0
