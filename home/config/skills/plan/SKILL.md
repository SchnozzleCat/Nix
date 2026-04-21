---
name: plan
description: Create an implementation plan from a ticket using the project template. Supports inline ticket info or fetching via CLI integrations (e.g. Linear). Iteratively refines the plan through conversation with the user.
allowed-tools: Bash(linear:*), Bash(git:*), Bash(cat:*), Bash(mkdir:*), Bash(grep:*), Bash(find:*), Read, Edit, Write
---

# Implementation Plan Skill

Create a structured implementation plan for a ticket, using the project's ticket template. The plan is built iteratively through conversation with the user — you **must** ask questions whenever anything is unclear and keep refining until the user is satisfied.

## Template

Every plan must follow this template:

```markdown
# {TICKET-ID}: {TITLE}

## Ticket description

{DESCRIPTION}

## Acceptance Criteria

- [ ] {CRITERION_1}
- [ ] {CRITERION_2}
- [ ] {CRITERION_3}

## What we have

### {REPO_1}

- {CURRENT_STATE_1}
- {CURRENT_STATE_2}
- {CURRENT_STATE_3}

### {REPO_2}

- {CURRENT_STATE_4}
- {CURRENT_STATE_5}
- {CURRENT_STATE_6}

## What we want

### {REPO_1}

- {DESIRED_CHANGE_1}

### {REPO_2}

- {DESIRED_CHANGE_2}

## Work packages

1. **{REPO_1}**: {WORK_PACKAGE_1}
2. **{REPO_2}**: {WORK_PACKAGE_2}
```

Adapt the number of repos, criteria, states, and work packages to fit the ticket — add or remove sections as needed.

## Output

Plans are written to the **current working directory** as `<TICKET-ID>.md`. **After every iteration** where you produce or update a draft, write the file immediately. The filename uses the ticket ID from the ticket source (e.g. `ENG-123`, `PROJ-456`, or a user-provided ID for inline tickets).

## Reading repository code

To fill in "What we have" and produce accurate work packages, you will need to read the relevant code. When you know which repos are involved:

1. Check if the repo exists as a subdirectory of the current working directory.
2. If it does, read the code directly from there.
3. If it does not, ask the user for the clone URL and clone it to `${TMPDIR}/<repo-name>`:

```bash
git clone <URL> "${TMPDIR}/<repo-name>"
```

Then read from `${TMPDIR}/<repo-name>`.

Always explore the codebase to understand the current state before writing the "What we have" section — don't rely solely on the ticket description.

## Workflow

### 1. Gather ticket information

Determine how the user is providing the ticket:

- **Inline**: The user describes the ticket directly in the conversation. Extract the ticket ID, title, and description from what they say. If the ticket ID is ambiguous, **ask the user to specify one**.
- **Via CLI**: The user references a ticket by ID (e.g. "ENG-123"). Use the `linear-cli` skill to fetch ticket details. If the ticket cannot be found, tell the user and ask them to provide the information inline or check the ID.

### 2. Populate the initial draft

Using the template and the gathered ticket information, create an initial draft:

- Fill in `{TICKET-ID}`, `{TITLE}`, and `{DESCRIPTION}` from the ticket.
- For **Acceptance Criteria**: if the ticket contains explicit acceptance criteria, use them. If not, infer reasonable criteria from the description and mark them as draft with a `⚠️ (draft)` suffix so the user knows to review them. **Ask the user** to confirm or revise.
- For **What we have** and **What we want**: if the ticket mentions specific repos or areas, scaffold those sections. If not, **ask the user** which repos/codebases are involved and what the current state is.
- For **Work packages**: propose an initial breakdown. If you're unsure about the granularity or ordering, **ask the user**.

Write the draft to file immediately.

### 3. Iterative refinement (MANDATORY)

This is the core of the skill. You **must not** consider the plan done until the user explicitly confirms it.

After each draft, present a summary to the user and ask targeted questions. Examples:

