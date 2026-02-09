# Markdown Image Alt Text

Adds detailed alt text to markdown image embeds that are missing it. Supports both Obsidian wiki-style (`![[image]]`) and standard markdown (`![](path)`) formats.

## Quick Start

1. Open a markdown file or folder with images
2. Ask: "Add alt text", "Describe images", or "Update alt text"
3. The skill finds images missing alt text, reads each one, and writes detailed descriptions
4. Embeds are updated inline in the correct format

## What It Does

- Scans markdown files for image embeds missing alt text
- Reads each image file to understand its visual content
- Writes thorough, detailed alt text describing the full visual content
- Updates embeds inline in the format used by the file (Obsidian or standard)
- Reports how many images were found, skipped, and updated

## Supported Formats

**Obsidian wiki-style:**
```
![[image.png]]  →  ![[image.png|alt text here]]
```

**Standard markdown:**
```
![](path/to/image.png)  →  ![alt text here](path/to/image.png)
```

Images that already have alt text are skipped.

## Files

| File | Purpose |
|------|---------|
| `skill.md` | Main skill instructions, format examples, and alt text guidelines |

## Tips

- Specify a file or folder to limit scope, or process the whole project
- Alt text describes full visual content — specific enough that someone could understand the image without seeing it
- Avoids starting with "Image of" or "Screenshot of"
