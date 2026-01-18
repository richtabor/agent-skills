---
name: ralph
description: Runs the Ralph autonomous loop. Executes stories from prds/*.json using git worktrees.
user_invocable: true
---

# Ralph

Run the autonomous loop to execute features from `prds/` directory.

## Usage

```
/ralph              # Run next available project (respects dependencies)
/ralph 25           # Run with 25 iterations
/ralph auth-flow    # Run specific project
```

## Process

Run the loop script in background mode:

```bash
~/.claude/skills/ralph/ralph.sh [iterations] [project-name]
```

Use `run_in_background: true` to prevent timeout. After starting, tell the user to check progress with `tail -f <worktree>/.ralph-progress.txt`.

### What It Does

1. Shows dependency graph, finds next available project
2. Creates git worktree at `../{repo}-{feature}/`
3. For each iteration:
   - Picks first story where `passes: false`
   - Implements it, runs quality checks
   - Commits: `feat: [id] - [title]`
   - Updates JSON, syncs back to main repo
4. When all stories pass, outputs `<promise>COMPLETE</promise>`

### Dependencies

Ralph reads `dependsOn` from each PRD and enforces ordering:

```json
{
  "projectName": "Dashboard",
  "dependsOn": ["auth-flow", "user-profile"]
}
```

Projects with incomplete dependencies are blocked. Ralph picks the first ready project alphabetically.

## Prerequisites

1. `prds/` directory with at least one `.json` file
2. Run `/create-prd` then `/create-prd-json` first

## Notes

- Run multiple Ralphs in parallel on independent projects (separate terminals)
- Each works in its own worktree, no conflicts
