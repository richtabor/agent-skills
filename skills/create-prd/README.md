# Create PRD

Plan features interactively. Asks clarifying questions about scope and requirements, then generates a detailed Product Requirements Document with user stories, acceptance criteria, and technical considerations.

## Quick Start

1. Describe a feature you want to build
2. Ask: "Create a PRD for [feature]" or "Plan this feature"
3. Answer 3-5 clarifying questions (respond with combos like "1A, 2B")
4. PRD is generated and saved to `prds/[feature-name].md`

## What It Does

- Asks targeted clarifying questions with lettered options to understand scope
- Generates structured PRDs with introduction, goals, user stories, and requirements
- Writes explicit, verifiable acceptance criteria (not vague "works correctly")
- Includes non-goals, design considerations, and technical notes
- Saves to `prds/` directory for use with Ralph or other execution tools

## PRD Sections

Each generated PRD includes:

- **Introduction** — What the feature is and why it's needed
- **Goals** — Primary and secondary objectives
- **User Stories** — With descriptions and acceptance criteria
- **Functional Requirements** — Numbered for easy reference
- **Non-Goals** — What the feature explicitly won't do
- **Design Considerations** — UI/UX notes
- **Technical Considerations** — Architecture, dependencies, challenges
- **Success Metrics** — How to measure if the feature succeeded
- **Open Questions** — Unresolved decisions

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions and PRD template |

## Tips

- Be specific about the feature upfront to get better clarifying questions
- Acceptance criteria should be verifiable: "Button displays 'Save' text" not "Button looks good"
- After creating a PRD, run `/ralph-json-create-issues` to convert it to executable format
