# OG Images

Guides creation of OpenGraph and Twitter share images using `next/og` ImageResponse in Next.js. Covers layout patterns, custom fonts, avatars, title case, Satori rules, and metadata integration.

## Quick Start

1. Decide if you need a file-based route or API route for your OG images
2. Ask: "Create an OG image", "Build a Twitter card", or "Add social previews"
3. The skill generates the route with proper layout, fonts, and Satori-compatible styles
4. Preview at `http://localhost:3000/api/og?title=Hello+World`

## What It Does

- Generates dynamic OpenGraph (1200x630) and Twitter (1200x600) images
- Provides file-based routes for static pages and API routes for dynamic content
- Handles custom font loading from `public/fonts/`
- Applies smart title case for CMS-sourced titles
- Loads avatars/logos as base64 data URIs
- Follows Satori rendering engine constraints (flex-only, inline styles, hex colors)
- Integrates with `generateMetadata()` for Next.js

## Approaches

| Approach | Best For | File |
|----------|----------|------|
| File-based route | Static pages with known titles | `app/opengraph-image.tsx` |
| API route | Dynamic content (blog posts, CMS) | `app/api/og/route.tsx` |

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Layout patterns, font loading, Satori rules, metadata integration, and common issues |

## Tips

- Use `export const runtime = "edge"` for both approaches
- Every element needs `display: "flex"` — it's the only layout mode in Satori
- Use hex colors, not `rgb()`, `hsl()`, or CSS variables
- Convert images to base64 data URIs instead of using relative paths
- Test by visiting the route directly in the browser during development
