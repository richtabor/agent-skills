# Review AGENTS.md

Creates minimal, effective AGENTS.md files using progressive disclosure. Reviews existing files for bloat and anti-patterns, and ensures CLAUDE.md is symlinked correctly.

## Quick Start

1. Open a project that needs an AGENTS.md or has a bloated one
2. Ask: "Create agents.md", "Review my agents.md", or "Refactor agents.md"
3. The skill audits the current state, applies the essential test, and outputs a minimal file
4. Content that doesn't belong in the root file gets moved to separate docs

## What It Does

- Creates new AGENTS.md files with only what's relevant to every task
- Refactors bloated files by relocating domain-specific content to separate docs
- Ensures CLAUDE.md is a symlink to AGENTS.md (never standalone)
- Flags anti-patterns: file trees, obvious instructions, contradictory rules
- Sets up progressive disclosure with `docs/` files for domain-specific rules
- Handles monorepo setups with nested AGENTS.md files

## What Belongs in Root AGENTS.md

| Include | Why |
|---------|-----|
| One-sentence project description | Anchors every agent decision |
| Package manager (if not npm) | Prevents wrong commands |
| Non-standard build/test commands | Saves trial and error |
| Links to domain-specific docs | Progressive disclosure |

Everything else goes in separate files or gets deleted.

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Core principles, review process, anti-patterns, output format, and monorepo handling |

## Tips

- The ideal AGENTS.md is as small as possible — every token loads on every request
- Describe capabilities ("Auth uses JWT"), not locations ("Auth is in src/auth/")
- File tree structures always go stale and waste tokens — never include them
- AGENTS.md is an open standard supported by 20+ tools including Copilot, Cursor, and Codex
