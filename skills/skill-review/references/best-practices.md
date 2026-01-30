# Best Practices for Writing Skills

> Comprehensive guide compiled from Anthropic docs, Claude Code documentation, and production skill analysis.

## Table of Contents

1. [Mental Model](#1-mental-model)
2. [Architecture](#2-architecture)
3. [Required Structure](#3-required-structure)
4. [Design Principles](#4-design-principles)
5. [Writing Descriptions](#5-writing-descriptions)
6. [Naming Conventions](#6-naming-conventions)
7. [Bundled Resources](#7-bundled-resources)
8. [Workflow Patterns](#8-workflow-patterns)
9. [Anti-Patterns](#9-anti-patterns)
10. [Advanced Patterns](#10-advanced-patterns)

---

## 1. Mental Model

Skills are **onboarding guides for specialized tasks**—modular instruction packages Claude loads dynamically when relevant.

| Aspect | CLAUDE.md | Skills |
|--------|-----------|--------|
| Loading | Always (startup) | On-demand (triggered) |
| Scope | Project-wide rules | Task-specific workflows |
| Context cost | Every conversation | Only when needed |
| Structure | Single file | Directory with resources |

**Use CLAUDE.md for**: Unchanging conventions, coding standards, always-on project rules.
**Use Skills for**: Complex workflows, scripts, templates, domain expertise activated contextually.

---

## 2. Architecture

### Token Loading Hierarchy

```
Level 1: Metadata only (always loaded)     ~100 tokens
         name + description in system prompt
                    ↓
Level 2: SKILL.md body (on trigger)        ~1,500-5,000 tokens
         Full instructions load after skill selected
                    ↓
Level 3: Bundled resources (as-needed)     Unlimited
         scripts/ references/ assets/
         Only read when Claude determines necessary
```

### Selection Mechanism

**Pure LLM reasoning—no algorithmic matching.** Claude evaluates all skill descriptions via natural language understanding. This means:

- Description quality is **critical** for triggering
- Vague descriptions → skill never triggers
- Specific trigger phrases → reliable activation

---

## 3. Required Structure

```
skill-name/
├── SKILL.md                    # Required - instructions + frontmatter
├── scripts/                    # Optional - executable code
│   └── validate.py
├── references/                 # Optional - docs loaded into context
│   ├── api.md
│   └── schema.md
└── assets/                     # Optional - files used in output (not loaded)
    └── template.docx
```

### Frontmatter (YAML)

```yaml
---
name: processing-pdfs                    # Required: lowercase, hyphens only
description: >-                          # Required: what + when to use
  Extract text and tables from PDF files, fill forms, merge documents.
  Use when working with PDF files or when user mentions PDFs, forms,
  or document extraction.
---
```

**Validation rules:**
- `name`: ≤64 chars, `[a-z0-9-]` only, no "anthropic"/"claude"
- `description`: ≤1024 chars, non-empty, no XML tags

---

## 4. Design Principles

### 4.1 Conciseness Is Survival

Context window = public good. Every token competes with conversation history.

**Default assumption: Claude is already intelligent.** Only add what Claude doesn't know.

```markdown
# BAD (~150 tokens) - explains obvious things
PDF (Portable Document Format) files are a common file format...

# GOOD (~50 tokens) - assumes competence
## Extract PDF text
Use pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

### 4.2 Progressive Disclosure

Never front-load everything. Structure for on-demand loading.

```markdown
# In SKILL.md - overview + pointers
## Quick start
[Essential code example]

## Features
- **Feature A**: See [A.md](references/A.md)
- **Feature B**: See [B.md](references/B.md)
```

**Critical rules:**
- Keep references **one level deep** from SKILL.md
- No chains: SKILL.md → advanced.md → details.md
- Long files (>100 lines): include TOC at top

### 4.3 Degrees of Freedom

Match specificity to task fragility:

| Freedom | When | Example |
|---------|------|---------|
| **High** | Multiple valid approaches | Code review guidelines |
| **Medium** | Preferred pattern, some variation OK | Report templates |
| **Low** | Fragile/error-prone, consistency critical | DB migration scripts |

---

## 5. Writing Descriptions

The description is **the** triggering mechanism.

### Rules

1. **Third person always** — "Processes Excel files" not "I can help you"
2. **Specific + trigger phrases** — Include what it does AND when to invoke
3. **Key terms for discovery** — Use synonyms user might say

### Examples

```yaml
# GOOD - specific, includes triggers
description: >-
  Analyze Excel spreadsheets, create pivot tables, generate charts.
  Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.

# GOOD - action + context
description: >-
  Generate descriptive commit messages by analyzing git diffs.
  Use when user asks for help writing commit messages or reviewing staged changes.

# BAD - vague
description: Helps with documents
description: Processes data
```

---

## 6. Naming Conventions

**Prefer gerund form** (verb + -ing):

```
✓ processing-pdfs
✓ analyzing-spreadsheets
✓ testing-code

✗ helper, utils, tools (vague)
✗ documents, data, files (generic)
✗ anthropic-helper, claude-tools (reserved)
```

---

## 7. Bundled Resources

### scripts/ — Executable Code

**When:** Same code rewritten repeatedly, deterministic reliability needed.

**Benefits:**
- Token efficient (executed without loading)
- Deterministic (no generation variance)
- Consistent across uses

**In SKILL.md:**
```markdown
# Execute (most common)
Run `python scripts/validate.py input.pdf`

# Read as reference (rare)
See `scripts/validate.py` for the validation algorithm
```

### references/ — Context-Loaded Documentation

**When:** Documentation Claude should reference while working.

```
references/
├── schema.md       # Database schemas
├── api.md          # API specifications
├── policies.md     # Company rules
```

**Large files (>10k words):** Include grep patterns in SKILL.md for targeted access.

### assets/ — Output Files (Not Loaded)

**When:** Files used in output, not instruction context.

Claude references by path, copies/modifies—never loads into context.

---

## 8. Workflow Patterns

### Checklist Pattern

```markdown
## Form filling workflow

Copy and track progress:
- [ ] Step 1: Analyze form
- [ ] Step 2: Create field mapping
- [ ] Step 3: Validate mapping
- [ ] Step 4: Fill form
```

### Feedback Loop Pattern

```markdown
## Validation loop

1. Make edits
2. **Validate immediately**: `python scripts/validate.py`
3. If validation fails: fix and re-run
4. **Only proceed when validation passes**
```

### Conditional Workflow Pattern

```markdown
## Document modification

1. Determine type:
   - **Creating new?** → Follow "Creation workflow"
   - **Editing existing?** → Follow "Editing workflow"
```

### Template Pattern

```markdown
## Report structure

ALWAYS use this template:

```markdown
# [Title]

## Executive summary
[One-paragraph overview]

## Key findings
- Finding 1
- Finding 2
```
```

---

## 9. Anti-Patterns

### Don't Include
- README.md, CHANGELOG.md, INSTALLATION_GUIDE.md
- User-facing documentation
- Setup/testing procedures

Skills are **for AI agents**, not humans.

### Don't Do

| Anti-Pattern | Why Bad | Fix |
|-------------|---------|-----|
| Windows paths | Breaks on Unix | Use forward slashes |
| Nested references | Partial reads | One level deep only |
| Time-sensitive info | Becomes wrong | Use "legacy" sections |
| Too many options | Confusing | Provide default |
| Vague descriptions | Never triggers | Specific + triggers |
| Inconsistent terms | Confuses Claude | Pick one term |
| Magic numbers | Unverifiable | Document why |

### Bad: Multiple Options Without Default

```markdown
# BAD
"You can use pypdf, or pdfplumber, or PyMuPDF..."

# GOOD
"Use pdfplumber for text extraction:
[code]
For scanned PDFs, use pdf2image with pytesseract instead."
```

---

## 10. Advanced Patterns

### "THE EXACT PROMPT" Pattern

Encode reproducible prompts:

```markdown
## THE EXACT PROMPT — Plan Review

```
Carefully review this entire plan for me...
```
```

### "Why This Exists" Section

Front-load motivation:

```markdown
## Why This Exists

Managing multiple AI agents is painful:
- **Window chaos**: Each agent needs its own terminal
- **Context switching**: Breaks flow
```

### Risk Tiering Tables

For safety/security skills:

```markdown
| Tier | Approvals | Auto-approve | Examples |
|------|-----------|--------------|----------|
| **CRITICAL** | 2+ | Never | `rm -rf /` |
| **DANGEROUS** | 1 | Never | `git reset --hard` |
| **CAUTION** | 0 | After 30s | `rm file.txt` |
```

### Exit Code Standardization

```markdown
## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Error |
| `2` | Invalid arguments |
```

---

## Sources

- [Skill Authoring Best Practices - Anthropic Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [anthropics/skills Repository](https://github.com/anthropics/skills)
