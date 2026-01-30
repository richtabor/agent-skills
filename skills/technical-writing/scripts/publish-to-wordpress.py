#!/usr/bin/env python3
"""
Publish a markdown blog post to WordPress via REST API.

This script converts markdown to HTML and posts it to WordPress as a draft or published post.

Requirements:
    pip install requests markdown2

Environment variables:
    WORDPRESS_URL: Your WordPress site URL (e.g., https://myblog.com)
    WORDPRESS_USERNAME: WordPress username
    WORDPRESS_APP_PASSWORD: WordPress Application Password

Usage:
    python publish-to-wordpress.py <markdown_file> [--publish] [--tags tag1,tag2,tag3]
"""

import sys
import os
import json
import base64
import re
from pathlib import Path
from datetime import datetime

try:
    import requests
except ImportError:
    print(json.dumps({
        "success": False,
        "error": "requests library not found. Install with: pip install requests"
    }))
    sys.exit(1)

try:
    import markdown2
except ImportError:
    print(json.dumps({
        "success": False,
        "error": "markdown2 library not found. Install with: pip install markdown2"
    }))
    sys.exit(1)


def load_env_file():
    """Load environment variables from .env.local or .env file in skill directory."""
    script_dir = Path(__file__).parent
    skill_dir = script_dir.parent

    # Try .env.local first, then .env
    for env_file in [skill_dir / '.env.local', skill_dir / '.env']:
        if env_file.exists():
            with open(env_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    # Skip comments and empty lines
                    if not line or line.startswith('#'):
                        continue

                    # Parse lines like: export WORDPRESS_URL="https://example.com"
                    # or: WORDPRESS_URL="https://example.com"
                    match = re.match(r'(?:export\s+)?(\w+)=["\']?([^"\']+)["\']?', line)
                    if match:
                        key, value = match.groups()
                        # Only set if not already in environment
                        if key not in os.environ:
                            os.environ[key] = value.strip()


def get_post_mapping_file():
    """Get path to the post mapping file."""
    # Mapping file is stored in .drafts directory
    # Script is at: .claude/skills/dev-blog/scripts/publish-to-wordpress.py
    # Need to go up 4 levels to get to project root
    script_dir = Path(__file__).parent  # .claude/skills/dev-blog/scripts
    project_root = script_dir.parent.parent.parent.parent  # project root
    blog_dir = project_root / '.drafts'
    return blog_dir / 'wordpress.json'


def load_post_mappings():
    """Load the mapping of markdown files to WordPress post IDs."""
    mapping_file = get_post_mapping_file()
    if mapping_file.exists():
        try:
            with open(mapping_file, 'r') as f:
                return json.load(f)
        except:
            return {}
    return {}


def get_relative_path(markdown_file):
    """Get relative path from project root."""
    abs_path = Path(markdown_file).resolve()
    # Find project root (contains .drafts directory)
    current = abs_path.parent
    while current != current.parent:
        if (current / '.drafts').exists():
            try:
                return str(abs_path.relative_to(current))
            except ValueError:
                # File is not within project, use absolute
                return str(abs_path)
        current = current.parent
    return str(abs_path)


def save_post_mapping(markdown_file, post_id, post_url, slug=None):
    """Save a mapping of markdown file to WordPress post ID.

    Uses the frontmatter slug as the primary key if available,
    with file path as fallback for backwards compatibility.
    """
    mapping_file = get_post_mapping_file()
    mappings = load_post_mappings()

    entry = {
        "post_id": post_id,
        "post_url": post_url,
        "last_updated": datetime.now().isoformat()
    }

    # Primary key: slug from frontmatter url (stable across file moves)
    if slug:
        mappings[slug] = entry

    # Also store by file path for backwards compatibility
    relative_path = get_relative_path(markdown_file)
    mappings[relative_path] = entry

    # Ensure .drafts directory exists
    mapping_file.parent.mkdir(parents=True, exist_ok=True)

    with open(mapping_file, 'w') as f:
        json.dump(mappings, f, indent=2)


def get_existing_post_id(markdown_file, slug=None):
    """Get the WordPress post ID for a markdown file, if it exists.

    Checks slug first (stable), then falls back to file path.
    """
    mappings = load_post_mappings()

    # Check by slug first (survives file moves/renames)
    if slug and slug in mappings:
        return mappings[slug].get('post_id')

    # Fall back to file path
    relative_path = get_relative_path(markdown_file)
    if relative_path in mappings:
        return mappings[relative_path].get('post_id')

    return None


def parse_frontmatter(content):
    """Parse YAML frontmatter from markdown content.

    Returns (metadata_dict, content_without_frontmatter).
    """
    if not content.startswith('---'):
        return {}, content

    end = content.find('---', 3)
    if end == -1:
        return {}, content

    frontmatter_text = content[3:end].strip()
    body = content[end + 3:].strip()

    metadata = {}
    current_key = None
    current_list = None

    for line in frontmatter_text.split('\n'):
        stripped = line.strip()
        # List item (e.g. "  - Development")
        if stripped.startswith('- ') and current_key:
            if current_list is None:
                current_list = []
            current_list.append(stripped[2:].strip())
            metadata[current_key] = current_list
            continue

        # Save any in-progress list
        current_list = None

        if ':' in stripped:
            key, _, value = stripped.partition(':')
            current_key = key.strip()
            value = value.strip()
            if value:
                metadata[current_key] = value
            # If value is empty, it might be followed by a list

    return metadata, body


def extract_title_from_markdown(content):
    """Extract the first H1 heading as the title."""
    for line in content.split('\n'):
        line = line.strip()
        if line.startswith('# '):
            return line[2:].strip()
    return "Untitled Post"


def convert_markdown_to_html(markdown_content):
    """Convert markdown to HTML with code highlighting and proper formatting."""
    html = markdown2.markdown(
        markdown_content,
        extras=[
            "fenced-code-blocks",
            "code-friendly",
            "cuddled-lists",
            "header-ids",
            "tables",
            "break-on-newline"
        ]
    )
    return html


def convert_markdown_to_blocks(markdown_content):
    """Convert markdown to WordPress Gutenberg block format."""
    import html as html_module

    blocks = []
    lines = markdown_content.split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]

        # Skip empty lines
        if not line.strip():
            i += 1
            continue

        # Headings (## or ###)
        if line.startswith('## '):
            heading_text = line[3:].strip()
            blocks.append(f'<!-- wp:heading -->\n<h2 class="wp-block-heading">{heading_text}</h2>\n<!-- /wp:heading -->')
            i += 1
        elif line.startswith('### '):
            heading_text = line[4:].strip()
            blocks.append(f'<!-- wp:heading {{"level":3}} -->\n<h3 class="wp-block-heading">{heading_text}</h3>\n<!-- /wp:heading -->')
            i += 1
        # Code blocks
        elif line.startswith('```'):
            code_lines = []
            language = line[3:].strip() or ''
            i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                code_lines.append(lines[i])
                i += 1
            code_content = '\n'.join(code_lines)
            code_escaped = html_module.escape(code_content)
            blocks.append(f'<!-- wp:code -->\n<pre class="wp-block-code"><code>{code_escaped}</code></pre>\n<!-- /wp:code -->')
            i += 1  # skip closing ```
        # Unordered lists
        elif line.startswith('- ') or line.startswith('* '):
            list_items = []
            while i < len(lines) and (lines[i].startswith('- ') or lines[i].startswith('* ')):
                item_text = lines[i][2:].strip()
                # Handle inline markdown in list items
                item_text = re.sub(r'\[([^\]]+)\]\(([^\)]+)\)', r'<a href="\2">\1</a>', item_text)
                item_text = re.sub(r'`([^`]+)`', r'<code>\1</code>', item_text)
                item_text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', item_text)
                list_items.append(f'<li>{item_text}</li>')
                i += 1
            list_html = '\n'.join(list_items)
            blocks.append(f'<!-- wp:list -->\n<ul class="wp-block-list">\n{list_html}\n</ul>\n<!-- /wp:list -->')
        # Ordered lists
        elif re.match(r'^\d+\.\s', line):
            list_items = []
            while i < len(lines) and re.match(r'^\d+\.\s', lines[i]):
                item_text = re.sub(r'^\d+\.\s', '', lines[i])
                item_text = re.sub(r'\[([^\]]+)\]\(([^\)]+)\)', r'<a href="\2">\1</a>', item_text)
                item_text = re.sub(r'`([^`]+)`', r'<code>\1</code>', item_text)
                item_text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', item_text)
                list_items.append(f'<li>{item_text}</li>')
                i += 1
            list_html = '\n'.join(list_items)
            blocks.append(f'<!-- wp:list {{"ordered":true}} -->\n<ol class="wp-block-list">\n{list_html}\n</ol>\n<!-- /wp:list -->')
        # Paragraphs
        else:
            para_lines = []
            # Check for list items more carefully: must have '- ' or '* ' (with space)
            while i < len(lines) and lines[i].strip() and not lines[i].startswith('#') and not lines[i].startswith('```') and not (lines[i].startswith('- ') or lines[i].startswith('* ')) and not re.match(r'^\d+\.\s', lines[i]):
                para_lines.append(lines[i].strip())
                i += 1
            if para_lines:  # Only create block if we have content
                para_text = ' '.join(para_lines)
                # Convert inline markdown (order matters: links before bold/italic to avoid conflicts)
                para_text = re.sub(r'\[([^\]]+)\]\(([^\)]+)\)', r'<a href="\2">\1</a>', para_text)
                para_text = re.sub(r'`([^`]+)`', r'<code>\1</code>', para_text)
                para_text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', para_text)
                para_text = re.sub(r'(?<!\*)\*(?!\*)([^*]+)\*(?!\*)', r'<em>\1</em>', para_text)
                blocks.append(f'<!-- wp:paragraph -->\n<p>{para_text}</p>\n<!-- /wp:paragraph -->')

    return '\n\n'.join(blocks)


