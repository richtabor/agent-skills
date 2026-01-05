---
name: social-writing
description: Transform notes into engaging social content for X (Twitter). Use when the user wants to create posts, threads, or social content from their notes, ideas, or work updates. Analyzes notes to identify shareable insights and crafts authentic posts that drive engagement. MUST follow BOTH references/x-strategy.md (content selection and growth principles) AND references/style-guide.md (voice and tone).
---

# Social Writing Skill

## Overview

Transform your notes, work updates, and observations into engaging X (Twitter) content. This skill analyzes your notes to identify the most shareable insights, then crafts authentic posts that match your voice and drive engagement.

## Process

### Phase 1: Preparation and Analysis

**1.1 Load Writing Guides (REQUIRED - Load First)**

Before any other work, read ALL THREE reference files:

1. **Growth Principles** (`references/x-strategy.md`) - Content selection criteria, what makes posts shareable, engagement patterns, and what to prioritize from notes. This guides WHAT to share.

2. **Style Guide** (`references/style-guide.md`) - Voice, tone, structure, banned phrases, and signature patterns. This guides HOW to share it.

3. **Anti-Patterns** (`references/anti-patterns.md`) - AI writing patterns to avoid. Critical for ensuring posts sound human and authentic, not AI-generated. Avoid patterns like "It's not X, it's Y", formal transitions, hedging language, and AI-specific vocabulary.

**PRIORITY RULE**: When guides conflict, `references/x-strategy.md` wins. Content value and shareability take precedence over stylistic preferences.

**1.2 Understand the Source Material**

Get clarity on what notes to work with:

- Ask which notes, ideas, or updates they want to transform into posts
- Read the source material (markdown files, text, or pasted content)
- Identify the core insights, learnings, or updates
- Note any specific tools, projects, numbers, or details mentioned

**Multiple ideas/notes workflow:**
- When the user provides multiple distinct ideas or notes, work through them ONE AT A TIME
- Create post options for the first idea
- Wait for user approval/feedback before moving to the next idea
- This prevents overwhelming the user and allows for refinement as you go

**1.3 Apply Selection Criteria**

Using principles from `references/x-strategy.md`, evaluate the notes:

- **High Priority**: Shipped features with learnings, non-obvious insights, specific tool recommendations, solutions to common problems
- **Medium Priority**: Industry takes with unique angles, process improvements with examples
- **Low Priority**: Generic progress updates, future plans, obvious observations
- **Skip**: Engagement bait, vague hype, complaints without solutions

For each potential post, verify:
- Does it teach something specific?
- Is it backed by real experience?
- Would you want to read this if someone else posted it?

### Phase 2: Content Creation

**2.1 Select the Best Angle**

From your analysis, identify:
- **One clear idea** - What's the single most interesting insight?
- **Specific details** - What names, numbers, or examples prove the point?
- **The hook** - What's the opening line that makes someone stop scrolling?

**2.2 Choose the Format**

Based on the content:

**Single Tweet** (most content) - Use for:
- One clear insight or observation
- Quick ship updates with learning
- Tool recommendations
- Strong observations

**Thread (2-5 tweets)** - Only use when you have:
- A narrative with steps
- Multiple related insights that build on each other
- Before/after story with context

**2.3 Draft the Content**

Apply BOTH guides loaded in Phase 1:

**From style-guide.md:**
- Direct, zero fluff - Get to the point in line 1
- Hook = first line
- Short sentences (10-15 words max)
- Specific over generic (names, tools, numbers)
- Present tense, active voice
- 180-250 characters (leave room for RTs)
- Avoid banned phrases (game-changer, unlock, dive in, leverage)

**From x-strategy.md:**
- Value first - Give readers something useful
- Show your work - Share process and reasoning
- Specificity builds credibility
- One clear idea per post

**Pattern Selection:**
Use appropriate pattern from x-strategy.md:
- "Here's what I learned" - For insights
- "Shipped X, learned Y" - For updates
- Specific vs Generic - For challenging assumptions
- Tool Recommendation - For workflow improvements
- Problem → Solution - For how you solved something

**2.4 Engagement Optimization**

End 70% of posts with engagement:
- Specific question: "How do you handle [specific thing]?"
- Teaser: "More on this soon."
- Invitation: "Curious what you think."
- Hard stop (30%): Let the insight land

**2.5 Quality Check**

Before finalizing, verify against the three loaded reference files:
- [ ] Did I get to the point in line 1?
- [ ] Is this specific? (names, numbers, examples)
- [ ] Would I actually say this out loud?
- [ ] Does it sound like ME, not ChatGPT?
- [ ] Did I use any banned phrases from style-guide.md?
- [ ] Did I avoid AI patterns from anti-patterns.md?
- [ ] If it's a reaction, did I add MY angle?

### Phase 3: Output

**3.1 Present the Content**

For each post created:

1. **The Post(s)** - Show the actual tweet(s) ready to copy/paste
2. **Format** - Indicate if it's a single tweet or thread
3. **Character Count** - Show length (target: 180-250 chars)
4. **Pattern Used** - Which pattern from x-strategy.md was applied
5. **Key Elements** - What specifics, tools, or projects were highlighted

