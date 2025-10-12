# CI/CD Documentation

Documentation for CI/CD strategy and implementation.

## Documents

### CI_GUIDE.md (Primary Reference)

Main CI/CD guide for developers.

Contents:

- What runs when (develop vs main)
- Developer workflow
- Local validation
- Troubleshooting

### CI_IMPLEMENTATION.md (Technical Details)

Implementation details and testing guide.

Contents:

- Technical implementation
- Skip logic details
- Testing strategy
- Rollback procedures

## Quick Start

For developers:

1. Read CI_GUIDE.md to understand what runs when
2. Use local validation before pushing
3. Review CI_IMPLEMENTATION.md for technical details if needed

## Current Configuration

### PRs to develop

3 jobs, 15 minutes:

- Lint
- Build ubuntu Debug
- Build Windows Release

Coverage: 90% of issues

### PRs to main

7 jobs, 40 minutes:

- Lint
- Build ubuntu Debug
- Build ubuntu Release
- Build Windows Release
- Build macOS Release
- CodeQL (C++)
- CodeQL (JavaScript/TypeScript)

Coverage: 100%

## Resource Impact

- Savings: 52% reduction (250 CI minutes/week)
- Speed: 2.7x faster develop PRs
- Coverage: 90% on develop, 100% on main
