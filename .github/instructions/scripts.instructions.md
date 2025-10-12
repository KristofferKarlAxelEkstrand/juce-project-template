---
applyTo:
  - 'scripts/**/*.sh'
  - 'scripts/**/*.bat'
---

# Shell Script Instructions

Write maintainable, cross-platform shell scripts for build automation and validation. Focus on clarity, error
handling, and platform compatibility.

## Script Standards

- Use strict error handling (`set -e` for Bash, `@echo off` for Batch)
- Include clear header comments explaining script purpose
- Validate prerequisites before executing main logic
- Provide informative error messages with troubleshooting hints
- Use functions to organize complex logic

## Cross-Platform Considerations

- Maintain separate `.sh` and `.bat` scripts for Unix/Windows
- Keep script logic consistent between platform versions
- Test scripts on target platforms before committing
- Document platform-specific behaviors and limitations
- Use portable commands when possible

## Build Scripts

- Detect and configure build environments automatically
- Check for required tools before starting builds
- Output clear status messages during execution
- Handle CMake configuration and build steps separately
- Clean up temporary files on failure

## Validation Scripts

- Check all required dependencies systematically
- Provide actionable feedback for missing tools
- Use exit codes correctly (0 for success, non-zero for failure)
- Test file existence before operations
- Validate build artifacts after successful builds

## Error Handling

- Fail fast on critical errors
- Provide context in error messages
- Suggest remediation steps when possible
- Log errors to stderr when appropriate
- Clean up partial state on failure

## Output Formatting

- Use clear section headers for different checks
- Provide visual feedback (checkmarks, crosses) for status
- Keep output concise but informative
- Use colors sparingly and only when helpful
- Support non-interactive execution (CI/CD)

## Documentation

- Document all script parameters and flags
- Explain environment variables used
- Include usage examples in comments
- Document any assumptions about environment
- Keep documentation current with implementation
