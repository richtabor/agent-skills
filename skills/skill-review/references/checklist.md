# Skill Review Checklist

Quick validation checklist for reviewing skills. Use for fast pass/fail audits.

---

## Structure

```
□ SKILL.md exists
□ Directory name matches frontmatter `name`
□ No extraneous files (README.md, CHANGELOG.md, etc.)
□ References one level deep (no chains)
□ Forward slashes only (no Windows paths)
□ Script paths referenced in body exist in directory
□ External binary dependencies documented
```

## Frontmatter

```
□ name: lowercase with hyphens only [a-z0-9-]
□ name: ≤64 characters
□ name: no "anthropic" or "claude"
□ description: non-empty
□ description: ≤1024 characters
□ description: third-person voice
□ description: includes what it does
□ description: includes when to trigger
```

## Description Quality

```
□ Specific actions (not vague like "helps with")
□ Trigger phrases included ("Use when...")
□ Synonyms for discoverability
□ No first/second person ("I can", "You can")
```

## Body Content

```
□ Under 500 lines total
□ Quick start near top
□ Details in references/ (not front-loaded)
□ Long refs (>100 lines) have TOC
□ No obvious explanations Claude knows
□ Examples over prose
□ Defaults provided when multiple options
```

## Anti-Patterns (should NOT find)

```
□ No Windows paths (scripts\file.py)
□ No nested reference chains
□ No time-sensitive statements ("before August 2025")
□ No magic numbers without explanation
□ No "you can use X or Y or Z" without default
□ No inconsistent terminology
□ No user-facing docs in skill directory
```

## Optional Elements

```
□ scripts/ - executable code (if needed)
□ references/ - loaded documentation (if needed)
□ assets/ - output templates (if needed)
□ allowed-tools scoped appropriately (if used)
```

---

## Quick Scoring

| Category | Weight | Pass/Fail |
|----------|--------|-----------|
| Frontmatter valid | Required | |
| Description quality | Required | |
| Body <500 lines | Required | |
| No anti-patterns | Required | |
| Progressive disclosure | Recommended | |
| Token efficiency | Recommended | |

**Pass**: All required + majority of recommended
**Needs work**: Any required failing
**Fail**: Multiple required failing

---

## Description Template

```yaml
description: >-
  [What it does - specific actions and capabilities].
  Use when [trigger phrases, contexts, file types, user intents].
```

## Example Passing Description

```yaml
description: >-
  Reviews UI for accessibility issues against WCAG 2.1/2.2 AA.
  Triggers on "is this accessible?", "check accessibility",
  or contrast/a11y review requests.
```

## Example Failing Description

```yaml
# Too vague
description: Helps with documents

# Missing triggers
description: Processes PDF files

# Wrong voice
description: I can help you analyze data
```
