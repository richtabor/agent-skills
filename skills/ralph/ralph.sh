#!/bin/bash
# Ralph - Autonomous agent loop with git worktrees
# Usage: ./ralph.sh [max_iterations] [project-name]

set -e

# Parse arguments
MAX_ITERATIONS=10
PROJECT_NAME=""

for arg in "$@"; do
  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$arg
  else
    PROJECT_NAME=$arg
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_REPO="$(git rev-parse --show-toplevel)"
REPO_NAME="$(basename "$MAIN_REPO")"
PRDS_DIR="$MAIN_REPO/prds"

# Check if a project is complete (all stories pass)
is_project_complete() {
  local json_file="$1"
  # Returns 0 (true) if no incomplete stories, 1 (false) if incomplete stories exist
  if jq -e '.userStories[] | select(.passes == false)' "$json_file" > /dev/null 2>&1; then
    return 1  # Has incomplete stories
  else
    return 0  # All complete
  fi
}

# Check if all dependencies of a project are complete
are_dependencies_complete() {
  local json_file="$1"
  local deps
  deps=$(jq -r '.dependsOn // [] | .[]' "$json_file" 2>/dev/null)

  if [ -z "$deps" ]; then
    return 0  # No dependencies, good to go
  fi

  for dep in $deps; do
    local dep_file="$PRDS_DIR/$dep.json"
    if [ ! -f "$dep_file" ]; then
      echo "Warning: Dependency $dep not found" >&2
      return 1
    fi
    if ! is_project_complete "$dep_file"; then
      return 1  # Dependency is not complete
    fi
  done

  return 0  # All dependencies complete
}

