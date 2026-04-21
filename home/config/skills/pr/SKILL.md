---
name: pr
description: Create a pull request from the current branch's changes against origin main/master. Supports both jujutsu and git workflows. Uses gh CLI to create the PR.
allowed-tools: Bash(jj:*), Bash(git:*), Bash(gh:*), Bash(cat:*), Bash(grep:*), Read, Grep, Glob
---

# Create Pull Request Skill

Create a GitHub pull request from the current branch's changes against the base branch (main or master). Works with both jujutsu and git version control.

## Inputs

The user may optionally provide:

- **A title** for the PR
- **A description or context** about the changes
- **A base branch** (defaults to detecting `main` or `master`)
- **Additional gh flags** (e.g. `--draft`, `--reviewer`, `--label`)

## Workflow

### 1. Detect version control system

Check which VCS is in use:

```bash
jj root 2>/dev/null
```

If this succeeds, use the **jujutsu** workflow. Otherwise, use the **git** workflow.

### 2. Determine base branch

Find the remote base branch by checking (in order):

1. User-specified base branch, if provided.
2. `main` on the remote (`origin/main` or equivalent).
3. `master` on the remote (`origin/master` or equivalent).

If neither exists, ask the user.

### 3. Gather changes

#### Jujutsu workflow

```bash
# Get the current bookmark (branch) name
jj bookmark list --mine

# Get the log of changes not on the base branch
jj log -r "ancestors(@ | bookmarks()) ~ ancestors(remote_bookmarks())"

# Get the full diff against the base
jj diff -r "ancestors(@ | bookmarks()) ~ ancestors(remote_bookmarks())"
```

If there is no bookmark pointing at or near the current change, ask the user to create one or offer to create one:

```bash
jj bookmark create <name> -r @
```

Push the bookmark to the remote:

```bash
jj git push --bookmark <name>
```

#### Git workflow

```bash
# Get the current branch name
git branch --show-current

# Get the log of commits against the base
git log --oneline <base>..HEAD

# Get the full diff against the base
git diff <base>...HEAD
```

If on a detached HEAD or `main`/`master` directly, ask the user to create a branch first.

Push the branch to the remote:

```bash
git push -u origin HEAD
```

### 4. Analyze changes and draft PR

Review the diff and commit log to understand the changes. Draft a PR title and body:

- **Title**: concise summary under 70 characters. Use the user-provided title if given.
- **Body**: structured summary of the changes using this format:

```markdown
## Summary

- <bullet points describing key changes>

## Test plan

- [ ] <how to verify the changes>
```

If the user provided context or a description, incorporate it into the summary.

### 5. Create the PR

Use `gh` to create the pull request:

```bash
gh pr create --title "<title>" --base <base-branch> --body "$(cat <<'EOF'
## Summary

- <changes>

## Test plan

- [ ] <verification steps>
EOF
)"
```

Pass through any additional flags the user specified (e.g. `--draft`, `--reviewer someone`, `--label bug`).

### 6. Report result

Show the user:

- The PR URL
- The title and base branch
- A brief summary of what was included

## Edge Cases

- **No changes**: If the diff is empty, tell the user there are nothing to open a PR for.
- **No remote branch**: Push the branch/bookmark before creating the PR.
- **PR already exists**: If `gh pr create` fails because a PR already exists, run `gh pr view --web` to show the existing one and ask the user if they want to update it.
- **Jujutsu with no bookmark**: Offer to create a bookmark from the current change description or ask the user for a name.
- **Dirty working tree (git)**: Warn the user about uncommitted changes that won't be included in the PR.
- **Fork-based workflow**: If `gh` detects a fork, let it handle the remote selection automatically.

## Example Session

```
User: /pr

Agent: Detected jujutsu repository.
Base branch: main

Changes (3 commits):
- feat: add firewall module for pi-sandbox
- feat: add pi-sandbox container image build
- chore: update flake inputs

Pushing bookmark `pi-sandbox` to origin...

Creating PR...

✅ PR created: https://github.com/user/repo/pull/42
  Title: feat: add pi-sandbox with firewall and container image
  Base: main ← pi-sandbox
```

```
User: /pr --draft --title "WIP: new auth flow"

Agent: Detected git repository on branch `feature/new-auth`.
Base branch: main

Changes (2 commits):
- feat: add OAuth2 provider integration
- feat: add login redirect handling

Pushing branch to origin...

Creating draft PR with title "WIP: new auth flow"...

✅ Draft PR created: https://github.com/user/repo/pull/43
  Title: WIP: new auth flow
  Base: main ← feature/new-auth
```
