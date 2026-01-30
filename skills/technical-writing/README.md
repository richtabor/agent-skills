# Technical Writing Skill

Write technical blog posts about features you're building. This skill analyzes your codebase to understand implementations, then creates clear, engaging content that avoids AI-sounding language.

## Quick Start

1. Open a project you want to write about
2. Ask: "Help me write about the [feature name]"
3. The skill investigates your code, loads the style guides, and drafts a post
4. Post is saved to `DRAFTS_PATH` (or `.blog/` by default)

## What It Does

- Analyzes git history and code to understand what was built
- Applies strict anti-AI-pattern rules (no "dive into", "leverage", etc.)
- Uses your personal voice from the style guide
- Uses sentence case for titles and headings (configurable)
- Saves posts to configurable `DRAFTS_PATH` (falls back to `.blog/`)
- Optionally publishes drafts to WordPress

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

### 3. Configure credentials

Add to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "env": {
    "WORDPRESS_URL": "https://yourblog.com",
    "WORDPRESS_USERNAME": "your_username",
    "WORDPRESS_APP_PASSWORD": "xxxx xxxx xxxx xxxx",
    "TITLE_CASE_STYLE": "sentence",
    "HEADING_CASE_STYLE": "sentence"
  }
}
```

### 4. Publish

After drafting a post, say:
- "Save this to WordPress"
- "Save to WordPress with tags: nextjs, voice-ai"

Posts are always saved as drafts—you publish manually from WordPress.

## Customizing

### Anti-patterns

Edit `references/anti-patterns.md` to add words or phrases you want to avoid. The skill checks content against this list.

### Style guide

Edit `references/style-guide.md` to define your writing voice, preferred structures, and signature moves. The guide includes sentence case preferences for titles and headings to match a conversational tone.

## Tips

- Be specific: "Write about the webhook security" beats "write about webhooks"
- Mention your audience: "For developers familiar with Next.js"
- Specify length: "Quick 500-word update" vs "detailed deep-dive"
- Request revisions after the draft
