# Humanize

Reviews and edits copy to remove AI-generated patterns and make text sound natural. Based on Wikipedia's "Signs of AI writing" guide, with 30 rules across 6 categories.

## Quick Start

1. Paste or point to text that sounds too AI-generated
2. Ask: "Humanize this", "Make it less AI", "This sounds robotic", or "Edit my copy"
3. The skill scores the text, rewrites problem sections, and self-checks the result
4. Returns a before/after score report, the rewritten text, and a summary of changes

## What It Does

- Scans text against 30 rules for AI writing patterns
- Scores text before and after rewriting (100-point scale)
- Removes AI vocabulary ("delve", "leverage", "foster", "vibrant")
- Cuts filler openings, hedging, and formulaic transitions
- Removes communication artifacts ("I hope this helps!", "Great question!")
- Replaces em dashes with commas, periods, or parentheses
- Adds natural voice, personality, and varied rhythm
- Self-checks rewrites to avoid introducing new AI patterns

## Rule Categories

| Category | Impact | What It Catches |
|----------|--------|-----------------|
| Content | HIGH | Significance inflation, vague attribution, promotional language |
| Language | HIGH | AI vocabulary, dual adjectives, negative parallelism, synonym cycling |
| Style | MEDIUM | Em dashes, mechanical bold, decorative emojis, curly quotes |
| Communication | HIGH | "I hope this helps!", "as of my last update", sycophantic openers |
| Filler | MEDIUM | "In today's fast-paced world", hedging, formulaic transitions |
| Voice | HIGH | Missing personality, flat rhythm, no opinions |

## Scoring

- **95-100**: Clean, sounds human
- **85-94**: Minor issues, mostly fine
- **70-84**: Noticeable AI patterns
- **Below 70**: Needs significant work

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill instructions, all 30 rules, and scoring system |
| `references/` | 36 reference files covering content, language, style, communication, filler, and voice rules |

## Customizing

Set `WRITING_STYLE_GUIDE_PATH` in `~/.claude/settings.json` to load your personal writing style guide before processing.

## Tips

- Works on any text: blog posts, documentation, emails, marketing copy
- The score report shows exactly which categories improved
- The skill preserves meaning and factual claims — it only changes how things are said