def fetch_wordpress_categories(wordpress_url, headers):
    """Fetch all categories from WordPress."""
    try:
        categories_url = f"{wordpress_url}/wp-json/wp/v2/categories?per_page=100"
        response = requests.get(categories_url, headers=headers, timeout=10)
        if response.status_code == 200:
            return response.json()
    except Exception as e:
        print(f"Warning: Could not fetch categories: {str(e)}", file=sys.stderr)
    return []


def suggest_category(categories, post_title, tags):
    """Suggest a category based on existing categories, title, and tags."""
    if not categories:
        return None

    # Simple keyword matching - prefer "Development" or "Technology" if they exist
    keywords = ["development", "tech", "programming", "code", "software"]

    # Check if any tags match category names
    if tags:
        for tag in tags:
            for cat in categories:
                if tag.lower() in cat['name'].lower():
                    return cat

    # Look for development/tech related categories
    for keyword in keywords:
        for cat in categories:
            if keyword in cat['name'].lower():
                return cat

    # Default to "Uncategorized" or first category
    for cat in categories:
        if cat['name'].lower() == 'uncategorized':
            return cat

    return categories[0] if categories else None


def publish_to_wordpress(markdown_file_path, tags=None):
    """
    Save blog post to WordPress as a draft.

    Args:
        markdown_file_path: Path to the markdown file
        tags: List of tag names (will be created if they don't exist)

    Returns:
        dict: Result with success status and post details or error
    """

    # Load environment variables from .env.local or .env file
    load_env_file()

    # Get credentials from environment
    wordpress_url = os.getenv("WORDPRESS_URL")
    username = os.getenv("WORDPRESS_USERNAME")
    app_password = os.getenv("WORDPRESS_APP_PASSWORD")

    if not all([wordpress_url, username, app_password]):
        return {
            "success": False,
            "error": "Missing WordPress credentials. Set WORDPRESS_URL, WORDPRESS_USERNAME, and WORDPRESS_APP_PASSWORD environment variables."
        }

    # Remove trailing slash from URL
    wordpress_url = wordpress_url.rstrip('/')

    # Read markdown file
    try:
        with open(markdown_file_path, 'r', encoding='utf-8') as f:
            markdown_content = f.read()
    except FileNotFoundError:
        return {
            "success": False,
            "error": f"File not found: {markdown_file_path}"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Error reading file: {str(e)}"
        }

    # Parse frontmatter if present
    metadata, body = parse_frontmatter(markdown_content)

    # Get title from frontmatter, fall back to first H1
    title = metadata.get('title', extract_title_from_markdown(markdown_content))

    # Get slug from url frontmatter field (strip leading slash)
    slug = metadata.get('url', '').lstrip('/')

    # Use frontmatter tags if no CLI tags provided
    if not tags:
        fm_tags = metadata.get('tags')
        if isinstance(fm_tags, list):
            tags = fm_tags

    # If frontmatter was parsed, body already excludes it.
    # Otherwise strip the first H1 from content.
    if metadata:
        markdown_content_final = body
    else:
        content_lines = markdown_content.split('\n')
        content_without_title = []
        title_removed = False
        for line in content_lines:
            if not title_removed and line.strip().startswith('# '):
                title_removed = True
                continue
            content_without_title.append(line)
        markdown_content_final = '\n'.join(content_without_title).strip()

    # Also strip H1 from body if it matches the frontmatter title
    if metadata and markdown_content_final.lstrip().startswith('# '):
        first_line = markdown_content_final.lstrip().split('\n', 1)[0]
        if first_line.startswith('# '):
            markdown_content_final = markdown_content_final.lstrip().split('\n', 1)[-1].strip()

    # Remove the "Tags:" line at the end if present
    # Matches patterns like: **Tags:** tag1, tag2, tag3
    markdown_content_final = re.sub(r'\n*---\s*\n*\*\*Tags:\*\*[^\n]*$', '', markdown_content_final, flags=re.MULTILINE)
    markdown_content_final = re.sub(r'\n*\*\*Tags:\*\*[^\n]*$', '', markdown_content_final, flags=re.MULTILINE)

    # Convert markdown to WordPress blocks
    block_content = convert_markdown_to_blocks(markdown_content_final.strip())

    # Create Basic Auth header
    credentials = f"{username}:{app_password}"
    auth_header = base64.b64encode(credentials.encode()).decode()

    headers = {
        "Authorization": f"Basic {auth_header}",
        "Content-Type": "application/json",
    }

    # Fetch categories from WordPress
    categories = fetch_wordpress_categories(wordpress_url, headers)

    # Use frontmatter category if provided, otherwise auto-suggest
    fm_category = metadata.get('category', '')
    suggested_category = None
    if fm_category and categories:
        for cat in categories:
            if cat['name'].lower() == fm_category.lower():
                suggested_category = cat
                break
    if not suggested_category:
        suggested_category = suggest_category(categories, title, tags)

    # Prepare post data (always as draft)
    post_data = {
        "title": title,
        "content": block_content,
        "status": "draft",
        "format": "standard"
    }

    # Set slug from frontmatter url field
    if slug:
        post_data["slug"] = slug

    # Debug: print content length
    print(f"DEBUG: Sending {len(block_content)} characters of block content", file=sys.stderr)
    print(f"DEBUG: First 300 chars: {block_content[:300]}", file=sys.stderr)

    # Add suggested category if found
    if suggested_category:
        post_data["categories"] = [suggested_category['id']]

    # Handle tags
    if tags:
        # First, get or create tag IDs
        tag_ids = []
        for tag_name in tags:
            tag_name = tag_name.strip()

            # Search for existing tag
            tag_search_url = f"{wordpress_url}/wp-json/wp/v2/tags?search={tag_name}"
            try:
                tag_response = requests.get(tag_search_url, headers=headers)
                if tag_response.status_code == 200:
                    existing_tags = tag_response.json()

                    # Check for exact match
                    exact_match = None
                    for t in existing_tags:
                        if t['name'].lower() == tag_name.lower():
                            exact_match = t
                            break

                    if exact_match:
                        tag_ids.append(exact_match['id'])
                    else:
                        # Create new tag
                        create_tag_url = f"{wordpress_url}/wp-json/wp/v2/tags"
                        tag_create_response = requests.post(
                            create_tag_url,
                            json={"name": tag_name},
                            headers=headers
                        )
                        if tag_create_response.status_code in [200, 201]:
                            new_tag = tag_create_response.json()
                            tag_ids.append(new_tag['id'])
            except Exception as e:
                print(f"Warning: Could not process tag '{tag_name}': {str(e)}", file=sys.stderr)

        if tag_ids:
            post_data["tags"] = tag_ids

    # Check if this markdown file already has a WordPress post
    existing_post_id = get_existing_post_id(markdown_file_path, slug=slug)

    if existing_post_id:
        # Update existing post
        endpoint = f"{wordpress_url}/wp-json/wp/v2/posts/{existing_post_id}"
        action = "updated"
    else:
        # Create new post
        endpoint = f"{wordpress_url}/wp-json/wp/v2/posts"
        action = "created"

    try:
        if existing_post_id:
            response = requests.post(endpoint, json=post_data, headers=headers, timeout=30)
        else:
            response = requests.post(endpoint, json=post_data, headers=headers, timeout=30)

        if response.status_code in [200, 201]:
            post = response.json()

            # Save the mapping for future updates
            save_post_mapping(markdown_file_path, post["id"], post["link"], slug=slug)

            result = {
                "success": True,
                "message": f"Post {action} as draft",
                "title": title,
                "post_id": post["id"],
                "post_url": post["link"],
                "edit_url": f"{wordpress_url}/wp-admin/post.php?post={post['id']}&action=edit",
                "status": "draft",
                "action": action
            }

            # Add category info if suggested
            if suggested_category:
                result["category"] = suggested_category['name']

            # Add tags info
            if tags:
                result["tags"] = tags

            return result
        else:
            error_detail = response.text
            try:
                error_json = response.json()
                error_detail = error_json.get('message', response.text)
            except:
                pass

            return {
                "success": False,
                "error": f"WordPress API error (status {response.status_code}): {error_detail}"
            }

    except requests.exceptions.Timeout:
        return {
            "success": False,
            "error": "Request timed out. Please check your WordPress URL and internet connection."
        }
    except requests.exceptions.ConnectionError:
        return {
            "success": False,
            "error": f"Could not connect to {wordpress_url}. Please check the URL and your internet connection."
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Unexpected error: {str(e)}"
        }


