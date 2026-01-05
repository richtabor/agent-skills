# Accessibility Review Skill

Conducts manual accessibility reviews of UI components, pages, and applications against WCAG 2.1/2.2 Level AA standards. Provides prioritized findings focused on practical, modern web accessibility requirements.

## Quick Start

1. Open a component, page, or code file you want reviewed
2. Ask: "Is this accessible?" or "Check this for accessibility issues"
3. The skill reviews against WCAG standards and presents findings one at a time
4. Decide to fix or ignore each issue as they're presented

## What It Does

- Reviews code, components, and pages against WCAG 2.1/2.2 Level AA
- Prioritizes findings as **Critical** (blocks access) or **Warning** (creates friction)
- Presents issues one at a time for focused decision-making
- Provides specific code fixes with file locations
- Tracks what was fixed vs. ignored with a final summary

## Review Process

The skill follows a stepped review process:

1. **Identifies the target** - Component, page, code file, or design
2. **Conducts manual review** - Uses WCAG checklist systematically
3. **Prioritizes findings** - Critical vs. Warning classifications
4. **Presents issues one at a time** - You decide fix or ignore for each
5. **Provides final summary** - Overview of all decisions made

## Issue Classification

### Critical Issues
Blocks users from accessing core functionality:
- Missing alt text on meaningful images
- Non-keyboard accessible interactive elements
- Insufficient color contrast (below 4.5:1 for normal text, 3:1 for large text)
- Forms without proper labels
- Missing focus indicators
- Inaccessible modal/dialog patterns
- Auto-playing media without controls

### Warning Issues
Creates friction but doesn't fully block access:
- Suboptimal heading hierarchy (skipped levels)
- Missing ARIA landmarks
- Link text that's unclear out of context
- Redundant or unnecessary ARIA
- Touch targets smaller than 44x44px
- Missing skip links
- Non-descriptive error messages

## Common Patterns Checked

### Interactive Elements
- All interactive elements must be keyboard accessible
- Focus must be visible with clear indicators
- Custom controls need proper ARIA roles and states

### Forms
- All inputs must have associated labels
- Error messages must be programmatically associated
- Required fields must be indicated clearly

### Color and Contrast
- Text contrast: 4.5:1 minimum for normal text, 3:1 for large text
- UI components: 3:1 contrast for interactive elements
- Don't rely on color alone to convey information

### Images and Media
- Meaningful images need descriptive alt text
- Decorative images should have empty alt (alt="")
- Videos need captions, audio content needs transcripts

### Structure
- Use semantic HTML (nav, main, article, etc.)
- Heading hierarchy should be logical (h1 → h2 → h3)
- ARIA landmarks help screen reader navigation

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions and review workflow |
| `references/wcag-checklist.md` | Comprehensive WCAG 2.1/2.2 Level AA checklist organized by principle |

## Review Guidelines

The skill follows these principles:

- **Be Practical**: Focus on issues that genuinely impact users. Modern WCAG 2.1/2.2 Level AA is the standard—avoid over-engineering or citing obscure edge cases.

- **Be Specific**: Reference actual code locations using `file_path:line_number` format when possible.

- **Be Constructive**: Provide actionable fixes, not just problems. Include code examples when helpful.

- **Consider Context**: Some patterns may have accessibility trade-offs. Acknowledge these and suggest the most accessible approach for the use case.

## Example Interaction

**User:** "Is this button accessible?"

**Skill:**
1. Reviews the button component against WCAG standards
2. Finds issues (e.g., missing focus indicator, insufficient contrast)
3. Presents first issue:
   ```
   ───────────────────────────────────
   Issue [1/2]: Critical
   ───────────────────────────────────
   
   **Problem**: Button lacks visible focus indicator
   
   **Location**: `components/Button.tsx:45`
   [Shows code snippet]
   
   **Impact**: Keyboard users can't see which element has focus
   
   **Recommended Fix**: Add focus-visible styles
   ───────────────────────────────────
   Fix this issue, or ignore?
   ```
4. Waits for your decision before presenting the next issue
5. Provides final summary of all decisions

## Tips for Best Results

- **Be specific**: "Check this modal component" vs. "check accessibility"
- **Review incrementally**: The one-at-a-time approach helps focus on each issue
- **Provide context**: Mention if something is a work-in-progress or has constraints
- **Ask questions**: "Why is this critical?" if you need clarification
