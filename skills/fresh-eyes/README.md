# Fresh Eyes

Re-reads code you just wrote with a fresh perspective to catch bugs, errors, and issues. Focuses only on real problems — won't refactor, add features, or change style preferences.

## Quick Start

1. Finish writing or modifying code
2. Ask: "Fresh eyes", "Review my code", "Check for bugs", or "Did I miss anything?"
3. The skill re-reads all changed files looking for bugs and errors
4. Issues are fixed immediately with a summary of what changed

## What It Does

- Identifies all files modified in the current session
- Re-reads each file as if seeing it for the first time
- Catches logic errors, off-by-one bugs, typos, missing return statements
- Finds missing error handling, edge cases, and cleanup code
- Fixes issues immediately without asking permission
- Reports a summary of everything found and fixed

## What It Checks

- **Logic errors** — Off-by-one, inverted conditions, race conditions, wrong comparisons
- **Obvious bugs** — Typos, copy-paste errors, forgotten returns, wrong function calls
- **Missing pieces** — Error handling gaps, uncovered edge cases, missing cleanup
- **Confusion risks** — Misleading variable names, magic numbers, inconsistent patterns

## What It Won't Do

- Refactor working code
- Add features or comments
- Change style preferences
- Optimize prematurely
- Reorganize file structure

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions, checklist, and review process |

## Tips

- Use after completing a feature or fix, before committing
- Works best when you've been deep in implementation and need a reset
- The skill fixes issues directly — review the summary to understand what changed
