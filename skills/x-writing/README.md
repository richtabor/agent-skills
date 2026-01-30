# X Writing Skill

Transforms notes, work updates, and observations into X (Twitter) posts. Analyzes source material for shareable insights, drafts authentic posts using proven patterns, and avoids AI writing patterns.

Supports fetching ideas directly from macOS Notes.

## Setup

### Environment Variables (Optional)

Add to Claude Code settings (`~/.claude/settings.json`):

```json
{
  "env": {
    "WRITING_STYLE_GUIDE_PATH": "/path/to/style-guide.md",
    "WRITING_ANTI_PATTERNS_PATH": "/path/to/anti-patterns.md",
    "NOTES_SOURCE": "Tweets",
    "X_CASE_STYLE": "lowercase",
    "X_DRAFTS_FILE": "/path/to/drafts"
  }
}
```

| Variable | Description |
|----------|-------------|
| `WRITING_STYLE_GUIDE_PATH` | Shared writing style guide for voice and tone |
| `WRITING_ANTI_PATTERNS_PATH` | Shared anti-patterns. Overrides `references/anti-patterns.md` |
| `X_DRAFTS_FILE` | File path for saving approved posts (default: `.x/posts.md`) |
| `NOTES_SOURCE` | macOS Notes note name to fetch from (default: `"Tweets"`) |
| `X_CASE_STYLE` | `"standard"` (default) or `"lowercase"` |

### macOS Notes Integration

```bash
# Fetch from default note
./scripts/fetch-notes.sh get

# Fetch from a specific note
./scripts/fetch-notes.sh get "Note Name"

# List available notes
./scripts/fetch-notes.sh list
```

## Usage

```bash
# From pasted content
claude "Transform these notes into X posts: [paste your notes]"

# From macOS Notes
claude "Look in my Notes for good tweet ideas"
```

## Reference Files

- **`references/x-strategy.md`** — Content selection, formatting, engagement patterns
- **`references/anti-patterns.md`** — AI writing patterns to avoid
- **Shared writing style guide** (via `WRITING_STYLE_GUIDE_PATH`) — Voice, tone, banned phrases

## Troubleshooting

**Script permission denied:** `chmod +x scripts/fetch-notes.sh`

**Can't find note:** Check exact name (case-sensitive), verify note is in default Notes account, try `./scripts/fetch-notes.sh list`
