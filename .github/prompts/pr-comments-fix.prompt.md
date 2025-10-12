# PR Review Comment Evaluation

Evaluate all PR review comments and make decisions: Accept (implement), Reject (explain why), or Acknowledge (informational).

## First

```bash
git fetch --all
git pull
git branch --show-current
```

## Core Evaluation Questions

For each comment ask:

1. **Technically correct?** Does it fix a bug, improve safety, or align with best practices?
2. **Worth the change?** Real benefit vs added complexity (KISS principle)?
3. **Project fit?** Matches architecture, conventions, and PR objectives?
4. **Edge cases?** Are there gotchas or constraints the reviewer missed?

## Decision Framework

**Accept if:**

- Fixes bugs/security issues
- Improves safety (null checks, bounds validation)
- Enhances clarity without performance cost
- Fills documentation gaps
- Prevents future maintenance issues

**Reject if:**

- Technically incorrect or impossible
- Adds complexity without clear benefit
- Violates project patterns/architecture
- Purely stylistic with no advantage
- Requires major refactoring for minor gain

## Workflow

1. **Read all comments** - Get full context first
2. **Evaluate each** - Apply decision framework
3. **Implement accepted** - Make changes, commit with reference
4. **Explain rejected** - Technical rationale, trade-offs
5. **Verify changes** - Run lint/build/test if applicable
6. **Communicate clearly** - Brief summary to user

## Response Style

**Be concise and clear:**

✅ **Accepted:**
"Added null check. Protects against future workflow changes. (commit abc1234)"

❌ **Rejected:**
"Can't use `default()` - doesn't exist in GitHub Actions. Current `|| 'develop'` is standard pattern."

🤝 **Acknowledged:**
"Good point about performance - already optimized in commit xyz5678."

## Optional: Quick Summary Note

If helpful for tracking, create brief note in `.temp-pr-reviews-docs/`:

```markdown
# PR #XX Review - Quick Notes

✅ Accepted (3): #1 null check, #4 docs fix, #7 typo
❌ Rejected (2): #3 wrong syntax, #5 over-engineered
🤝 Noted (1): #2 already done

Changes: commit abc1234
Ready to merge: Yes/No
```

**Note:** `.temp-pr-reviews-docs/` is gitignored temp space. Delete after PR merge: `rm -rf .temp-pr-reviews-docs/`

## Focus

**Priority:** Make good decisions and communicate them clearly.

**Not priority:** Writing extensive documentation. Keep notes minimal - just enough to track decisions and explain to user.
