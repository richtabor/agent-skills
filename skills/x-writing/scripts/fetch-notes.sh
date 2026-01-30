#!/bin/bash
# Fetch notes from macOS Notes app for social content creation
# Usage:
#   ./fetch-notes.sh list                    - List all notes
#   ./fetch-notes.sh list "Folder Name"      - List notes in specific folder
#   ./fetch-notes.sh get "Note Name"         - Get content of specific note
#   ./fetch-notes.sh get                     - Get content from X_NOTES_APP_SOURCE env var
#   ./fetch-notes.sh recent                  - Get most recent note
#   ./fetch-notes.sh recent 5                - Get 5 most recent notes

set -e

# Load environment variables if .env.local exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env.local"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Default note name from env var or fallback to "Tweets"
DEFAULT_NOTE="${X_NOTES_APP_SOURCE:-Tweets}"

COMMAND="${1:-list}"
ARG="$2"

case "$COMMAND" in
    list)
        if [ -z "$ARG" ]; then
            # List all notes
            osascript <<'EOF'
tell application "Notes"
    set output to ""
    repeat with aNote in every note
        set noteName to name of aNote
        set output to output & noteName & linefeed
    end repeat
    return output
end tell
EOF
        else
            # List notes in specific folder
            osascript -e "tell application \"Notes\"
    set output to \"\"
    repeat with aNote in notes of folder \"$ARG\"
        set output to output & name of aNote & linefeed
    end repeat
    return output
end tell"
        fi
        ;;

    get)
        # Use provided note name or default from env var
        NOTE_NAME="${ARG:-$DEFAULT_NOTE}"

        # Get specific note content
        osascript -e "tell application \"Notes\"
    set theNote to first note whose name is \"$NOTE_NAME\"
    return body of theNote
end tell" | sed 's/<[^>]*>//g' | sed 's/&nbsp;/ /g' | sed 's/&amp;/\&/g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g'
        ;;

    recent)
        COUNT="${ARG:-1}"

        # Get most recent note(s)
        osascript -e "tell application \"Notes\"
    set recentNotes to notes
    set noteCount to $COUNT
    set output to \"\"

    repeat with i from 1 to noteCount
        if i > (count of recentNotes) then exit repeat
        set aNote to item i of recentNotes
        set output to output & \"--- \" & name of aNote & \" ---\" & linefeed & linefeed
        set output to output & body of aNote & linefeed & linefeed
    end repeat

    return output
end tell" | sed 's/<[^>]*>//g' | sed 's/&nbsp;/ /g' | sed 's/&amp;/\&/g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g'
        ;;

    search)
        if [ -z "$ARG" ]; then
            echo "Error: Please provide a search term"
            echo "Usage: $0 search \"search term\""
            exit 1
        fi

        # Search for notes containing text
        osascript -e "tell application \"Notes\"
    set searchTerm to \"$ARG\"
    set output to \"\"

    repeat with aNote in every note
        set noteBody to body of aNote as text
        if noteBody contains searchTerm then
            set output to output & name of aNote & linefeed
        end if
    end repeat

    return output
end tell"
        ;;

    *)
        echo "Unknown command: $COMMAND"
        echo ""
        echo "Usage:"
        echo "  $0 list                    - List all notes with folders"
        echo "  $0 list \"Folder Name\"      - List notes in specific folder"
        echo "  $0 get \"Note Name\"         - Get content of specific note"
        echo "  $0 recent                  - Get most recent note"
        echo "  $0 recent 5                - Get 5 most recent notes"
        echo "  $0 search \"search term\"    - Search for notes containing text"
        exit 1
        ;;
esac
