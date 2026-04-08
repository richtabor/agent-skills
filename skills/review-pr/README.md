# Review PR

Fetches, evaluates, and addresses PR review comments from GitHub. Verifies each comment against the actual codebase before acting — many reviewer comments reference outdated code or misunderstand the logic.

## Quick Start

1. Have an open PR with review comments
2. Ask: "Review PR comments", "Address PR feedback", or "Fix PR comments"
3. The skill fetches comments, reads the actual code, evaluates each one, replies, and resolves all threads
4. Returns a summary of what was addressed, fixed, or explained

## What It Does

- Fetches all review comments from a GitHub PR
- Reads the actual current code before evaluating any comment
- Categorizes each comment as **Already addressed**, **Fix**, or **Won't fix**
- Implements fixes for valid bugs and typos
- Replies to every comment with concise reasoning
- Resolves all threads automatically
- Runs as a single pass — no pausing for confirmation

## Comment Categories

| Category | When | Action |
|----------|------|--------|
| Already addressed | Issue was fixed or reviewer misread the code | Explains what the code actually does |
| Fix | Valid bug, security issue, or typo in current code | Implements the fix, replies with commit hash |
| Won't fix | Over-engineering, style preference, or would break consistency | Explains reasoning |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Full process, evaluation guidelines, reply templates, and common reviewer misunderstandings |

## Tips

- The skill always reads the actual file before evaluating — reviewers often reference outdated line numbers
- Common false positives: inverted conditions that are actually correct, validation that exists elsewhere, tokens in error messages that aren't sensitive
- Replies are concise (1-2 sentences) and explain reasoning, not just dismiss