- "I've drafted 3 acceptance criteria based on the description. Do these cover the full scope, or am I missing anything?"
- "I assumed the changes span `api-server` and `web-client` repos. Is that correct, or are there other repos involved?"
- "For 'What we have', I described the current state based on the ticket. Can you fill in any gaps or correct anything?"
- "I've broken this into 4 work packages. Should any be split further or combined? Is the ordering right?"
- "Are there any dependencies between work packages I should note?"
- "Is there anything about the current codebase that would make this harder than it appears?"

**Rules for the conversation:**

1. **Never assume** — if the ticket description is vague about which repos, what the current state is, or what specific changes are needed, ask.
2. **Ask specific questions**, not "is everything okay?" Point out exactly what you're uncertain about.
3. **Present the current draft** after each round of feedback so the user can see the latest state.
4. **Write to file after every change** — the plan file should always reflect the latest draft.
5. **Continue iterating** until the user says the plan is complete, final, or approved.

### 4. Finalization

When the user confirms the plan is complete:

1. Do one final write to the plan file.
2. Remove any `⚠️ (draft)` markers.
3. Confirm the file path to the user.
4. Optionally suggest next steps (e.g., creating Linear sub-issues from work packages, creating branches).

## Template Fields Reference

| Placeholder          | Source                   | Notes                                |
| -------------------- | ------------------------ | ------------------------------------ |
| `{TICKET-ID}`        | Ticket ID                | e.g. `ENG-123`                       |
| `{TITLE}`            | Ticket title             | From ticket or user                  |
| `{DESCRIPTION}`      | Ticket description       | From ticket or user                  |
| `{CRITERION_N}`      | Acceptance criteria      | Infer from ticket, confirm with user |
| `{REPO_N}`           | Repository names         | **Always ask if not clear**          |
| `{CURRENT_STATE_N}`  | Current state per repo   | **Always ask if not clear**          |
| `{DESIRED_CHANGE_N}` | Desired changes per repo | **Always ask if not clear**          |
| `{WORK_PACKAGE_N}`   | Work packages            | Propose, then refine with user       |

## Example Session

```
User: Create an implementation plan for ENG-456

Agent: Let me fetch that ticket.
[runs: linear issue view ENG-456]
[runs: linear issue describe ENG-456]

Agent: I've created an initial draft for ENG-456 "Add export to CSV feature".
The description mentions exporting data from the dashboard. I have a few questions:

1. Which repos are involved? I'm guessing `web-app` and `api-server` — is that right?
2. The description doesn't specify which data can be exported. Is it all dashboard tables, or specific ones?
3. Should the export respect the current filter/search state of the table?

Draft written to: ENG-456.md

User: Yes, web-app and api-server. It's only for the orders table for now. And yes, it should respect filters.

Agent: Got it. I've updated the draft. A few more questions:

1. For the API, should the CSV be generated server-side and returned as a download, or should the client build the CSV from existing API data?
2. Is there a row limit for exports, or should it handle arbitrarily large datasets?
3. Any specific CSV formatting requirements (delimiter, encoding, date format)?

Draft written to: ENG-456.md

User: Server-side download. No hard row limit but we should stream it. Standard CSV with UTF-8.

Agent: Updated. I've added streaming as a consideration in the work packages. Let me also ask:

1. Should there be a loading/progress indicator on the frontend while the export is running?
2. Does the user need permission to export, or is it available to all authenticated users?

[... continues until user confirms ...]

User: The plan looks good, let's finalize it.

Agent: Final plan written to: ENG-456.md ✅
```

## Handling Edge Cases

- **No ticket ID provided**: Ask the user for one, or offer to use a slug-based ID (e.g., `export-csv`).
- **Ticket not found in CLI**: Tell the user, suggest checking the ID, and offer to proceed inline instead.
- **User provides partial info**: Populate what you can, mark unknowns with `⚠️ (needs input)`, and ask about them explicitly.
- **Multiple tickets**: Handle one ticket at a time. If the user references multiple, ask which one to start with.
- **Large/complex tickets**: Propose a coarser initial breakdown, then drill into each work package with the user individually.