**3.2 Offer Options**

When appropriate, provide 2-3 variations:
- Different angles on the same insight
- Single tweet vs thread format
- Different engagement endings

**3.3 Explain Selections**

Briefly note what was prioritized and why:
- Which insights from notes were selected
- Why certain details were emphasized
- What was intentionally left out

**3.4 Save Approved Posts**

When the user approves a post, append it to `.social/X.md` at the top level (create if missing).

**File location:**
- Always save to: `.social/X.md` (top-level, works from any directory)

**Markdown format:**
```markdown
---

**Category:** Learning
**Type:** Single
**Status:** approved
**Date:** 2026-01-01

WordPress.com AI adds conversation alongside block editing.

People who couldn't navigate the UI before are shipping sites now. Others still use blocks for fine-tuning.

Both work. The conversation path just removes the skill barrier.

---
```

**For threads**, use markers to distinguish tweets:
```markdown
---

**Category:** Learning
**Type:** Thread
**Status:** approved
**Date:** 2026-01-01

[THREAD - Tweet 1/4]
WordPress.com AI changes how people build sites.

[Tweet 2/4]
People who couldn't navigate block editing are shipping now.

[Tweet 3/4]
The UI is still there for fine-tuning. But conversation removes the skill barrier.

[Tweet 4/4]
Ask or click. Both paths work.

---
```

**Categories:**
- **Learning** - Insights, shipped updates with learnings
- **Update** - Project progress
- **Tool** - Recommendations
- **Observation** - Industry takes

**Workflow:**
1. Present the post(s) to the user
2. When approved, append to `.social/X.md`
3. User can copy-paste directly into X (text is ready with proper line breaks)
4. User removes the section after posting, or asks you to remove it

## Output Format

After creating social content, provide:

```
📱 Post 1 (Single Tweet, 210 chars)
─────────────────────────────────
[Actual tweet text ready to copy/paste]

Pattern: "Shipped X, learned Y"
Specifics: agents.foo, conversational context matching
Engagement: Specific question

─────────────────────────────────

From your notes, I prioritized:
✓ The discovery insight (most shareable)
✓ Why traditional search failed (specific learning)
✗ Timeline details (not core value)

Alternative angles:
• Focus on the technical implementation
• Thread breaking down the 3 attempts
```

## Example Interaction

**User**: "Help me create a post from these notes about building the curation feature"

**Response**:
```
Let me analyze your notes and create X content.

[Phase 1: Loads references/x-strategy.md and references/style-guide.md]
[Reads the notes, identifies key insights and specific details]

─────────────────────────────────
📱 Post (Single Tweet, 218 chars)
─────────────────────────────────

Shipped curation v1 for agents.foo today.

Discovery is way harder than app stores. Agents are conversations, not static features.

Had to rebuild around context matching instead of keyword search.

Pattern: "Shipped X, learned Y"
Key specifics: agents.foo, context matching vs keyword search
Engagement: Implicit (landing the insight)

─────────────────────────────────

From your notes, I selected:
✓ Core insight: agent discovery is different
✓ Specific solution: context matching
✓ Concrete detail: agents.foo
✗ Number of rebuild attempts (not essential to the insight)

Would you like me to:
• Save this approved post to .social/ for tracking
• Create a thread version breaking down why search patterns failed
• Add a question ending for more engagement
• Draft additional posts from other insights in your notes
```

## Tips for Best Results

1. **Provide context**: "Notes from building curation feature" vs just pasting notes
2. **Mention specific parts**: "Focus on the learning about context matching" helps prioritize
3. **Indicate quantity**: "Create 3 posts from these notes" vs "create posts"
4. **Specify format preference**: "Single tweets only" or "open to threads"
5. **Request variations**: "Show me a few angles" gives options to choose from
6. **Iterate**: After the draft, request adjustments: "Make it more specific" or "Add a question ending"

## Working with Different Note Types

### Technical/Dev Notes
- Extract specific tools, frameworks, or technical decisions
- Focus on the "why" behind technical choices
- Include measurable improvements (time saved, performance gains)

### Personal Observations
- Find the counter-intuitive angle
- Add specific examples from your work
- Tie to practical application

### Meeting Notes
- Extract actionable insights
- Skip procedural details
- Focus on decisions or learnings

### Work Updates
- Lead with what shipped
- Include one key learning
- Make it specific (not "made progress")

## Advanced: Batch Processing

For multiple posts from one set of notes:

1. **Identify 3-5 distinct insights** worth sharing
2. **Create separate posts** for each (don't try to cram everything)
3. **Space them out** - Don't post all at once
4. **Vary patterns** - Use different structures for variety
5. **Test and iterate** - See what resonates, refine approach

## Remember

**Quality over quantity.** 2 valuable posts beat 10 generic ones.

**Specificity is everything.** Names, numbers, tools, projects - these make posts shareable.

**Your voice matters.** Follow the guides but sound like yourself, not a template.

**Value first.** If it doesn't teach, share insight, or help someone - reconsider posting it.
