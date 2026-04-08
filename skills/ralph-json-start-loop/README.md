# Ralph JSON Start Loop

Runs the Ralph autonomous loop to execute features from `prds/*.json` files using git worktrees. Picks stories in order, implements them, runs quality checks, and commits progress.

## Quick Start

1. Create a JSON PRD with `/ralph-json-create-issues`
2. Run: `/ralph`, `/ralph 25`, or `/ralph auth-flow`
3. Ralph picks the next available project (respecting dependencies), implements stories, and commits
4. Monitor progress with `tail -f <worktree>/.ralph-progress.txt`

## Usage

```
/ralph              # Run next available project (respects dependencies)
/ralph 25           # Run with 25 iterations
/ralph auth-flow    # Run specific project
```

## What It Does

- Shows dependency graph and finds the next available project
- Creates a git worktree at `../{repo}-{feature}/`
- Picks the first story where `passes: false`
- Implements the story, runs quality checks
- Commits with `feat: [id] - [title]` and updates the JSON
- Syncs progress back to the main repo
- Outputs `<promise>COMPLETE</promise>` when all stories pass

## Prerequisites

- At least one `.json` PRD file in `.claude/plans/`, `plans/`, or `prds/`
- Create PRDs with plan mode, then convert with `/ralph-json-create-issues`

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions, dependency handling, and process |
| `references/prompt.md` | Prompt template for the autonomous agent |
| `scripts/ralph.sh` | The loop script that orchestrates execution |

## Tips

- Run multiple Ralph instances in parallel on independent projects (separate terminals)
- Each instance works in its own worktree, so there are no conflicts
- Projects with incomplete dependencies are automatically blocked
