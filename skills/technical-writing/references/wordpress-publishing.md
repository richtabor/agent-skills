# Publishing to WordPress

Once you've drafted a blog post, you can publish it directly to WordPress via the REST API.

## Setup (One Time)

You'll need three things:

1. **WordPress site URL**: Your blog URL (e.g., `https://yourblog.com`)
2. **WordPress username**: Your WordPress account username
3. **Application Password**: Generate one at WordPress.com → Account Settings → Security → Application Passwords
   - **Important**: Use an Application Password, NOT your regular WordPress password
   - Application Passwords can be revoked independently for better security

Add these to your Claude Code settings (`~/.claude/settings.json`) under the `env` key:

```json
{
  "env": {
    "WORDPRESS_URL": "https://yourblog.com",
    "WORDPRESS_USERNAME": "your_username",
    "WORDPRESS_APP_PASSWORD": "xxxx xxxx xxxx xxxx"
  }
}
```

## Installing Dependencies

The publishing script requires two Python packages:

```bash
pip install requests markdown2
```

## Publishing Your Post

After creating a blog post (automatically saved to `.drafts/`), you can save it to WordPress as a draft:

**Save to WordPress:**
```
Save this to WordPress
```

**Save with specific tags:**
```
Save this to WordPress with tags: nextjs, voice-ai, development
```

**Update an existing post:**
```
Update the voice planner post on WordPress
```

The script will automatically:
1. **Check if the post already exists** (tracks via `.drafts/wordpress.json`)
2. If exists: **Update the existing draft** (no duplicate posts!)
3. If new: Create new draft and save the mapping
4. Extract the title from the first H1 heading in your markdown
5. Convert markdown to Gutenberg blocks
6. Fetch your WordPress categories and suggest the best match
7. Create or find WordPress tags
8. **Always saves as draft** (never publishes immediately - you publish manually from WordPress admin)
9. Return the post URL, edit URL, suggested category, and tags

**Smart Updates:**
- First time saving: Creates new WordPress draft post
- Subsequent saves: Updates the same WordPress post
- No duplicate posts - each markdown file maps to one WordPress post
- Mapping stored in `.drafts/wordpress.json`

## How It Works

When you ask to save to WordPress, the skill runs:

```bash
python scripts/publish-to-wordpress.py .drafts/2025-12-29-voice-planner.md --tags nextjs,voice-ai
```

**First time (creates new post):**
```json
{
  "success": true,
  "message": "Post created as draft",
  "title": "Planning Out Loud",
  "post_id": 123,
  "post_url": "https://yourblog.com/?p=123",
  "edit_url": "https://yourblog.com/wp-admin/post.php?post=123&action=edit",
  "status": "draft",
  "action": "created",
  "category": "Development",
  "tags": ["nextjs", "voice-ai"]
}
```

**Subsequent times (updates existing post):**
```json
{
  "success": true,
  "message": "Post updated as draft",
  "title": "Planning Out Loud",
  "post_id": 123,
  "post_url": "https://yourblog.com/?p=123",
  "edit_url": "https://yourblog.com/wp-admin/post.php?post=123&action=edit",
  "status": "draft",
  "action": "updated",
  "category": "Development",
  "tags": ["nextjs", "voice-ai"]
}
```

Notice the post_id stays the same (123) - it updates the existing post instead of creating duplicates.

**Workflow:**
1. All blog drafts are stored in `.drafts/` with date-based filenames
2. Mapping of markdown files to WordPress posts is tracked in `.drafts/wordpress.json`
3. First save creates a new WordPress draft
4. Subsequent saves update the same WordPress draft
5. You can preview, edit, and publish from WordPress admin when ready

## Troubleshooting

**"Missing WordPress credentials" error:**
- Make sure environment variables are set in `~/.claude/settings.json` under the `env` key

**Connection errors:**
- Verify your `WORDPRESS_URL` is correct (include `https://`)
- Check your internet connection
- Ensure your WordPress site is accessible

**Authentication errors:**
- Generate a fresh Application Password
- Don't use your regular WordPress password
- Check username spelling

**Python package errors:**
- Run `pip install requests markdown2`
