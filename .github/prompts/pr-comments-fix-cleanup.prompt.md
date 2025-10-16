# PR Review Cleanup & Merge Check

Quick final verification before marking PR as ready to merge.

## Pre-Merge Checklist

**1. All comments addressed?**

- Every comment has Accept/Reject/Acknowledge decision
- Accepted items implemented (verify commits exist)
- Rejected items have clear technical rationale

**2. Changes validated?**

```bash
# Quick validation
npm test              # Markdown linting
git status            # Should be clean
git log --oneline -3  # Check commits
```

**3. Commit quality?**

- Follows Conventional Commits (`docs:`, `feat:`, `fix:`)
- Clear descriptions
- References PR number if applicable

**4. Ready to merge?**

- No blockers
- All validation passes
- Working tree clean

## Quick Summary to User

Provide brief status:

```markdown
## Review Complete ✅

**Comments:** X total (Y accepted, Z rejected) **Changes:** [commit abc1234] or [none needed] **Status:** Ready to merge
/ Needs attention

**Key decisions:**

- Accepted: Brief list
- Rejected: Brief list with reason
```

## Post-Merge Cleanup

After PR merges:

```bash
# Delete temp review files
rm -rf .temp-pr-reviews-docs/
```

## Focus

**Priority:** Verify PR is ready, communicate status clearly.

**Not priority:** Extensive documentation. Quick check and go.
