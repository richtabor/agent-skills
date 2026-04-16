---
name: ralph-json-start-loop
description: "Autonomous development loop powered by local JSON files. Picks up stories from prds/*.json, creates git worktrees, and executes them one by one. Use when the user asks to run Ralph, start the autonomous loop, execute stories from PRDs, or work through JSON tasks. Triggers on 'run ralph', 'start the loop', 'execute my PRDs', or 'autonomous mode'."
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

1. Run the loop script in background mode:

```bash
~/.claude/skills/ralph/ralph.sh [iterations] [project-name]
```

Use `run_in_background: true` to prevent timeout. After starting, tell the user to check progress with `tail -f <worktree>/.ralph-progress.txt`.

2. The script shows the dependency graph, finds the next available project, and creates a git worktree at `../{repo}-{feature}/`.

3. For each iteration, it picks the first story where `passes: false`, implements it, runs quality checks, commits (`feat: [id] - [title]`), and syncs back to the main repo.

4. When all stories pass, outputs `<promise>COMPLETE</promise>`.

### Error Handling

- If `gh auth status` fails, stop and ask the user to run `gh auth login`.
- If the worktree already exists, warn and ask whether to reuse or clean up.
- If a story fails quality checks after implementation, log the failure and move to the next story.

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

1. At least one `.json` PRD file in `.claude/plans/`, `plans/`, or `prds/`
2. Use plan mode to create a plan, then run `/ralph-json-create-issues` to convert it

## Notes

- Run multiple Ralphs in parallel on independent projects (separate terminals)
- Each works in its own worktree, no conflicts
