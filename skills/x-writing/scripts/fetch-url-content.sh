#!/bin/bash
# Fetch content from URLs using Firecrawl API for social content creation
# Usage:
#   ./fetch-url-content.sh "https://example.com"         - Get content from URL
#   ./fetch-url-content.sh "https://example.com" markdown - Get markdown format (default)
#   ./fetch-url-content.sh "https://example.com" text    - Get plain text format

set -e

# Load environment variables if .env.local exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env.local"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Check for required arguments
if [ -z "$1" ]; then
    echo "Error: URL is required"
    echo ""
    echo "Usage:"
    echo "  $0 <url>                    - Get content from URL (markdown format)"
    echo "  $0 <url> markdown           - Get markdown format (default)"
    echo "  $0 <url> text               - Get plain text format"
    echo ""
    echo "Example:"
    echo "  $0 https://example.com/post"
    exit 1
fi

URL="$1"
FORMAT="${2:-markdown}"

# Check for Firecrawl API key
if [ -z "$FIRECRAWL_API_KEY" ]; then
    echo "Error: FIRECRAWL_API_KEY environment variable is not set"
    echo ""
    echo "Please set your Firecrawl API key in .env.local:"
    echo "  export FIRECRAWL_API_KEY=\"your-api-key-here\""
    echo ""
    echo "Get your API key at: https://www.firecrawl.dev"
    exit 1
fi

# Validate format
if [ "$FORMAT" != "markdown" ] && [ "$FORMAT" != "text" ]; then
    echo "Error: Invalid format '$FORMAT'. Must be 'markdown' or 'text'"
    exit 1
fi

# Fetch content using Firecrawl API
HTTP_CODE=$(curl -s -w "%{http_code}" -o /tmp/firecrawl_response.json -X POST "https://api.firecrawl.dev/v1/scrape" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
    -d "{
        \"url\": \"$URL\",
        \"formats\": [\"$FORMAT\"]
    }")

# Check if curl failed
if [ $? -ne 0 ] || [ -z "$HTTP_CODE" ]; then
    echo "Error: Failed to connect to Firecrawl API. Check your internet connection." >&2
    rm -f /tmp/firecrawl_response.json
    exit 1
fi

# Read the response
RESPONSE=$(cat /tmp/firecrawl_response.json)
rm -f /tmp/firecrawl_response.json

# Check HTTP status code
if [ "$HTTP_CODE" -ge 400 ]; then
    ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('error', 'HTTP error $HTTP_CODE'))" 2>/dev/null || echo "HTTP error $HTTP_CODE")
    echo "Error: API request failed with status $HTTP_CODE: $ERROR_MSG" >&2
    exit 1
fi

# Check if the request was successful
if echo "$RESPONSE" | grep -q '"success":true'; then
    # Extract the content based on format
    if [ "$FORMAT" = "markdown" ]; then
        CONTENT=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data and 'markdown' in data['data']:
        print(data['data']['markdown'])
    else:
        print('Error: markdown content not found in response', file=sys.stderr)
        sys.exit(1)
except (json.JSONDecodeError, KeyError) as e:
    print(f'Error parsing response: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1)
    else
        CONTENT=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data and 'text' in data['data']:
        print(data['data']['text'])
    else:
        print('Error: text content not found in response', file=sys.stderr)
        sys.exit(1)
except (json.JSONDecodeError, KeyError) as e:
    print(f'Error parsing response: {e}', file=sys.stderr)
    sys.exit(1)
" 2>&1)
    fi
    
    # Check if content extraction was successful
    if [ $? -ne 0 ]; then
        echo "$CONTENT" >&2
        exit 1
    fi
    
    echo "$CONTENT"
else
    # Extract error message if available
    ERROR_MSG=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('error', 'Unknown error'))" 2>/dev/null || echo "Failed to parse error response")
    echo "Error fetching content from URL: $ERROR_MSG" >&2
    exit 1
fi
