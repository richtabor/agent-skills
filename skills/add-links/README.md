# Content Links

Add internal and external links to a blog post draft naturally.

## Setup

Set WordPress credentials in `~/.claude/settings.json` (same as `technical-writing`):

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
Add links to this post: .drafts/2025-01-30-my-post.md
```

```
Link this draft: https://yourblog.com/my-post/
```

The skill fetches your existing posts for internal links, searches the web for external references, and proposes links for approval before changing anything.

## How It Works

1. Fetches your published posts and searches the web for relevant external references
2. Presents a table of proposed links — you select which ones to apply
3. Updates the post (WordPress REST API) or local file with your approved links

## Link Budget

- 3–5 internal links per post
- 2–4 external links per post
- No links in the opening paragraph
- Internal links take priority over external