def main():
    if len(sys.argv) < 2:
        print("Usage: publish-to-wordpress.py <markdown_file> [--tags tag1,tag2,tag3]")
        print("\nOptions:")
        print("  --tags tag1,tag2    Comma-separated list of tags to add to the post")
        print("\nEnvironment variables required:")
        print("  WORDPRESS_URL           Your WordPress site URL")
        print("  WORDPRESS_USERNAME      WordPress username")
        print("  WORDPRESS_APP_PASSWORD  WordPress Application Password")
        print("\nNote: Posts are always saved as drafts. You can publish them from WordPress admin.")
        sys.exit(1)

    markdown_file = sys.argv[1]

    # Parse tags
    tags = None
    for arg in sys.argv:
        if arg.startswith("--tags"):
            if "=" in arg:
                tags = [t.strip() for t in arg.split("=")[1].split(",")]
            elif sys.argv.index(arg) + 1 < len(sys.argv):
                next_arg = sys.argv[sys.argv.index(arg) + 1]
                if not next_arg.startswith("--"):
                    tags = [t.strip() for t in next_arg.split(",")]

    # Save to WordPress as draft
    result = publish_to_wordpress(markdown_file, tags=tags)

    # Output result as JSON
    print(json.dumps(result, indent=2))

    if not result["success"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
