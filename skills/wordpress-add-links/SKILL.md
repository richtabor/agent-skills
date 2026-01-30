# WordPress Add Links

Find and add internal and external links to a blog post draft, naturally woven into existing sentences.

## Trigger

- "find links for this post"
- "find internal links"
- "add links to this post"
- "link this draft"

## Environment Variables

- `WORDPRESS_URL` — Blog base URL (e.g. `https://yourblog.com`)
- `WORDPRESS_USERNAME` — WordPress account username
- `WORDPRESS_APP_PASSWORD` — Application password (not your regular password)

## Process

### Phase 1: Load the Post

Determine input type from what the user provides:

**Local file** — Read the markdown file. Parse any frontmatter for title, tags, or topic context.

**WordPress URL** — Extract the slug from the URL, then fetch via REST API:

```bash
curl -s "$WORDPRESS_URL/wp-json/wp/v2/posts?slug={slug}&_fields=id,title,content,tags,categories"
```

Store the post ID for later update if working from WordPress.

### Phase 2: Fetch Internal Content

Fetch published posts from the same WordPress site:

```bash
curl -s -u "$WORDPRESS_USERNAME:$WORDPRESS_APP_PASSWORD" \
  "$WORDPRESS_URL/wp-json/wp/v2/posts?per_page=100&_fields=id,title,link,excerpt,tags,categories"
```

From the results:
- Build a list of existing posts with titles, URLs, and excerpts
- Identify posts that are topically relevant to the current draft
- Internal links take priority over external links when both could cover the same topic

### Phase 3: Find External Links

Use web search to find authoritative external references for key topics in the post (tools, libraries, concepts, standards).

Prefer in this order:
1. Official documentation and project pages
2. Primary sources (specs, RFCs, research)
3. Well-known reference sites (MDN, Wikipedia)

Avoid linking to other blog posts or news articles unless no better source exists.

### Phase 4: Add Links Inline

Insert links into the existing text. Rules:

- **Don't add new sentences or paragraphs** — only add links to words/phrases already in the draft
- **Keep anchor text short** — link the subject/topic (2–4 words), not full clauses or sentences. E.g. link "something new" not "Let each project teach you something new"
- **Natural reading test** — if read aloud, the sentence should sound identical with or without the link
- **Link density constraints:**
  - 3–5 internal links per post (fewer for shorter posts)
  - 2–4 external links per post (fewer for shorter posts)
- **No links in the opening paragraph** — let the reader settle in
- **No link clustering** — spread links across different paragraphs
- **No duplicate destinations** — each URL appears once
- **No duplicate anchor text** — each linked phrase is unique

### Phase 5: Review with User

Do not explain what you found, list existing links, or narrate your process. Just present the table and ask for approval.

Present proposed links as a table using `AskUserQuestion`. Each link is a selectable option so the user can pick which ones to apply:

| # | Text | URL | Type | Reason |
|---|------|-----|------|--------|
| 1 | "block patterns" | /block-patterns | Internal | Related tutorial |
| 2 | "WCAG" | w3.org/WAI/WCAG21 | External | Official spec |

Use `AskUserQuestion` with `multiSelect: true` so the user can check the links they want applied. List each link as an option (e.g. label: `"block patterns" → /block-patterns`, description: the reason).

Do not proceed to Phase 6 until the user selects links.

### Phase 6: Save

After approval:

**Local file** — Overwrite the draft with the linked version.

**WordPress post** — Update via REST API:

```bash
curl -s -X POST \
  -u "$WORDPRESS_USERNAME:$WORDPRESS_APP_PASSWORD" \
  "$WORDPRESS_URL/wp-json/wp/v2/posts/{post_id}" \
  -H "Content-Type: application/json" \
  -d '{"content": "...updated HTML..."}'
```

Report final counts:
- Internal links added: X
- External links added: Y
