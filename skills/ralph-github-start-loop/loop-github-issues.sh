#!/bin/bash
# Loop GitHub Issues - Autonomous agent loop with GitHub Issues
# Usage: ./loop-github-issues.sh [max_iterations] [prd-search-term] [--all]

set -e

# Parse arguments
MAX_ITERATIONS=10
PRD_SEARCH=""
RUN_ALL=false

for arg in "$@"; do
  if [[ "$arg" == "--all" ]] || [[ "$arg" == "-a" ]]; then
    RUN_ALL=true
  elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$arg
  else
    PRD_SEARCH=$arg
  fi
done

# Auto-enable --all when not running interactively (no tty)
if [ ! -t 0 ]; then
  RUN_ALL=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_REPO="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_REPO")"

# Get repo owner/name for gh commands
REPO_FULL=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null) || {
  echo "Error: Could not determine repository. Ensure gh is authenticated and you're in a git repo."
  exit 1
}

# Check if an issue is closed
is_issue_closed() {
  local issue_number="$1"
  local state
  state=$(gh issue view "$issue_number" --json state -q '.state' 2>/dev/null)
  [ "$state" = "CLOSED" ]
}

# Check if all blocking issues are closed (using native GitHub blocking)
are_blockers_closed() {
  local issue_number="$1"
  get_repo_parts "$REPO_FULL"

  local blockers
  blockers=$(gh api graphql \
    -F owner="$REPO_OWNER" -F repo="$REPO_NAME_ONLY" -F number="$issue_number" \
    -f query='
      query($owner: String!, $repo: String!, $number: Int!) {
        repository(owner: $owner, name: $repo) {
          issue(number: $number) {
            blockedBy(first: 20) {
              nodes { number state }
            }
          }
        }
      }' --jq '.data.repository.issue.blockedBy.nodes' 2>/dev/null)

  # Check if any blockers are OPEN
  local open_blockers
  open_blockers=$(echo "$blockers" | jq '[.[] | select(.state == "OPEN")] | length' 2>/dev/null || echo "0")

  [ "$open_blockers" = "0" ] || [ "$open_blockers" = "null" ] || [ -z "$open_blockers" ]
}

# Get repo owner and name
get_repo_parts() {
  local full="$1"
  REPO_OWNER=$(echo "$full" | cut -d'/' -f1)
  REPO_NAME_ONLY=$(echo "$full" | cut -d'/' -f2)
}

# Get all open sub-issues for a parent PRD using gh-sub-issue extension
get_sub_issues() {
  local parent_number="$1"
  gh sub-issue list "$parent_number" --state open --json number,title,state 2>/dev/null | jq '.subIssues // []' || echo "[]"
}

# Check if all sub-issues are closed
all_sub_issues_closed() {
  local parent_number="$1"
  local sub_issues
  sub_issues=$(get_sub_issues "$parent_number")
  local open_count
  open_count=$(echo "$sub_issues" | jq 'length')
  [ "$open_count" = "0" ] || [ "$open_count" = "null" ]
}

# Get closed sub-issues for a parent PRD
get_closed_sub_issues() {
  local parent_number="$1"
  gh sub-issue list "$parent_number" --state closed --json number,title 2>/dev/null | jq -r '.subIssues // [] | .[] | "- [x] #\(.number) \(.title)"'
}

# Get acceptance criteria from closed sub-issues
get_acceptance_criteria() {
  local parent_number="$1"
  local sub_issues
  sub_issues=$(gh sub-issue list "$parent_number" --state closed --json number,title 2>/dev/null | jq -r '.subIssues // [] | .[].number')

  for issue_num in $sub_issues; do
    local body
    body=$(gh issue view "$issue_num" --json body -q '.body' 2>/dev/null || echo "")
    # Extract acceptance criteria section
    local criteria
    criteria=$(echo "$body" | sed -n '/^## Acceptance Criteria/,/^## /p' | sed '1d;$d')
    if [ -n "$criteria" ]; then
      echo "$criteria"
    fi
  done
}


# Extract branch name from PRD issue body
get_branch_name() {
  local body="$1"
  # Look for branch specification in body like: `feature/name` or `bugfix/name`
  local branch
  branch=$(echo "$body" | grep -oE '`(feature|bugfix)/[a-zA-Z0-9_-]+`' | tr -d '`' | head -1)

  if [ -z "$branch" ]; then
    # Fallback: extract from title
    echo ""
  else
    echo "$branch"
  fi
}

# Find open PRD issues
find_prd_issues() {
  gh issue list --label prd --state open --json number,title,body --limit 50
}

# Check if a PRD already has an open PR (by searching PR body for issue reference)
has_open_pr() {
  local issue_number="$1"
  local pr_count
  # Search for open PRs that reference this issue number in any form
  pr_count=$(gh pr list --state open --json number,body 2>/dev/null | jq --arg num "#$issue_number" '[.[] | select(.body | contains($num))] | length')
  [ "$pr_count" != "0" ] && [ "$pr_count" != "null" ] && [ -n "$pr_count" ]
}

# Show PRD status
show_prd_status() {
  echo "PRD Issues Status:"
  echo "───────────────────"

  local prds
  prds=$(find_prd_issues)

  if [ "$(echo "$prds" | jq 'length')" = "0" ]; then
    echo "  No open PRD issues found."
    return
  fi

  local prd_count
  prd_count=$(echo "$prds" | jq 'length')

  for i in $(seq 0 $((prd_count - 1))); do
    local number title status sub_issues sub_count
    number=$(echo "$prds" | jq -r ".[$i].number")
    title=$(echo "$prds" | jq -r ".[$i].title")

    status="ready"
    if ! are_blockers_closed "$number"; then
      status="blocked"
    elif has_open_pr "$number"; then
      status="has PR"
    fi

    sub_issues=$(get_sub_issues "$number")
    sub_count=$(echo "$sub_issues" | jq 'length' 2>/dev/null || echo "?")

    echo "  #$number: $title"
    echo "         Status: $status | Open stories: $sub_count"
  done
  echo ""
}

# Find next ready PRD
find_next_prd() {
  local prds
  prds=$(find_prd_issues)

  if [ "$(echo "$prds" | jq 'length')" = "0" ]; then
    echo "No open PRD issues found." >&2
    echo "Run /prd-to-github-issues first to create GitHub Issues from a PRD." >&2
    return 1
  fi

  # If user specified a search term, filter by it
  if [ -n "$PRD_SEARCH" ]; then
    local matching
    matching=$(echo "$prds" | jq -r --arg search "$PRD_SEARCH" '[.[] | select(.title | ascii_downcase | contains($search | ascii_downcase))]')

    if [ "$(echo "$matching" | jq 'length')" = "0" ]; then
      echo "No PRD issues matching '$PRD_SEARCH' found." >&2
      return 1
    fi

    prds="$matching"
  fi

  # Find first PRD with no open blockers
  local selected=""
  while read -r prd; do
    local number title
    number=$(echo "$prd" | jq -r '.number')
    title=$(echo "$prd" | jq -r '.title')

    # Check if this PRD has open sub-issues
    local sub_issues sub_count
    sub_issues=$(get_sub_issues "$number")
    sub_count=$(echo "$sub_issues" | jq 'length' 2>/dev/null)

    if [ "$sub_count" = "0" ] || [ "$sub_count" = "null" ] || [ -z "$sub_count" ]; then
      continue  # No open sub-issues, skip
    fi

    # Check blockers (using native GitHub blocking)
    if ! are_blockers_closed "$number"; then
      continue  # Has open blockers, skip
    fi

    # Check if already has an open PR
    if has_open_pr "$number"; then
      continue  # Already has a PR in progress, skip
    fi

    selected="$prd"
    break
  done < <(echo "$prds" | jq -c '.[]')

  if [ -z "$selected" ]; then
    echo "No PRD issues are ready (all are blocked or have no open stories)." >&2
    return 1
  fi

  echo "$selected"
}

# Format all open stories for the agent
format_stories_for_agent() {
  local parent_number="$1"
  local sub_issues
  sub_issues=$(get_sub_issues "$parent_number")

  if [ "$(echo "$sub_issues" | jq 'length')" = "0" ]; then
    return 1
  fi

  # For each sub-issue, fetch the body separately and format
  echo "$sub_issues" | jq -r '.[].number' | while read -r issue_num; do
    local title body
    title=$(echo "$sub_issues" | jq -r ".[] | select(.number == $issue_num) | .title")
    body=$(gh issue view "$issue_num" --json body -q '.body' 2>/dev/null || echo "")
    echo "## Issue #$issue_num: $title"
    echo ""
    echo "$body"
    echo ""
    echo "---"
    echo ""
  done
}

# Main execution
echo "Ralph Issues - GitHub Issues Based Autonomous Loop"
echo "==================================================="
echo ""

# Get available PRDs (no open PRs, not blocked, has open stories)
get_available_prds() {
  local prds
  prds=$(find_prd_issues)
  local available="[]"

  while read -r prd; do
    local number
    number=$(echo "$prd" | jq -r '.number')

    # Skip if blocked
    if ! are_blockers_closed "$number"; then
      continue
    fi

    # Skip if already has PR
    if has_open_pr "$number"; then
      continue
    fi

    # Skip if no open sub-issues
    local sub_count
    sub_count=$(get_sub_issues "$number" | jq 'length' 2>/dev/null)
    if [ "$sub_count" = "0" ] || [ "$sub_count" = "null" ] || [ -z "$sub_count" ]; then
      continue
    fi

    available=$(echo "$available" | jq --argjson prd "$prd" '. + [$prd]')
  done < <(echo "$prds" | jq -c '.[]')

  echo "$available"
}

# Show available PRDs and let user choose
AVAILABLE_PRDS=$(get_available_prds)
AVAILABLE_COUNT=$(echo "$AVAILABLE_PRDS" | jq 'length')

if [ "$AVAILABLE_COUNT" = "0" ]; then
  echo "No PRDs available to work on."
  echo "(All PRDs are either blocked, already have PRs, or have no open stories)"
  exit 0
fi

echo "Available PRDs (no open PRs):"
echo "───────────────────────────────"
for i in $(seq 0 $((AVAILABLE_COUNT - 1))); do
  local_number=$(echo "$AVAILABLE_PRDS" | jq -r ".[$i].number")
  local_title=$(echo "$AVAILABLE_PRDS" | jq -r ".[$i].title")
  local_sub_count=$(get_sub_issues "$local_number" | jq 'length' 2>/dev/null || echo "?")
  echo "  $((i + 1))) #$local_number: $local_title ($local_sub_count stories)"
done
echo ""
echo "  a) All PRDs"
echo ""

# Determine which PRDs to run
if [ -n "$PRD_SEARCH" ]; then
  # Find matching PRD by search term
  SELECTED_PRDS=$(echo "$AVAILABLE_PRDS" | jq -r --arg search "$PRD_SEARCH" '[.[] | select(.title | ascii_downcase | contains($search | ascii_downcase))]')
  if [ "$(echo "$SELECTED_PRDS" | jq 'length')" = "0" ]; then
    echo "No PRDs matching '$PRD_SEARCH' found."
    exit 1
  fi
  echo "Auto-selected PRDs matching '$PRD_SEARCH'"
elif [ "$RUN_ALL" = true ]; then
  # Run all available PRDs
  SELECTED_PRDS="$AVAILABLE_PRDS"
  echo "Running all available PRDs (--all mode)"
else
  # Ask user to choose
  echo "Which PRD(s) to work on? (enter number, 'a' for all, or 'q' to quit)"
  read -r CHOICE

  if [ "$CHOICE" = "q" ]; then
    exit 0
  elif [ "$CHOICE" = "a" ]; then
    SELECTED_PRDS="$AVAILABLE_PRDS"
  elif [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "$AVAILABLE_COUNT" ]; then
    SELECTED_PRDS=$(echo "$AVAILABLE_PRDS" | jq ".[$((CHOICE - 1))]" | jq -s '.')
  else
    echo "Invalid choice."
    exit 1
  fi
fi

SELECTED_COUNT=$(echo "$SELECTED_PRDS" | jq 'length')
echo ""
echo "Selected $SELECTED_COUNT PRD(s) to work on."
echo ""

# Main PRD loop
for prd_idx in $(seq 0 $((SELECTED_COUNT - 1))); do

PRD_JSON=$(echo "$SELECTED_PRDS" | jq ".[$prd_idx]")
PRD_NUMBER=$(echo "$PRD_JSON" | jq -r '.number')
PRD_TITLE=$(echo "$PRD_JSON" | jq -r '.title')
PRD_BODY=$(echo "$PRD_JSON" | jq -r '.body')

# Get or derive branch name
BRANCH_NAME=$(get_branch_name "$PRD_BODY")
if [ -z "$BRANCH_NAME" ]; then
  # Derive from title: Auth Flow -> feature/auth-flow
  FEATURE_NAME=$(echo "$PRD_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  BRANCH_NAME="feature/$FEATURE_NAME"
fi

# Ensure branch name is unique (append -N if exists)
BASE_BRANCH_NAME="$BRANCH_NAME"
COUNTER=2
while git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" || \
      git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; do
  BRANCH_NAME="${BASE_BRANCH_NAME}-${COUNTER}"
  ((COUNTER++))
done

echo "Selected PRD: #$PRD_NUMBER - $PRD_TITLE"
echo "Branch: $BRANCH_NAME"
echo "Max iterations: $MAX_ITERATIONS"
echo ""

# Assign PRD issue to current user to show it's in progress
gh issue edit "$PRD_NUMBER" --add-assignee @me 2>/dev/null || true

# Setup worktree
FEATURE_SLUG=$(echo "$BRANCH_NAME" | sed 's|.*/||')
WORKTREE_PATH="$MAIN_REPO/../$REPO_NAME-$FEATURE_SLUG"

if [ ! -d "$WORKTREE_PATH" ]; then
  echo "Creating worktree at $WORKTREE_PATH..."

  # Create branch if it doesn't exist
  if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    git branch "$BRANCH_NAME" main
  fi

  git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
  echo "Using existing worktree at $WORKTREE_PATH"
fi

cd "$WORKTREE_PATH"

# Initialize local status file (in /tmp to avoid committing)
RALPH_STATUS_FILE="/tmp/ralph-status-${REPO_NAME}-${PRD_NUMBER}.txt"
echo "# Ralph Progress: PRD #$PRD_NUMBER - $PRD_TITLE" > "$RALPH_STATUS_FILE"
echo "# Started: $(date)" >> "$RALPH_STATUS_FILE"
echo "# Branch: $BRANCH_NAME" >> "$RALPH_STATUS_FILE"
echo "---" >> "$RALPH_STATUS_FILE"

# Comment on PRD issue to show work is starting
gh issue comment "$PRD_NUMBER" --body "🤖 Ralph started on branch \`$BRANCH_NAME\`" 2>/dev/null || true

echo ""
echo "Starting Ralph in worktree: $WORKTREE_PATH"
echo "Status file: $RALPH_STATUS_FILE"
echo "============================================="

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "============================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS"
  echo "  PRD: #$PRD_NUMBER"
  echo "============================================="

  # Check if all sub-issues are closed
  if all_sub_issues_closed "$PRD_NUMBER"; then
    echo ""
    echo "============================================="
    echo "  All stories complete for PRD #$PRD_NUMBER!"
    echo "============================================="
    echo ""

    # Push and create PR
    echo "Pushing branch and creating PR..."
    git push -u origin "$BRANCH_NAME" || true

    COMPLETED_STORIES=$(get_closed_sub_issues "$PRD_NUMBER")
    ACCEPTANCE_CRITERIA=$(get_acceptance_criteria "$PRD_NUMBER")

    # Extract overview section from PRD body (between ## Overview and next ##)
    PRD_OVERVIEW=$(echo "$PRD_BODY" | sed -n '/^## Overview/,/^## /p' | sed '1d;$d' | head -15)
    if [ -z "$PRD_OVERVIEW" ]; then
      PRD_OVERVIEW=$(echo "$PRD_BODY" | head -15)
    fi

    PR_BODY=$(cat <<EOF
### What does this PR do?

$PRD_OVERVIEW

### Changes

$COMPLETED_STORIES

### Related issues

Closes #$PRD_NUMBER

### How to test

$ACCEPTANCE_CRITERIA

### Additional notes

Generated by [Ralph Issues](https://github.com/richtabor/agent-skills).
EOF
)

    PR_URL=$(gh pr create --title "$PRD_TITLE" --body "$PR_BODY" 2>&1) || echo "PR may already exist"

    # Clean up worktree now that PR is created
    echo "Cleaning up worktree..."
    cd "$MAIN_REPO"
    git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true

    echo ""
    echo "============================================="
    echo "  PR created: $PR_URL"
    echo "============================================="

    # Continue to next PRD if there are more
    continue 2  # Break out of inner for loop to next PRD
  fi

  # Get all open stories for the agent to choose from
  ALL_STORIES=$(format_stories_for_agent "$PRD_NUMBER") || {
    echo "No open stories found for PRD #$PRD_NUMBER"
    break
  }

  # Get recent Ralph commits for context (learnings from previous iterations)
  RECENT_COMMITS=$(git log --grep="Agent: Ralph" --pretty=format:"---commit---%n%s%n%b" -10 2>/dev/null | head -100 || echo "No commits yet")

  echo "Passing all open stories to agent..."

  # Build prompt with PRD context, recent commits, and stories inline
  PROMPT_CONTENT=$(cat "$SCRIPT_DIR/references/prompt.md")
  FULL_PROMPT="${PROMPT_CONTENT}

---

# PRD #${PRD_NUMBER}: ${PRD_TITLE}

${PRD_BODY}

---

# Recent Commits (context from previous iterations)

${RECENT_COMMITS}

---

# Open Stories

${ALL_STORIES}

---

Pick one story and implement it. Run the quality gates from the PRD above."

  # Run claude with the combined prompt
  OUTPUT=$(claude --dangerously-skip-permissions -p "$FULL_PROMPT" 2>&1 | tee /dev/stderr) || true

  # Check for story completion (look for commit message with "closes #XXX")
  LAST_COMMIT=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
  COMPLETED_ISSUE=$(echo "$LAST_COMMIT" | grep -oE 'closes #[0-9]+' | grep -oE '[0-9]+' || true)

  if [ -n "$COMPLETED_ISSUE" ]; then
    echo "Story #$COMPLETED_ISSUE completed and committed."

    # Push so commit link works (creates branch on remote if first push)
    git push -u origin "$BRANCH_NAME"

    # Close the issue with a comment linking to the commit
    COMMIT_SHA=$(git rev-parse HEAD)
    COMMIT_URL="https://github.com/$REPO_FULL/commit/$COMMIT_SHA"
    gh issue close "$COMPLETED_ISSUE" --comment "Implemented in $COMMIT_URL"

    # Update parent PRD with progress
    STORY_TITLE=$(gh issue view "$COMPLETED_ISSUE" --json title -q '.title' 2>/dev/null || echo "Story #$COMPLETED_ISSUE")
    gh issue comment "$PRD_NUMBER" --body "✅ $STORY_TITLE — $COMMIT_URL" 2>/dev/null || true

    # Update local progress file
    echo "[$(date '+%H:%M')] ✅ #$COMPLETED_ISSUE $STORY_TITLE" >> "$RALPH_STATUS_FILE"
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

# If we get here without completing, we hit max iterations
echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all stories."
echo "PRD: #$PRD_NUMBER"
echo "Worktree: $WORKTREE_PATH"
echo "Check https://github.com/$REPO_FULL/issues/$PRD_NUMBER for progress."
echo ""
echo "Continuing to next PRD..."

done  # End of main PRD loop

echo ""
echo "============================================="
echo "  All selected PRDs complete!"
echo "============================================="
echo ""
echo "<promise>COMPLETE</promise>"
