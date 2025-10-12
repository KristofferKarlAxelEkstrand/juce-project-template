---
applyTo: 'scripts/**/*.sh,scripts/**/*.bat,**/*.sh,**/*.bat'
---

# Shell Script Instructions

Write maintainable, cross-platform shell scripts for build automation and project management. Focus on clarity,
error handling, and user experience.

## Writing Principles

- **Precise**: Write scripts that do exactly what is needed
- **Concise**: Keep scripts short and focused on single tasks
- **Correct**: Test scripts on all target platforms
- **Down-to-earth**: Use standard shell patterns and tools
- **KISS**: Avoid complex logic when simple solutions work
- **Pedagogic**: Write scripts that are easy to read and understand

Avoid decorative output, emojis, emoticons, and promotional language in scripts and messages.

## Script Standards

- Use `set -euo pipefail` in bash scripts for strict error handling
- Add trap handlers for error reporting with line numbers
- Provide `--help` or `-h` flags for all scripts
- Use descriptive variable names with UPPERCASE for constants
- Quote all variable expansions to prevent word splitting

## Cross-Platform Considerations

- Maintain parallel .sh (Unix) and .bat (Windows) versions
- Use forward slashes for paths when possible (works on both)
- Test scripts on all target platforms
- Document platform-specific requirements
- Use CMake for complex cross-platform logic

## Error Handling

- Exit with non-zero status codes on failures
- Print clear error messages to stderr
- Include context in error messages (script name, operation)
- Clean up temporary files on error
- Validate prerequisites before running main logic

## User Experience

- Print clear status messages during execution
- Show progress for long-running operations
- Provide helpful error messages with suggested fixes
- Include usage examples in help text
- Echo important output paths and next steps

## Documentation

- Include header comments explaining script purpose
- Document required environment variables
- List prerequisites and dependencies
- Provide usage examples
- Explain expected output and side effects

## Build Scripts Specific

- Source plugin metadata from CMake-generated files
- Use consistent build directory names (build/ninja, build/default)
- Validate build artifacts after compilation
- Print artifact locations for user convenience
- Handle missing build directories gracefully
