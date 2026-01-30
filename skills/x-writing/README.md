# X Writing Skill

Transforms notes, work updates, and observations into X (Twitter) posts. Analyzes source material for shareable insights, drafts authentic posts using proven patterns, and avoids AI writing patterns.

Reads ideas from a markdown file (`X_SOURCE_FILE`) and/or macOS Notes (`X_NOTES_APP_SOURCE`). If both are configured, asks which to use.

## Setup

### Environment Variables (Optional)

Add to Claude Code settings (`~/.claude/settings.json`):

```json
{
  "env": {
    "WRITING_STYLE_GUIDE_PATH": "/path/to/style-guide.md",
    "WRITING_ANTI_PATTERNS_PATH": "/path/to/anti-patterns.md",
    "X_SOURCE_FILE": "/path/to/ideas.md",
    "X_NOTES_APP_SOURCE": "Tweets",
    "X_DRAFTS_FILE": "/path/to/posts.md",
    "X_CASE_STYLE": "lowercase"
  }
}
```

| Variable | Description |
|----------|-------------|
| `WRITING_STYLE_GUIDE_PATH` | Shared writing style guide for voice and tone |
| `WRITING_ANTI_PATTERNS_PATH` | Shared anti-patterns. Overrides `references/anti-patterns.md` |
| `X_SOURCE_FILE` | Path to a markdown file containing post ideas |
| `X_NOTES_APP_SOURCE` | macOS Notes note name to fetch ideas from (e.g. `"Tweets"`) |
| `X_DRAFTS_FILE` | File path for saving approved posts (default: `.x/posts.md`) |
| `X_CASE_STYLE` | `"standard"` (default) or `"lowercase"` |

## Usage

```bash
# From pasted content
claude "Transform these notes into X posts: [paste your notes]"

# From ideas file
claude "Check my ideas and draft some posts"
```

## Reference Files

- **`references/x-strategy.md`** — Content selection, formatting, engagement patterns
- **`references/anti-patterns.md`** — AI writing patterns to avoid
- **Shared writing style guide** (via `WRITING_STYLE_GUIDE_PATH`) — Voice, tone, banned phrases