# Find all ready projects (not just first)
find_ready_projects() {
  local ready=()
  for json_file in "$PRDS_DIR"/*.json; do
    [ -f "$json_file" ] || continue

    # Skip if done or complete
    if jq -e '.status == "done"' "$json_file" > /dev/null 2>&1; then
      continue
    fi
    if is_project_complete "$json_file"; then
      continue
    fi

    # Skip if dependencies not met
    if ! are_dependencies_complete "$json_file"; then
      continue
    fi

    ready+=("$(basename "$json_file" .json)")
  done

  printf '%s\n' "${ready[@]}"
}

# Find next project to work on (respects dependencies)
find_next_project() {
  if [ -n "$PROJECT_NAME" ]; then
    # User specified a project
    if [ -f "$PRDS_DIR/$PROJECT_NAME.json" ]; then
      local json_file="$PRDS_DIR/$PROJECT_NAME.json"

      # Check if it has incomplete stories
      if is_project_complete "$json_file"; then
        echo "Project $PROJECT_NAME is already complete" >&2
        return 1
      fi

      # Check if dependencies are complete
      if ! are_dependencies_complete "$json_file"; then
        echo "Error: Project $PROJECT_NAME has incomplete dependencies:" >&2
        jq -r '.dependsOn // [] | .[]' "$json_file" | while read -r dep; do
          local dep_file="$PRDS_DIR/$dep.json"
          if [ -f "$dep_file" ] && ! is_project_complete "$dep_file"; then
            echo "  - $dep (incomplete)" >&2
          fi
        done
        return 1
      fi

      echo "$PROJECT_NAME"
      return 0
    else
      echo "Error: Project $PROJECT_NAME.json not found in prds/" >&2
      return 1
    fi
  fi

  # Get all ready projects
  readarray -t ready_projects < <(find_ready_projects)

  if [ ${#ready_projects[@]} -eq 0 ]; then
    # Check if there are blocked projects
    local blocked=0
    for json_file in $(ls "$PRDS_DIR"/*.json 2>/dev/null | sort); do
      [ -f "$json_file" ] || continue
      if ! is_project_complete "$json_file" && ! are_dependencies_complete "$json_file"; then
        if [ $blocked -eq 0 ]; then
          echo "No projects ready. Blocked projects:" >&2
          blocked=1
        fi
        local name=$(basename "$json_file" .json)
        echo "  - $name (waiting on dependencies)" >&2
      fi
    done

    if [ $blocked -eq 0 ]; then
      echo "No incomplete projects found in prds/" >&2
    fi
    return 1
  elif [ ${#ready_projects[@]} -eq 1 ]; then
    echo "${ready_projects[0]}"
    return 0
  else
    # Multiple ready - let Claude pick
    project_info=""
    for proj in "${ready_projects[@]}"; do
      desc=$(jq -r '.description // .projectName' "$PRDS_DIR/$proj.json")
      project_info+="- $proj: $desc"$'\n'
    done

    choice=$(claude -p "Pick ONE project to work on next. Reply with just the project name, nothing else.

Ready projects:
$project_info" 2>/dev/null | tr -d '[:space:]')

    # Validate choice is in ready list
    for proj in "${ready_projects[@]}"; do
      if [ "$proj" = "$choice" ]; then
        echo "$choice"
        return 0
      fi
    done

    # Fallback to first if invalid response
    echo "${ready_projects[0]}"
    return 0
  fi
}

# Show dependency graph
show_dependency_graph() {
  echo "Dependency Graph:"
  echo "─────────────────"
  for json_file in $(ls "$PRDS_DIR"/*.json 2>/dev/null | sort); do
    [ -f "$json_file" ] || continue
    local name=$(basename "$json_file" .json)
    local deps=$(jq -r '.dependsOn // [] | join(", ")' "$json_file")
    local status="pending"

    if is_project_complete "$json_file"; then
      status="✓ complete"
    elif are_dependencies_complete "$json_file"; then
      status="ready"
    else
      status="blocked"
    fi

    if [ -n "$deps" ]; then
      echo "  $name [$status] → depends on: $deps"
    else
      echo "  $name [$status] → (no dependencies)"
    fi
  done
  echo ""
}

# Check prds directory exists
if [ ! -d "$PRDS_DIR" ]; then
  echo "Error: prds/ directory not found"
  echo "Run /create-prd and /create-prd-json first"
  exit 1
fi

# Show dependency graph
show_dependency_graph

# Find project to work on
PROJECT=$(find_next_project) || exit 1
PRD_FILE="$PRDS_DIR/$PROJECT.json"
BRANCH_NAME=$(jq -r '.branchName' "$PRD_FILE")

echo "Project: $PROJECT"
echo "Branch: $BRANCH_NAME"
echo "Max iterations: $MAX_ITERATIONS"

# Setup worktree
WORKTREE_PATH="$MAIN_REPO/../$REPO_NAME-$PROJECT"

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

# Copy PRD to worktree (as prd.json for the agent to find)
cp "$PRD_FILE" "$WORKTREE_PATH/prd.json"

# Set status to in_progress
jq '.status = "in_progress"' "$WORKTREE_PATH/prd.json" > "$WORKTREE_PATH/prd.json.tmp" && mv "$WORKTREE_PATH/prd.json.tmp" "$WORKTREE_PATH/prd.json"
cp "$WORKTREE_PATH/prd.json" "$PRD_FILE"

# Use progress file in worktree (each project has its own)
WORKTREE_PROGRESS="$WORKTREE_PATH/.ralph-progress.txt"
if [ ! -f "$WORKTREE_PROGRESS" ]; then
  echo "# Ralph Progress Log" > "$WORKTREE_PROGRESS"
  echo "Started: $(date)" >> "$WORKTREE_PROGRESS"
  echo "Project: $PROJECT" >> "$WORKTREE_PROGRESS"
  echo "Branch: $BRANCH_NAME" >> "$WORKTREE_PROGRESS"
  echo "---" >> "$WORKTREE_PROGRESS"
fi

# Main loop - keeps going until all PRDs are complete
while true; do
  echo ""
  echo "Starting Ralph in worktree: $WORKTREE_PATH"
  echo "═══════════════════════════════════════════════════════"

  cd "$WORKTREE_PATH"

  for i in $(seq 1 $MAX_ITERATIONS); do
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Ralph Iteration $i of $MAX_ITERATIONS"
    echo "  Project: $PROJECT"
    echo "═══════════════════════════════════════════════════════"

    # Run claude with the ralph prompt
    OUTPUT=$(claude --dangerously-skip-permissions -p "$(cat "$SCRIPT_DIR/references/prompt.md")" 2>&1 | tee /dev/stderr) || true

    # Sync prd.json back to main repo
    if [ -f "$WORKTREE_PATH/prd.json" ]; then
      cp "$WORKTREE_PATH/prd.json" "$PRD_FILE"
    fi

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
      echo ""
      echo "═══════════════════════════════════════════════════════"
      echo "  Ralph completed all tasks for $PROJECT!"
      echo "  Completed at iteration $i of $MAX_ITERATIONS"
      echo "═══════════════════════════════════════════════════════"
      echo ""

      # Push and create PR
      echo "Pushing branch and creating PR..."
      git push -u origin "$BRANCH_NAME"

      # Generate PR body from PRD
      PR_TITLE=$(jq -r '.title // .projectName' "$WORKTREE_PATH/prd.json")
      PR_BODY=$(cat <<EOF
## Summary
$(jq -r '.description // "Automated implementation by Ralph."' "$WORKTREE_PATH/prd.json")

## Stories Completed
$(jq -r '.userStories[] | "- [x] \(.title)"' "$WORKTREE_PATH/prd.json")

---
🤖 Generated by Ralph
EOF
)

      gh pr create --title "$PR_TITLE" --body "$PR_BODY" || echo "PR may already exist"

      echo ""
      break  # Exit inner loop, continue to next PRD
    fi

    echo "Iteration $i complete. Continuing..."
    sleep 2
  done

  # Check if we hit max iterations without completing
  if ! echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing."
    echo "Project: $PROJECT"
    echo "Worktree: $WORKTREE_PATH"
    echo "Check $WORKTREE_PATH/.ralph-progress.txt for status."
    exit 1
  fi

  # Go back to main repo to find next project
  cd "$MAIN_REPO"

  echo ""
  echo "Looking for next PRD..."
  echo ""

  # Show updated dependency graph
  show_dependency_graph

  # Find next project
  PROJECT=$(find_next_project) || {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  All PRDs complete! 🎉"
    echo "═══════════════════════════════════════════════════════"
    exit 0
  }

  # Setup for next project
  PRD_FILE="$PRDS_DIR/$PROJECT.json"
  BRANCH_NAME=$(jq -r '.branchName' "$PRD_FILE")

  echo "Next project: $PROJECT"
  echo "Branch: $BRANCH_NAME"

  # Setup worktree for next project
  WORKTREE_PATH="$MAIN_REPO/../$REPO_NAME-$PROJECT"

  if [ ! -d "$WORKTREE_PATH" ]; then
    echo "Creating worktree at $WORKTREE_PATH..."

    if ! git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      git branch "$BRANCH_NAME" main
    fi

    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
  else
    echo "Using existing worktree at $WORKTREE_PATH"
  fi

  # Copy PRD to worktree
  cp "$PRD_FILE" "$WORKTREE_PATH/prd.json"

  # Set status to in_progress
  jq '.status = "in_progress"' "$WORKTREE_PATH/prd.json" > "$WORKTREE_PATH/prd.json.tmp" && mv "$WORKTREE_PATH/prd.json.tmp" "$WORKTREE_PATH/prd.json"
  cp "$WORKTREE_PATH/prd.json" "$PRD_FILE"

  # Initialize progress file if needed
  WORKTREE_PROGRESS="$WORKTREE_PATH/.ralph-progress.txt"
  if [ ! -f "$WORKTREE_PROGRESS" ]; then
    echo "# Ralph Progress Log" > "$WORKTREE_PROGRESS"
    echo "Started: $(date)" >> "$WORKTREE_PROGRESS"
    echo "Project: $PROJECT" >> "$WORKTREE_PROGRESS"
    echo "Branch: $BRANCH_NAME" >> "$WORKTREE_PROGRESS"
    echo "---" >> "$WORKTREE_PROGRESS"
  fi

  sleep 2
done
