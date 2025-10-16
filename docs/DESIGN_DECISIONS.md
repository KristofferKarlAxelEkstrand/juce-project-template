# Design Decisions

This document explains key architectural decisions in the JUCE Project Template.

## Build Script Duplication vs. Shared Configuration

### Decision: Keep VS Path Detection Logic Duplicated

**Context:** The Visual Studio detection code appears in both `configure-ninja.bat` and `build-ninja.bat`:

```batch
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=..."
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\..." (
    set "VCVARSALL=..."
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\..." (
    set "VCVARSALL=..."
)
```

**Copilot Suggestions:**

- PR review (configure-ninja.bat:12-18): Extract paths to shared config or environment variables
- PR review (build-ninja.bat:12-18): Same VS detection logic is duplicated
- Multiple occurrences of same detection logic flagged as duplication

**Our Decision:** Keep duplication intentionally in **both scripts**.

**Rationale:**

1. **Script Independence**: Each script must work standalone
   - Users may run `build-ninja.bat` directly without running `configure-ninja.bat`
   - Scripts can be copied individually to other projects
   - No dependency on external files or setup steps

2. **Simplicity**: Current approach is easier to understand
   - Self-contained scripts are easier to debug
   - No need to explain shared configuration system
   - Batch file "imports" are error-prone and platform-specific

3. **Small Code Size**: Only ~7 lines duplicated
   - Total script size: ~48 lines each
   - DRY principle matters more for >100 line duplications
   - Maintenance burden is minimal

4. **Robustness**: Avoids potential shared state issues
   - Environment variables can be modified by other processes
   - Shared config files can be accidentally deleted/modified
   - Each script validates VS installation independently

5. **Version Control**: Changes are atomic
   - When updating VS paths, `git diff` clearly shows both scripts updated
   - No risk of forgetting to update shared config
   - Self-documenting changes

**Alternative Considered:**

```batch
REM find-vs.bat (shared script)
@echo off
if exist "C:\Program Files\..." (
    set "VCVARSALL=..."
    exit /b 0
)
exit /b 1

REM build-ninja.bat (would need to call find-vs.bat)
call scripts\find-vs.bat
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: VS not found
    exit /b 1
)
call "%VCVARSALL%" x64
```

**Rejected because:**

- Adds complexity (3 scripts instead of 2)
- Requires explaining the shared script system
- Makes scripts less portable
- Batch file `call` semantics are tricky (variable scope issues)

**When to Revisit:**

Consider extracting if:

- Detection logic grows beyond 20 lines
- We support 5+ VS versions/editions
- We add macOS/Linux equivalents that need similar logic
- Scripts grow to >200 lines total

**Conclusion:**

For ~7 lines of simple path checking, duplication is the right trade-off. The benefits of script independence,
simplicity, and robustness outweigh the minor maintenance cost.

**Reference:** [DRY Principle](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) - "Every piece of knowledge must
have a single, unambiguous, authoritative representation within a system." However, this applies to **knowledge**, not
necessarily **code**. The paths are configuration, not business logic.

---

## Other Design Decisions

### Cross-Platform Script Approach (Dual Scripts vs. Single CMake Script)

**Decision:** Use platform-specific scripts (`.bat` and `.sh`) instead of single CMake script.

**Rationale:**

- Windows requires MSVC environment initialization (vcvarsall.bat)
- Unix systems use system compilers without special setup
- Platform-specific scripts are more explicit and debuggable
- VS Code tasks handle platform selection automatically

### Ninja vs. MSBuild for Windows Development

**Decision:** Default to Ninja for fast incremental builds.

**Rationale:**

- Ninja: 1-3 second incremental builds
- MSBuild: 10-30 second incremental builds
- 10-30x performance improvement for development workflow
- Both remain available via different presets

### Documentation Structure

**Decision:** Separate workflow guide (DEVELOPMENT_WORKFLOW.md) from build system guide (CROSS_PLATFORM_BUILDS.md).

**Rationale:**

- Different audiences: developers (workflow) vs. build engineers (build system)
- Easier to maintain smaller, focused documents
- Prevents intimidating 1000+ line markdown files

---

**Last Updated:** October 11, 2025
