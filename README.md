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

Reviews UI for accessibility issues against WCAG 2.1/2.2 Level AA. Provides prioritized findings (Critical/Warning) focused on practical, modern web accessibility.

### [WordPress Add Links](./skills/wordpress-add-links)

Finds internal and external links for a blog post draft, naturally woven into existing text.

### [AGENTS.md](./skills/agents-md)

Creates and refactors AGENTS.md files using progressive disclosure principles.

### [Create PRD](./skills/create-prd)

Plans features interactively. Asks clarifying questions, then generates a detailed PRD document.

### [Create PRD JSON](./skills/create-prd-json)

Converts a PRD markdown file into prd.json format for autonomous execution.

### [Fresh Eyes](./skills/fresh-eyes)

Re-reads code you just wrote with fresh perspective to catch bugs, errors, and issues. Fixes problems immediately without asking.

### [Markdown Image Alt Text](./skills/markdown-img-alt-text)

Adds detailed alt text to markdown image embeds. Supports Obsidian wiki-style and standard markdown formats.

### [Motion Design](./skills/motion-design)

Designs intentional motion for product UI. Recommends easing curves, durations, and implementation approaches.

### [Ralph](./skills/ralph)

Runs an autonomous development loop. Executes stories from PRD JSON files using git worktrees.

### [Technical Writing](./skills/technical-writing)

Writes technical blog posts about features being built. Supports WordPress publishing.

### [X Writing](./skills/x-writing)

Transforms notes into X (Twitter) posts. Identifies shareable insights and crafts authentic posts. Supports macOS Notes integration.

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

The PRD and Ralph skills (`create-prd`, `create-prd-json`, `ralph`) are inspired by [snarktank/ralph](https://github.com/snarktank/ralph).

The `fresh-eyes` skill is inspired by [Jeffrey Emanuel](https://x.com/doodlestein/status/1956228999945806049).
