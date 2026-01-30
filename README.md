# Agent Skills

A collection of agent skills for design, engineering, writing, and product, built on the open [Agent Skills](https://agentskills.io/) standard.

## Install

```bash
# Add via skills.sh
npx skills add richtabor/agent-skills

# or as a Claude Code plugin
/plugin marketplace add https://github.com/richtabor/agent-skills
/plugin install rt
```

## Available Skills

### [Accessibility Review](./skills/accessibility-review)

Audits components, pages, and screenshots against WCAG 2.1/2.2 Level AA. Returns prioritized findings (Critical/Warning) with specific fixes rather than generic guidance.

### [WordPress Add Links](./skills/wordpress-add-links)

Scans a blog post draft, finds relevant internal and external link opportunities, and weaves them into existing sentences without disrupting the flow.

### [Create PRD](./skills/create-prd)

Walks through a feature idea with clarifying questions, then produces a structured Product Requirements Document ready for development.

### [Ralph: Create JSON Issues](./skills/ralph-create-json-issues)

Converts a PRD or plan file into right-sized JSON stories for the JSON loop. Reads from `.claude/plans/` or `prds/`, sizes each story to one context window, and wires up cross-PRD dependencies.

### [Fresh Eyes](./skills/fresh-eyes)

Re-reads code you just wrote as if seeing it for the first time. Catches off-by-one errors, missed edge cases, naming issues, and logic bugs, then fixes them on the spot.

### [Humanize](./skills/humanize)

Rewrites AI-generated text so it reads like a person wrote it. Applies 30 rules across 6 categories based on Wikipedia's AI writing patterns guide, preserving meaning while removing robotic phrasing.

### [Markdown Image Alt Text](./skills/markdown-img-alt-text)

Reads each image in a markdown file, describes its content, and writes detailed alt text inline. Works with both Obsidian wiki-style (`![[image]]`) and standard markdown formats.

### [Motion Design](./skills/motion-design)

Evaluates UI animation needs and recommends specific easing curves, durations, and implementation approaches. Every animation gets a job, or it gets cut.

### [Ralph: GitHub Create Issues](./skills/ralph-github-create-issues)

Converts a PRD markdown file into GitHub Issues (parent + sub-issues). Reads from `.claude/plans/` or `prds/`, sizes stories for single-context execution, and links dependencies via GitHub's native blocking.

### [Ralph: GitHub Start Loop](./skills/ralph-github-start-loop)

Autonomous development loop powered by GitHub Issues. Fetches open PRD issues, spins up git worktrees, implements stories, closes sub-issues on commit, and opens a PR when done.

### [Ralph: JSON Create Issues](./skills/ralph-json-create-issues)

Converts a PRD or plan file into right-sized JSON stories for the JSON loop. Reads from `.claude/plans/` or `prds/`, sizes each story to one context window, and wires up cross-PRD dependencies.

### [Ralph: JSON Start Loop](./skills/ralph-json-start-loop)

Autonomous development loop powered by local JSON files. Picks up stories from `prds/*.json`, spins up git worktrees, and executes them one by one without manual intervention.

### [Review AGENTS.md](./skills/review-agents-md)

Detects missing `AGENTS.md` files, creates them using progressive disclosure principles, and symlinks `CLAUDE.md`. Proactively checks new projects and handles all combinations of existing files.

### [Skill Review](./skills/skill-review)

Validates agent skills against the Agent Skills standard. Audits structure, frontmatter, description quality, progressive disclosure, and anti-patterns, then returns a scored report with actionable fixes.

### [Technical Writing](./skills/technical-writing)

Turns the feature you just built into a technical blog post. Analyzes your codebase for implementation details, structures the narrative, and avoids AI-sounding language. Supports WordPress publishing.

### [X Writing](./skills/x-writing)

Turns notes and ideas into X posts that sound like you wrote them. Pulls ideas from a markdown file (`X_SOURCE_FILE`) or macOS Notes (`X_NOTES_APP_SOURCE`), identifies the most shareable angle, and drafts posts matched to your voice. Saves approved posts to `X_DRAFTS_FILE`.

## Structure

Each skill lives in its own folder:

```
skill-name/
├── SKILL.md              # Required: Instructions and metadata
├── references/           # Optional: Documentation loaded as needed
├── scripts/              # Optional: Executable code
└── assets/               # Optional: Templates, images, etc.
```

## Credits

The PRD and Ralph skills (`create-prd`, `ralph-json-create-issues`, `ralph-json-start-loop`, `ralph-github-start-loop`, `ralph-github-create-issues`) are inspired by [snarktank/ralph](https://github.com/snarktank/ralph).

The `fresh-eyes` skill is inspired by [Jeffrey Emanuel](https://x.com/doodlestein/status/1956228999945806049).
