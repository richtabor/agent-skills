# Issue Writing Guide

Based on [Linear's method](https://linear.app/method/write-issues-not-user-stories): write issues, not user stories.

## Rules

1. **No user stories** — Skip "As a user, I want..." entirely
2. **Title = the task** — Short, direct, imperative ("Add login form", not "User authentication feature")
3. **Concrete deliverables** — Every issue produces code, design, or a document
4. **Write only what's needed** — Context for completion, nothing more
5. **Quote, don't summarize** — Include actual user feedback if relevant

## Issue Format

```markdown
**Files:** `path/to/file.tsx`

**Acceptance Criteria:**
- [ ] Specific change
- [ ] Typecheck passes
- [ ] Lint passes

**Notes:**
Context if needed. Quote user feedback directly.
```

**No description field.** Title is the description.

## Sizing

### Right-sized (one commit)

- Add a database column
- Create a single UI component
- Add one API endpoint
- Add form validation

### Too large (split)

```
BAD:  "Build auth system"
GOOD: "Add login form"
      "Add email validation"
      "Add auth server action"
```

## Acceptance Criteria

### Good

```
- Email/password fields present
- Validates email format on blur
- Error message appears below field
- Typecheck passes
- Lint passes
```

### Bad

```
- Users can log in (vague)
- Works correctly (vague)
- Good UX (subjective)
```

## What Ralph Handles

### Good fit

- CRUD endpoints
- Pattern migrations
- Test coverage
- UI wiring
- Schema changes

### Not for Ralph

- Fuzzy requirements
- Architectural decisions
- Security-sensitive code
- Performance without metrics
