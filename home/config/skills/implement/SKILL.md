---
name: implement
description: Implement a feature from a Linear ticket or inline description. Fetches the plan, implements it, lints, tests, and commits with jujutsu.
allowed-tools: Bash(linear:*), Bash(git:*), Bash(jj:*), Bash(nix:*), Bash(cat:*), Bash(mkdir:*), Bash(grep:*), Bash(find:*), Bash(ls:*), Bash(rm:*), Bash(cp:*), Bash(mv:*), Read, Edit, Write, Glob, Grep, Agent
---

# Implement Feature Skill

Implement a feature end-to-end from a Linear ticket or an inline description. The agent gathers the plan, implements it in code, and commits meaningful checkpoints using jujutsu.

## Inputs

The user provides one of:

- **A Linear ticket identifier** (e.g. `ENG-123`): the agent fetches the ticket details and any linked implementation plan.
- **An inline feature description**: the user describes what to build directly.

## Workflow

### 1. Gather the plan

#### From Linear

Capture the title, description, acceptance criteria, and any linked sub-issues.

#### Inline

The user describes the feature directly. Extract the intent, scope, and any constraints from their message.

### 2. Assess readiness

Before writing any code, verify you have enough information to start. You need at minimum:

- **What** the feature does (clear behavior or outcome)
- **Where** in the codebase it lives (which files/modules to touch)

If either is missing, **ask the user** — but only for truly critical gaps. Do not ask about:

- Code style (follow existing conventions)
- Minor implementation details you can decide yourself
- Things you can determine by reading the code

Explore the codebase to understand the current state before implementing. Read the relevant files to understand existing patterns and conventions.

### 3. Implement

Work through the feature incrementally. Follow existing code conventions — match the style, patterns, and structure of surrounding code.

**Guidelines:**

- Make the smallest changes needed to achieve the goal.
- Do not refactor unrelated code.
- Do not add speculative features or over-engineer.
- If the plan has work packages, follow them in order.
- If you encounter an ambiguity that blocks progress, ask the user. Otherwise, make a reasonable choice and keep going.

### 4. Checkpoint: lint, test, commit

After completing a meaningful unit of work (a work package, a logical feature slice, or the full implementation), run the checkpoint sequence:

#### a. Lint

Determine the repo's lint/format command by checking (in order):

1. **AGENT.md** — may specify the exact command.
2. **Common config files** — detect the toolchain from what's present:
   - `package.json` (with `lint` script) → `npm run lint` or equivalent
   - `pyproject.toml` / `ruff.toml` → `ruff check --fix . && ruff format .`
   - `Makefile` (with `lint` target) → `make lint`
   - `.eslintrc*` → `npx eslint --fix .`
   - `Cargo.toml` → `cargo fmt && cargo clippy`
   - `go.mod` → `gofmt -w . && go vet ./...`
3. **Fallback** — if nothing is detected, skip linting.

If formatting produces changes, review them briefly to make sure nothing unexpected happened, then include them in the commit.

#### b. Test

Determine the repo's test command by checking (in order):

1. **AGENT.md / CLAUDE.md** — may specify the exact command.
2. **Common config files** — detect from what's present:
   - `package.json` (with `test` script) → `npm test`
   - `pyproject.toml` / `pytest.ini` → `pytest`
   - `Makefile` (with `test` target) → `make test`
   - `Cargo.toml` → `cargo test`
   - `go.mod` → `go test ./...`
3. **Fallback** — if no test runner is detected, skip testing.

If specific tests exist for the changed area, prefer running those over the full suite. If tests fail, fix the issue before committing.

#### c. Commit with jujutsu

Describe the change and create a new nameless jj change:

```bash
jj describe -m "<description of what was accomplished>"
jj new
```

The description should be a concise summary of what was done in this checkpoint, written in imperative mood (e.g. "add firewall module for pi-sandbox", not "added firewall module").

**Commit message conventions:**

- Use conventional-commit-style prefixes: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`
- Keep the first line under 72 characters
- Add a blank line and body paragraph if the change warrants explanation

### 5. Repeat or finish

If there are more work packages or implementation steps, go back to step 3. Each significant slice gets its own checkpoint.

When the full feature is implemented:

1. Do a final lint + test pass.
2. Commit any remaining changes.
3. Summarize what was done to the user, listing the changes created.

## Edge Cases

- **Ticket not found**: Tell the user, suggest checking the ID, offer to proceed with inline info.
- **Lint fails on unrelated code**: Only fix lint issues in files you touched. Note unrelated lint failures to the user.
- **Tests fail on unrelated code**: Note the failure to the user and proceed with committing your changes if they are not the cause.
- **Large feature**: Break into multiple checkpoints naturally. Each checkpoint should leave the codebase in a buildable state.
- **Lint/test tool not found**: If the detected command isn't installed or fails to run, proceed without that step.

## Example Session

```
User: /implement-feature ENG-456

Agent: Let me fetch that ticket.
[runs: linear issue view ENG-456]

Found: "Add export to CSV feature"

The plan has 3 work packages:
1. API: Add streaming CSV endpoint
2. Web: Add export button to orders table
3. Web: Wire up download with progress indicator

Starting with feature slice...

[reads relevant API code]
[implements the CSV endpoint]
[runs: npm run lint]
[runs: nix run test]
[runs: jj describe -m "feat: add streaming CSV export endpoint for orders"]
[runs: jj new]

Slice implemented.

All done. Created 3 jj changes:
- feat: add streaming CSV export endpoint for orders
- feat: add export button to orders table UI
- feat: wire up CSV download with progress indicator
- test: added tests for streaming CSV export
```
