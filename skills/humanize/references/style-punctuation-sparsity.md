---
title: Restore Human Punctuation Density
category: style
impact: medium
---

## Restore Human Punctuation Density

A stronger 2026 tell than em dashes is how little punctuation AI uses. Models write long sentences glued with `and`, and they use fewer commas, semicolons, and parentheses than humans. They also rarely quote people, so they skip the punctuation that quotation brings.

**AI pattern:**
> The policy expands access and reduces wait times and aligns incentives across agencies and the consequences are significant for rural communities.

**Human alternative:**
> The policy expands access and cuts wait times. It also realigns incentives across agencies. Rural communities feel that first.

**Patterns to watch:**
- Long sentences with `and` as the main joint (AI's most overused word)
- Almost no commas, semicolons, or parentheses in a paragraph
- No short interrupting sentence in a run of long ones
- No quoted speech or expert asides

**Fix:** Break `and`-chains into two sentences. Restore commas and parenthetical asides where a human would pause. Drop in a short sentence. If the source names a person, quote them instead of paraphrasing into one long clause.

See also `style-rhythm` (cadence) and `language-negative-parallelism` (rhetorical templates used to fake liveliness).
