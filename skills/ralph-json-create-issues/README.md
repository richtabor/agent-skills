# Ralph JSON Create Issues

Converts a PRD or plan markdown file into `prds/*.json` format for `ralph-json-start-loop` to execute autonomously. Handles story sizing, dependency ordering, and acceptance criteria validation.

## Quick Start

1. Create a PRD using `/create-prd` or plan mode
2. Run: `/ralph-json-create-issues`
3. The skill converts your PRD into right-sized stories with explicit acceptance criteria
4. JSON is saved to `prds/[feature-name].json`
5. Run `/ralph-json-start-loop` to start executing

## What It Does

- Finds PRD/plan files in `.claude/plans/`, `plans/`, or `prds/`
- Breaks features into stories small enough for one agent iteration
- Orders stories by dependency (schema first, then backend, API, UI)
- Writes explicit, verifiable acceptance criteria for each story
- Scans existing `prds/*.json` to detect cross-PRD dependencies
- Populates `dependsOn` array for Ralph to enforce execution order

## Story Sizing

Each story must complete in one Ralph iteration:

```
Too large: "Build entire auth system"
Right-sized: "Add login form"
             "Add email validation"
             "Add auth server action"
```

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Conversion rules, output format, and pre-save checklist |

## Tips

- Every story must include "Typecheck passes" and "Lint passes" in acceptance criteria
- UI stories should include "Verify at localhost:3000/[path]"
- Avoid vague criteria like "works correctly" or "good UX"
- After conversion, run `/ralph-json-start-loop` to execute
