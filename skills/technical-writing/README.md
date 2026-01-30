# Technical Writing Skill

Create technical blog posts about features you're building. This skill analyzes your codebase to understand implementations, then structures clear, engaging content that balances technical detail with readability while avoiding AI-sounding language.

## Quick Start

1. Open a project you want to write about
2. Ask: "Help me write about the [feature name]"
3. The skill investigates your code, loads the writing style guides and anti-patterns, then drafts a post
4. Post is saved to `WRITING_DRAFTS_PATH` (or `.drafts/` by default)

## What It Does

- Reads git history to understand recent changes and what was built
- Applies strict anti-AI-pattern rules (no "dive into", "leverage", etc.)
- Uses your personal voice from the style guide
- Generates short, evocative titles (3-7 words) and memorable URL slugs
- Adds YAML frontmatter with title, url, category, and tags
- Fetches existing WordPress categories and tags to use in frontmatter
- Uses sentence case for titles and headings (configurable)
- Saves posts to configurable `WRITING_DRAFTS_PATH` (falls back to `.drafts/`)
- Optionally publishes drafts to WordPress (uses frontmatter slug for permalinks)

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions and workflow |
| `references/anti-patterns.md` | Words and phrases to avoid |
| `references/style-guide.md` | Personal voice and tone |
| `references/wordpress-publishing.md` | Publishing setup guide |
| `scripts/publish-to-wordpress.py` | WordPress REST API script |

## WordPress Publishing (Optional)

If you want to publish drafts directly to WordPress:

### 1. Install dependencies

```bash
pip install requests markdown2
```

### 2. Get WordPress credentials

1. Your WordPress site URL (e.g., `https://yourblog.com`)
2. Your WordPress username
3. An Application Password from: WordPress.com → Account Settings → Security → Application Passwords

### 3. Publish

After drafting a post, say:
- "Save this to WordPress"
- "Save to WordPress with tags: nextjs, voice-ai"

Posts are always saved as drafts—you publish manually from WordPress.

## Customizing

Add env vars to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "env": {
    "WRITING_STYLE_GUIDE_PATH": "/path/to/style-guide.md",
    "WRITING_ANTI_PATTERNS_PATH": "/path/to/anti-patterns.md",
    "WRITING_DRAFTS_PATH": "/path/to/drafts",
    "WRITING_TITLE_CASE_STYLE": "sentence",
    "WRITING_HEADING_CASE_STYLE": "sentence",
    "WORDPRESS_URL": "https://yourblog.com",
    "WORDPRESS_USERNAME": "your_username",
    "WORDPRESS_APP_PASSWORD": "xxxx xxxx xxxx xxxx"
  }
}
```

| Variable | Description |
|----------|-------------|
| `WRITING_STYLE_GUIDE_PATH` | Path to your own style guide. Falls back to `references/style-guide.md` |
| `WRITING_ANTI_PATTERNS_PATH` | Path to your own anti-patterns. Falls back to `references/anti-patterns.md` |
| `WRITING_DRAFTS_PATH` | Where to save drafts. Falls back to `.drafts/` in the current project |
| `WRITING_TITLE_CASE_STYLE` | `"sentence"` (default) or `"title"` |
| `WRITING_HEADING_CASE_STYLE` | `"sentence"` (default) or `"title"` |
| `WORDPRESS_URL` | WordPress site URL (required for publishing) |
| `WORDPRESS_USERNAME` | WordPress account username (required for publishing) |
| `WORDPRESS_APP_PASSWORD` | Application password (required for publishing) |

## Tips

- Be specific: "Write about the webhook security" beats "write about webhooks"
- Mention your audience: "For developers familiar with Next.js"
- Request revisions after the draft
