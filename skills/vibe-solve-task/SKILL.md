---
name: solve-task
description: "Use when the user wants to work on and complete a specific task. Orchestrates the full lifecycle: viability analysis, implementation, code review, and delivery. Requires vibeMCP tools. Handles git operations inline (following git-task-workflow patterns). Uses code-review for review."
---

# Solve Task

Execute a task end-to-end: analyze, implement, review, and deliver.

## Prerequisites

- vibeMCP server with tools: `list_tasks`, `read_doc`, `tool_update_task_status`, `tool_update_task`, `tool_create_doc`, `get_plan`
- Skill available: `code-review` (for code review via subagent)
- Git repository with a remote
- `gh` CLI authenticated

If vibeMCP is not connected, inform the user and stop.
If `gh` is not authenticated, prompt `gh auth login` and stop.

## Setup

1. Find the workspace: look for `vibe: <project>` in CLAUDE.md
2. Find the base branch: look for `branch: <n>` in CLAUDE.md (default: `main`)

## Process

### 1. Preflight Checks

Verify the working directory is clean:
```bash
git status --porcelain
```
If there are uncommitted changes → inform the user and stop. Do not stash or discard.

### 2. Select Task

**If task number provided** (e.g., "solve-task 003"):
```
list_tasks(project)
```
Find the task whose filename starts with `003-`. Then:
```
read_doc(project, "tasks", <matched_filename>)
```

**If no number provided:**
```
list_tasks(project, status="in-progress")
```
- If found → use first in-progress task
- If none → `list_tasks(project, status="pending")` → use first pending
- If nothing → inform user, no tasks available, stop

### 3. Check Dependencies

```
get_plan(project)
```

If an execution plan exists, check whether this task has `blockedBy` dependencies that are not yet `done`.

If blocked → list what's blocking and stop:
```
Task 003 is blocked by:
- 001-setup-db (status: pending)

Complete the blocking tasks first, or use run-plan to execute in order.
```

### 4. Read & Understand

```
read_doc(project, "tasks", <task_file>)
```

Parse and retain:
- **objective**: what the task accomplishes
- **steps**: ordered list of actions
- **context**: related files
- **acceptance criteria**: how to verify success (if present)

### 5. Viability Analysis

Before writing any code:

**Always do:**
- Verify all files mentioned in Context exist
- Check that imports/dependencies referenced in steps are available

**For tasks with 3+ steps, also:**
- Read the related files to understand current state
- Assess if steps are achievable given the codebase
- Identify risks or unknowns

**Outcomes:**
- **Viable** → continue
- **Viable with adjustments** → update the task and inform:
  ```
  tool_update_task(project, <task_file>, steps=[<adjusted_steps>])
  ```
  Tell the user what changed and why.
- **Not viable** → explain why and stop. Do not mark as blocked automatically — let the user decide.

### 6. Mark In-Progress

```
tool_update_task_status(project, <task_file>, "in-progress")
```

### 7. Create Branch

```bash
git checkout <base_branch>
git pull
git checkout -b task/<NNN>-<task-name>
```

### 8. Implement

Follow the steps from the task file:
- Read files before modifying them
- Small, focused changes — one step at a time
- Do not add functionality beyond what the task describes

### 9. Run Tests

Detect and run the project's test suite:

| Indicator | Command |
|---|---|
| `Package.swift` | `swift test` |
| `pyproject.toml` with pytest | `uv run pytest` or `pytest` |
| `package.json` with `"test"` script | `npm test` |
| `Makefile` with `test` target | `make test` |

If no test suite is detected, skip this step.

**If tests fail** → fix and rerun. This counts as **attempt 1**.

### 10. Code Review (mandatory)

Use the `code-review` skill with:
- **base_branch**: from setup
- **task_objective**: the objective parsed in step 4

```bash
git diff <base_branch>..HEAD
```

**If PASS** → go to step 12.
**If ISSUES** → go to step 11.

### 11. Fix & Retest

Apply fixes from the review, then run tests again.

**Attempt tracking:**
- Each cycle of "fix → test → review" counts as one attempt
- Step 9 was attempt 1
- **Maximum 3 attempts total** (steps 9 through 11)

If still failing after 3 attempts:
- Stop
- Leave the branch intact for manual intervention
- Inform the user with the specific failures

After a successful cycle → go to step 12.

### 12. Deliver

```bash
git add -A
git commit -m "$(cat <<'EOF'
<task title>

<summary of changes>

Task: <NNN>-<task-name>
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

git push -u origin task/<NNN>-<task-name>

gh pr create \
    --base <base_branch> \
    --title "<task title>" \
    --body "$(cat <<'EOF'
## Summary
<summary of changes>

## Task
<NNN>-<task-name>
EOF
)"

gh pr merge --squash --delete-branch

git checkout <base_branch>
git pull
```

Capture the PR URL from `gh pr create` output for use in step 13.

**On merge conflict** → stop, show conflicting files, inform user. Do not auto-resolve.
**On PR checks fail** → stop, show status, inform user.

### 13. Log & Complete

```
tool_create_doc(
    project=<project>,
    folder="changelog",
    filename="<NNN>-<task-name>",
    content="# <task title>\n\nDate: <YYYY-MM-DD>\nPR: <pr_url>\n\n## Changes\n- <what changed>\n\n## Files Affected\n- <key files>"
)

tool_update_task_status(project, <task_file>, "done")
```

If the project has a root `CHANGELOG.md`, also append the entry there following Keep a Changelog format.

## Error Handling

| Error | Action |
|-------|--------|
| Dirty working directory | Stop, inform user |
| Task not found | Stop, list available tasks |
| Task has unmet dependencies | Show blockers, stop |
| Viability check fails | Explain why, stop |
| Tests fail (3 attempts) | Log details, leave branch, inform user |
| Code review fails (3 attempts) | Log issues, leave branch, inform user |
| Merge conflict | Show files, stop — do not auto-resolve |
| PR checks fail | Show status, stop |
| `gh` not authenticated | Prompt `gh auth login`, stop |

## Key Principles

- **Git operations are inline** — this skill executes git commands directly, following the patterns from git-task-workflow. It does not invoke git-task-workflow as a separate skill.
- **Delegate review to code-review** — don't inline review logic, always use the skill with `task_objective`
- **Always use MCP tools for task state** — never edit task files directly with Read/Write
- **3 attempts max** — each fix→test→review cycle is one attempt. Surface the problem, don't loop forever
- **Log everything** — changelog for every completed task, failure details for every failed task
- **Check before acting** — dependencies, viability, clean working directory
- **YAGNI** — implement only what the task describes, nothing more
