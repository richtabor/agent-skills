---
name: technical-writing
description: Writes technical blog posts about features being built. Triggers when user asks to write about development progress, implementations, or project updates.
---

# Technical Writing Skill

## Overview

Create technical blog posts about features you're building. This skill analyzes your codebase to understand implementations, then structures clear, engaging content that balances technical detail with readability while avoiding AI-sounding language.

## Process

### Phase 1: Research and Planning

**1.1 Load Writing Guides (REQUIRED - Load First)**

Before any other work, read BOTH reference files:

1. **Writing Rules** (`references/anti-patterns.md`) - Comprehensive lists of AI-sounding words, phrases, and patterns to avoid. This is the foundation - what NOT to sound like.

2. **Style Guide** (`references/style-guide.md`) - Personal writing voice, tone, structure, and signature moves. This is the voice layer - what TO sound like.

**PRIORITY RULE**: When guides conflict, `references/anti-patterns.md` wins. Avoiding AI patterns always takes precedence over stylistic choices.

**1.2 Understand What Was Built**

Investigate the codebase to understand the feature:

- Ask which feature or changes they want to write about
- Use git to check recent commits if relevant (skip if not a git repo): `git log --oneline -10`
- Read relevant code files to understand implementation
- Identify key technical decisions, architecture, and interesting details
- Note any challenges solved or clever solutions

**1.3 Plan the Structure**

Plan what to cover in the post. Use these as a guide, not a rigid template:

- **Opening**: Start with an engaging hook or context for what you built
- **Overview**: Brief explanation of the feature (2-3 sentences)
- **Problem/Value**: Why this matters or what problem it solves
- **Technical Details**: How it works with code snippets
  - Key implementation details
  - Interesting technical decisions
  - Architecture or design patterns used
- **Challenges**: What was tricky and how you solved it (if relevant)
- **Future**: Next steps or related features (if relevant)
- **Tech Stack**: Technologies used (can be woven into the narrative or listed)

The actual headings, structure, and flow should feel natural to the specific post - not formulaic.

### Phase 2: Writing

**2.1 Draft Creation**

Create the blog post applying BOTH guides you loaded in Phase 1.

**Code Snippets:**
- Keep snippets short (5-15 lines)

**Target length**: 500-1200 words depending on complexity

**2.2 Save the Draft**

Save the completed blog post to `.blog/` (create the folder if missing):

**File naming convention:**
- Format: `.blog/YYYY-MM-DD-slug.md`
- Use URL-friendly slug based on title
- Example: `.blog/2025-12-29-voice-planner.md`

### Phase 3: Publishing (Optional)

**3.1 WordPress Publishing**

If the user wants to publish to WordPress, load **WordPress Publishing Guide** (`references/wordpress-publishing.md`) for complete setup and publishing instructions.

The guide covers:
- Environment setup and credentials
- Python dependencies installation
- Publishing commands and workflow
- Smart update tracking (no duplicate posts)
- Troubleshooting common issues

Quick summary:
- First time: Creates new WordPress draft
- Subsequent: Updates existing draft (no duplicates)
- Always saves as draft (never auto-publishes)
- Returns post URL and edit URL

## Output Format

After creating and saving the blog post, provide:

1. **Saved Location**: Path where the post was saved
2. **Post Title**: The final title used
3. **Suggested Tags**: 4-6 relevant tags for WordPress
4. **Key Files Referenced**: List of files mentioned with line numbers
5. **Word Count**: Approximate length

## Example Interaction

**User**: "Help me write about the voice planning feature"

**Response**:
```
Let me investigate the voice planning implementation to write about it.

[Phase 1: Loads references/anti-patterns.md and references/style-guide.md]
[Reads relevant files: voice-session.tsx, api/webhook/route.ts, claude.ts]

[Phase 2: Creates and saves blog post applying both guides]

Blog post saved to: .blog/2025-12-29-voice-first-planning.md

Title: "Planning Out Loud"

Suggested Tags:
- voice-ai
- elevenlabs
- anthropic-claude
- daily-planning
- nextjs
- productivity-tools

Key Files Referenced:
- src/components/voice-session.tsx:78 (voice session initialization)
- src/app/api/webhook/route.ts:40 (webhook signature validation)
- src/lib/claude.ts:88 (Claude tool calling)
- src/lib/github.ts:107 (GitHub atomic commits)

Word Count: ~850 words

Would you like me to adjust the tone, add more technical detail, or publish this to WordPress?
```

## Tips for Best Results

1. **Be specific about scope**: "Write about the webhook security implementation" is better than "write about webhooks"
2. **Mention target audience**: "For developers familiar with Next.js" vs "For non-technical readers"
3. **Specify length preference**: "Quick 500-word update" vs "Detailed deep-dive"
4. **Share context**: "This is part 2 in a series" or "First post about this project"
5. **Request revisions**: After the draft, ask to expand sections, simplify explanations, or adjust tone

## Advanced: Series Posts

For multi-part series:
- Start with "Help me outline a 3-part series about [topic]"
- Each post should build on previous ones
- Include "Previously" and "Next up" sections
- Keep consistent structure across posts
