---
applyTo:
  - '.github/workflows/*.yml'
  - '.github/workflows/*.yaml'
---

# GitHub Workflows Instructions

Configure CI/CD workflows for efficient, reliable builds across platforms. Follow GitHub Actions best practices
and optimize for cost and speed.

## Workflow Design Principles

- Use descriptive workflow and job names
- Implement conditional execution for cost optimization
- Cache dependencies when possible
- Run jobs in parallel when independent
- Fail fast to save resources

## Build Matrix Strategy

- Define clear matrix dimensions (OS, build type, configuration)
- Use `run_on_develop` flags for conditional job execution
- Skip unnecessary jobs on develop PRs (60% resource savings)
- Run comprehensive validation on main PRs (100% coverage)
- Document matrix strategy in workflow comments

## Job Organization

- Separate linting, building, and testing into distinct jobs
- Use job dependencies (`needs:`) to enforce ordering
- Skip jobs early with conditional checks
- Provide clear step names for debugging
- Log skip decisions explicitly

## Platform-Specific Builds

- Test on ubuntu-latest, windows-latest, macos-latest
- Use appropriate build tools for each platform
- Handle platform-specific dependencies correctly
- Cache platform-specific build artifacts
- Set correct environment variables per platform

## Security Scanning

- Run CodeQL analysis on C++ and JavaScript/TypeScript
- Trigger security scans only on main PRs
- Use latest CodeQL action versions
- Configure language-specific analysis correctly
- Review and address findings promptly

## Performance Optimization

- Use GitHub Actions caching for dependencies
- Minimize checkout depth when possible
- Run expensive jobs only when necessary
- Use artifacts for inter-job data transfer
- Monitor workflow execution times

## Error Handling

- Provide clear error messages in failed steps
- Include troubleshooting hints in step names
- Use continue-on-error sparingly
- Fail fast when critical steps fail
- Log sufficient context for debugging

## Workflow Triggers

- Trigger on pull requests to protected branches
- Use path filters to skip irrelevant changes
- Document trigger conditions clearly
- Avoid redundant workflow runs
- Consider manual workflow dispatch for testing

## Documentation Requirements

- Comment complex workflow logic
- Document matrix strategy and skip logic
- Explain conditional execution decisions
- Reference related documentation (CI_GUIDE.md, etc.)
- Keep workflow documentation current
