# Ralph GitHub Create Issues

Converts a PRD or plan markdown file into GitHub Issues (parent + sub-issues) for `ralph-github-start-loop` to execute. Creates a parent issue with overview and implementation order, then individual sub-issues for each story.

## Quick Start

1. Create a PRD using `/create-prd` or plan mode
2. Run: `/ralph-github-create-issues` or `/ralph-github-create-issues auth-flow`
3. The skill finds your PRD, creates parent and sub-issues, and links dependencies
4. Run `/ralph-github-start-loop` to start executing

## What It Does

- Finds PRD/plan files in `.claude/plans/`, `plans/`, or `prds/`
- Creates a parent GitHub Issue with the `prd` label, overview, and implementation order
- Creates sub-issues for each user story with acceptance criteria
- Links sub-issues to the parent using `gh sub-issue`
- Detects cross-PRD dependencies and creates GitHub blocking relationships
- Offers to delete the local PRD file after issues are created

## Prerequisites

- `gh` CLI authenticated (`gh auth status`)
- A PRD or plan file (create one with `/create-prd` or plan mode)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions, issue templates, and dependency detection |
| `references/best-practices.md` | Story sizing and acceptance criteria guidance |

## Tips

- Stories should be small enough to complete in one agent iteration
- Acceptance criteria must be explicit and verifiable
- After creating issues, run `/ralph-github-start-loop` to execute them autonomously
