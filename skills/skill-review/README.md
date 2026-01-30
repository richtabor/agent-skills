# Skill Review

Validates agent skills against the Agent Skills standard and compiled best practices. Reviews structure, frontmatter, description quality, progressive disclosure, and common anti-patterns.

## Quick Start

1. Point it at a skill directory or SKILL.md file
2. Ask: "Review this skill", "Check my skill", "Is this skill well-written?"
3. The skill audits structure, frontmatter, description, body, and anti-patterns
4. Returns a scored report with actionable fixes

## What It Does

- Validates directory structure (SKILL.md, references/, scripts/)
- Checks frontmatter against the spec (name format, description length, trigger phrases)
- Scores description quality for triggering effectiveness
- Analyzes body for token efficiency and progressive disclosure
- Flags anti-patterns (Windows paths, nested references, stale info, inconsistent terms)
- Provides a structured report with pass/fail checks and suggested rewrites

## Review Process

1. **Load references** — Reads best-practices.md and checklist.md
2. **Identify target** — Single skill, all skills, or a draft
3. **Structural audit** — Directory layout, file presence, script paths
4. **Frontmatter validation** — Name format, description spec compliance
5. **Description quality** — Trigger phrases, specificity, synonyms
6. **Body analysis** — Line count, token efficiency, progressive disclosure
7. **Anti-pattern check** — Common issues from production skills
8. **Report findings** — Scored summary with actionable recommendations

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions and review workflow |
| `references/best-practices.md` | Comprehensive guidelines for skill architecture and design |
| `references/checklist.md` | Quick validation checklist for fast reviews |

## Tips for Best Results

- **Review before publishing**: Catch issues before they affect agent performance
- **Review after major edits**: Description changes affect triggering
- **Use quick mode**: Ask for "quick review" to run just the checklist
- **Review all skills**: Ask to "audit all my skills" for a full sweep
