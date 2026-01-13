#!/bin/bash
# Fetch content from URLs using Firecrawl API for social content creation
# Usage:
#   ./fetch-url-content.sh "https://example.com"         - Get content from URL
#   ./fetch-url-content.sh "https://example.com" markdown - Get markdown format (default)
#   ./fetch-url-content.sh "https://example.com" text    - Get plain text format

set -e

# Helper function to extract error message from JSON response
extract_error() {
    local response="$1"
    echo "$response" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('error', 'Unknown error'))" 2>/dev/null || echo "Unknown error"
}

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

# Validate URL format
if [[ ! "$URL" =~ ^https?:// ]]; then
    echo "Error: Invalid URL format. URL must start with http:// or https://"
    echo "Provided: $URL"
    exit 1
fi

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
TEMP_FILE=$(mktemp)
# Ensure temp file cleanup on exit
trap "rm -f '$TEMP_FILE'" EXIT

# Create JSON payload using Python to properly escape values
PAYLOAD=$(python3 -c "import json, sys; print(json.dumps({'url': sys.argv[1], 'formats': [sys.argv[2]]}))" "$URL" "$FORMAT")

# Send request using stdin to avoid exposing API key in process arguments
HTTP_CODE=$(echo "$PAYLOAD" | curl -s -w "%{http_code}" -o "$TEMP_FILE" -X POST "https://api.firecrawl.dev/v1/scrape" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
    --data-binary @-)

# Check if curl failed
if [ $? -ne 0 ] || [ -z "$HTTP_CODE" ]; then
    echo "Error: Failed to connect to Firecrawl API. Check your internet connection." >&2
    exit 1
fi

# Read the response
RESPONSE=$(cat "$TEMP_FILE")

# Check HTTP status code
if [ "$HTTP_CODE" -ge 400 ]; then
    ERROR_MSG=$(extract_error "$RESPONSE")
    echo "Error: API request failed with status $HTTP_CODE: $ERROR_MSG" >&2
    exit 1
fi

# Check if the request was successful using proper JSON parsing
SUCCESS=$(echo "$RESPONSE" | python3 -c "import sys, json; data = json.load(sys.stdin); print(str(data.get('success', False)).lower())" 2>/dev/null || echo "false")

if [ "$SUCCESS" = "true" ]; then
    # Extract the content using a Python script
    CONTENT=$(echo "$RESPONSE" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    format_type = sys.argv[1]
    
    if 'data' not in data:
        print('Error: data field not found in response', file=sys.stderr)
        sys.exit(1)
    
    if format_type not in data['data']:
        print('Error: {} content not found in response'.format(format_type), file=sys.stderr)
        sys.exit(1)
    
    print(data['data'][format_type])
    
except (json.JSONDecodeError, KeyError) as e:
    print('Error parsing response: {}'.format(e), file=sys.stderr)
    sys.exit(1)
" "$FORMAT" 2>&1)
    
    # Check if content extraction was successful
    if [ $? -ne 0 ]; then
        echo "$CONTENT" >&2
        exit 1
    fi
    
    echo "$CONTENT"
else
    # Extract error message if available
    ERROR_MSG=$(extract_error "$RESPONSE")
    echo "Error fetching content from URL: $ERROR_MSG" >&2
    exit 1
fi
