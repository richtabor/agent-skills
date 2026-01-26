# Agent Skills

Modular skills that extend AI coding agents. Works across Claude Code, Cursor, Codex, and Copilot.

## Editing Skills

- Keep `SKILL.md` under 500 lines; move details into `references/`
- Prefer surgical changes—don't reformat unrelated markdown
- Information lives in `SKILL.md` or references, not both

## Key Files

- `.claude-plugin/marketplace.json` — Plugin manifest
- `README.md` — Lists available skills

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.