# WordPress Add Links

Adds internal and external links to a WordPress blog post, or a markdown file. Fetches your published posts for internal link candidates, searches the web for external references, and proposes links for approval before publishing.

Works with local markdown files or live WordPress posts. Requires WordPress credentials in both cases (internal links are sourced from your published posts).

## Setup

Set WordPress credentials in `~/.claude/settings.json`:

```json
{
  "env": {
    "WORDPRESS_URL": "https://yourblog.com",
    "WORDPRESS_USERNAME": "your-username",
    "WORDPRESS_APP_PASSWORD": "xxxx xxxx xxxx xxxx"
  }
}
```

## Usage

```
Add links to this post: https://yourblog.com/my-post/
```

```
Add links to this post: .drafts/2025-01-30-my-post.md
```

## How It Works

1. Fetches your published WordPress posts and searches the web for relevant external references
2. Presents a table of proposed links — you select which ones to apply
3. Saves approved links to the local file or updates the post via WordPress REST API

## Link Budget

- 3–5 internal links per post
- 2–4 external links per post
- No links in the opening paragraph
- Internal links take priority over external
