# Better Tools for AI-Assisted C++ Audio Development

This document describes the static analysis, sanitizers, and real-time safety tools integrated into this project to help
AI assistants (and developers) write better and safer C++ audio code.

## Implementation Status

| Phase   | Description           | Status                  |
| ------- | --------------------- | ----------------------- |
| Phase 1 | compile_commands.json | ✅ Complete             |
| Phase 2 | clang-tidy            | ✅ Complete             |
| Phase 3 | Sanitizer presets     | ✅ Complete             |
| Phase 4 | Real-time safety      | ✅ Available (Clang 20) |
| Phase 5 | cppcheck integration  | ✅ Complete             |
| Phase 6 | VS Code tasks         | ✅ Complete             |
| Phase 7 | Unified scripts       | ✅ Complete             |

## Available Tools

### Static Analysis

| Tool       | Command                            | Purpose                         |
| ---------- | ---------------------------------- | ------------------------------- |
| clang-tidy | `./scripts/run-clang-tidy.sh`      | Deep C++ analysis with auto-fix |
| cppcheck   | `./scripts/run-cppcheck.sh`        | Fast supplementary analysis     |
| Combined   | `./scripts/run-static-analysis.sh` | Run both tools                  |

### Sanitizer Builds

| Sanitizer                  | Command                                 | Detects                         |
| -------------------------- | --------------------------------------- | ------------------------------- |
| AddressSanitizer           | `./scripts/run-with-sanitizer.sh asan`  | Memory errors, buffer overflows |
| UndefinedBehaviorSanitizer | `./scripts/run-with-sanitizer.sh ubsan` | Undefined behavior              |
| ThreadSanitizer            | `./scripts/run-with-sanitizer.sh tsan`  | Data races                      |
| RealtimeSanitizer          | `./scripts/run-with-sanitizer.sh rtsan` | Real-time violations            |

### VS Code Tasks

Available via `Ctrl+Shift+P` → "Run Task":

- Run Static Analysis
- Run clang-tidy
- Run cppcheck
- Build with AddressSanitizer
- Build with ThreadSanitizer
- Build with UndefinedBehaviorSanitizer
- Build with RealtimeSanitizer

## Quick Reference

### After Any Code Change

```bash
./scripts/run-clang-tidy.sh src/YourFile.cpp
```

### Before Committing

```bash
./scripts/run-static-analysis.sh
```

### Debugging Memory Issues

```bash
./scripts/run-with-sanitizer.sh asan
```

### Debugging Thread Issues

```bash
./scripts/run-with-sanitizer.sh tsan
```

## Configuration Files

| File                 | Purpose                                     |
| -------------------- | ------------------------------------------- |
| `.clang-tidy`        | clang-tidy check configuration              |
| `CMakePresets.json`  | Sanitizer build presets (asan, ubsan, tsan) |
| `.vscode/tasks.json` | VS Code task definitions                    |

## Interpreting Tool Output

### clang-tidy

```text
src/MainComponent.cpp:42:5: warning: use nullptr [modernize-use-nullptr]
```

**Action**: Apply the suggested fix or run with `--fix` flag to auto-correct.

### AddressSanitizer

```text
ERROR: AddressSanitizer: heap-use-after-free on address 0x...
```

**Action**: A pointer is being used after the memory was freed. Check object lifetimes.

### ThreadSanitizer

```text
WARNING: ThreadSanitizer: data race
  Write of size 4 at 0x... by thread T1
  Previous read of size 4 at 0x... by main thread
```

**Action**: Two threads access the same memory without synchronization. Use `std::atomic` or proper locking.

### cppcheck

```text
src/MainComponent.cpp:50: error: Null pointer dereference [nullPointer]
```

**Action**: Check that pointer is valid before dereferencing.

## Real-Time Safety Analysis (Clang 20)

The dev container includes Clang 20 with real-time safety features:

### Function Effect Analysis

Add `[[clang::nonblocking]]` attribute to audio callbacks for compile-time verification:

```cpp
void processBlock(juce::AudioBuffer<float>& buffer,
                  juce::MidiBuffer& midiMessages) [[clang::nonblocking]] override
{
    // Compiler will warn about allocations, locks, or blocking calls here
}
```

Enable with: `-Wfunction-effects` compiler flag.

### RealtimeSanitizer (rtsan)

Detects real-time violations at runtime:

```bash
./scripts/run-with-sanitizer.sh rtsan
```

Catches:

- Memory allocations in audio callbacks
- Mutex locks
- System calls that may block

## References

- [clang-tidy Documentation](https://clang.llvm.org/extra/clang-tidy/)
- [AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html)
- [UndefinedBehaviorSanitizer](https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html)
- [ThreadSanitizer](https://clang.llvm.org/docs/ThreadSanitizer.html)
- [Function Effect Analysis](https://clang.llvm.org/docs/FunctionEffectAnalysis.html)
- [RealtimeSanitizer](https://clang.llvm.org/docs/RealtimeSanitizer.html)
- [cppcheck Manual](https://cppcheck.sourceforge.io/manual.html)
