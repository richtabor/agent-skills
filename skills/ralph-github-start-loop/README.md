# Ralph GitHub Start Loop

Runs an autonomous loop that fetches stories from GitHub Issues, implements them, and closes issues as they're completed. Works in a git worktree to avoid conflicts with your working directory.

## Quick Start

1. Create issues with `/ralph-github-create-issues`
2. Run: `/loop-github-issues`, `/loop-github-issues --all`, or `/loop-github-issues auth-flow`
3. The skill picks up stories from GitHub Issues, implements them, and closes each one
4. When all sub-issues are closed, a PR is created automatically

## Usage

```
/loop-github-issues              # Interactive: shows PRDs, asks which to run
/loop-github-issues --all        # Run all available PRDs
/loop-github-issues auth-flow    # Run PRDs matching search term
/loop-github-issues 25           # Run with 25 iterations per PRD
/loop-github-issues --all 25     # Run all PRDs with 25 iterations each
```

## What It Does

- Lists open PRD issues (by `prd` label) that don't already have open PRs
- Creates a git worktree at `../{repo}-{feature}/`
- For each iteration, picks the next open sub-issue and implements it
- Commits with `feat: Story Title (closes #XXX)` to auto-close issues
- Creates a PR when all sub-issues are closed
- Cleans up the worktree when done

## Prerequisites

- `gh` CLI authenticated
- PRD issues created via `/ralph-github-create-issues`

## Monitoring

- **Local**: `cat /tmp/ralph-status-{repo}-{prd-number}.txt`
- **GitHub**: Progress comments are posted to the PRD issue

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions, issue conventions, and process details |
| `references/prompt.md` | Prompt template for the autonomous agent |
| `scripts/loop-github-issues.sh` | The loop script that orchestrates execution |

## Tips

- Run multiple instances in parallel on independent PRDs (separate terminals)
- Each instance works in its own worktree, so there are no conflicts
- PRDs with unresolved blocking dependencies are automatically skipped
