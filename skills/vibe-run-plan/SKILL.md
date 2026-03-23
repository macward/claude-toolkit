---
name: run-plan
description: "Use when the user wants to execute all pending tasks in sequence. Default is autonomous (runs all without pausing). If the user asks to confirm, review, or go step-by-step, pause between tasks for approval. Delegates each task to solve-task."
---

# Run Plan

Orchestrate the execution of all pending tasks in sequence, delegating each one to `solve-task`.

## Prerequisites

- vibeMCP server with tools: `list_tasks`, `read_doc`, `get_plan`, `tool_create_plan`
- Skill available: `solve-task`
- Git repository with a remote
- `gh` CLI authenticated

If vibeMCP is not connected, inform the user and stop.
If `gh` is not authenticated, prompt `gh auth login` and stop.

## Responsibility Boundary

run-plan handles **orchestration only**:
- What tasks to execute and in what order
- What to do when a task succeeds, fails, or is skipped
- Inter-task cleanup and state verification
- Progress logging

run-plan does **not** handle task execution. Each task is fully delegated to `solve-task`, which owns the entire lifecycle (preflight, viability, implementation, review, delivery).

## Parameters

- **feature** (optional): Execute only tasks for a specific feature. When specified:
  - Loads feature plan from `feature-<feature>.md` instead of master plan
  - Filters tasks by `feature` field

## Setup

1. Find the workspace: look for `vibe: <project>` in CLAUDE.md
2. Find the base branch: look for `branch: <n>` in CLAUDE.md (default: `main`)
3. Determine mode from user's request:
   - **Autonomous** (default): "run the plan", "execute all tasks"
   - **Confirm**: "run the plan step by step", "run with confirmation", "one at a time"
4. Check for feature scope:
   - "run feature auth", "execute auth plan" → feature="auth"
   - No feature mentioned → run master plan

## Process

### 1. Preflight

Verify environment before starting the loop:

```bash
git status --porcelain
gh auth status
```

If working directory is dirty → inform the user and stop.
If `gh` is not authenticated → prompt `gh auth login` and stop.

### 2. Gather Context

**If feature specified:**
```
get_plan(project, filename="feature-<feature>.md")
list_tasks(project, status="pending", feature=<feature>)
list_tasks(project, status="in-progress", feature=<feature>)
```

**Otherwise (master plan):**
```
get_plan(project)
list_tasks(project, status="pending")
list_tasks(project, status="in-progress")
```

If no pending or in-progress tasks → inform user and stop.

### 3. Build Execution Queue

From the execution plan, parse the dependency table (`Blocked By` column) and build an ordered queue:

- Skip tasks already `done`
- Put `in-progress` tasks first (resuming a previous run)
- Respect `Blocked By` dependencies — a task enters the queue only when all its blockers are `done`
- If no plan exists, use task number order (001, 002, 003...)

If all remaining tasks are blocked → show what's blocking each and stop.

### 4. Read Task Summaries

For confirm mode, read the objective of each queued task:
```
read_doc(project, "tasks", <filename>)
```

In autonomous mode this step is optional — solve-task will read the task itself.

### 5. Announce

Show the full queue to the user:
```
run-plan started (N tasks)
Mode: autonomous | confirm

Queue:
  1. 001-setup-db
  2. 002-auth-service (depends on 001)
  3. 005-api-endpoints
  4. 003-user-model (depends on 001)
  5. 004-integration-tests (depends on 002, 003)
```

### 6. Execute Loop

For each task in the queue:

#### 6a. Pre-task: Confirm mode prompt

**If confirm mode** — present and ask before each task:
```
[2/N] Next: <NNN>-<task-name>
Objective: <objective from step 4>

Continue? [Y / skip / abort]
```
- **Y** → proceed to 6b
- **skip** → record as skipped, go to 6d
- **abort** → go to step 8 (Completion) with partial results

#### 6b. Pre-task: Verify clean state

Before delegating to solve-task, verify the working directory is ready:

```bash
git status --porcelain
```

If dirty (e.g., leftover from a failed task):
```bash
git checkout <base_branch>
git clean -fd
git checkout <base_branch>
git pull
```

If a branch `task/<NNN>-<task-name>` already exists from a previous failed attempt:
```bash
git branch -D task/<NNN>-<task-name>
git push origin --delete task/<NNN>-<task-name> 2>/dev/null
```

This ensures solve-task always starts from clean state.

#### 6c. Execute task

Delegate to `solve-task`:
```
Execute solve-task for task <NNN>
```

solve-task will run its full process (preflight, dependency check, viability, implementation, review, delivery). run-plan does not interfere with any of those steps.

**If solve-task completes successfully:**
```
[2/N] <NNN>-<task-name> ── done ✓
```

**If solve-task fails** → go to step 7 (Handle Failures).

#### 6d. Post-task: Re-evaluate queue

Re-check dependencies before the next task:
- Completing a task may unblock others → add newly unblocked tasks to the queue
- A skipped task may block downstream tasks → handle in 6e

#### 6e. Skip propagation

If a task was skipped (confirm mode), check if any queued tasks depend on it.

For each blocked downstream task, inform the user:
```
[4/N] 004-integration-tests ── BLOCKED (depends on 002-auth-service, which was skipped)
Auto-skipping.
```

Record as skipped with reason. Do not ask — if the dependency was skipped, the dependent cannot run.

### 7. Handle Failures

**Autonomous mode**: stop the entire run immediately.
```
[3/N] <NNN>-<task-name> ── FAILED ✗
Reason: <what solve-task reported>

run-plan stopped. Completed N/M tasks.
```

**Confirm mode**: give the user options:
```
[3/N] <NNN>-<task-name> ── FAILED ✗
Reason: <what solve-task reported>

Options:
- retry — clean up and re-run this task from scratch
- skip — mark as skipped, continue to next
- abort — stop the entire run
```

**On retry**: step 6b will clean up the failed branch before re-delegating to solve-task.

**On skip**: record as skipped, check skip propagation (6e), continue.

### 8. Completion

Show final summary:
```
run-plan completed

✓ 001-setup-db           PR #12
✓ 002-auth-service       PR #13
✗ 003-user-model         FAILED (tests)
⊘ 004-integration-tests  skipped (depends on 003)
✓ 005-api-endpoints      PR #14

3/5 completed, 1 failed, 1 skipped
```

Update the execution plan status section:
```
tool_create_plan(
    project,
    content=<updated plan with Current Status reflecting actual results>,
    filename=<same plan filename>
)
```

## Error Handling

| Error | Action |
|-------|--------|
| Dirty working directory (preflight) | Stop before starting |
| `gh` not authenticated | Prompt `gh auth login`, stop |
| No pending tasks | Inform user, stop |
| All tasks blocked | Show blockers, stop |
| solve-task fails (autonomous) | Stop entire run, log, inform |
| solve-task fails (confirm) | Offer retry/skip/abort |
| solve-task stops for viability | Treated as failure — same handling |
| Skipped task blocks downstream | Auto-skip downstream, inform |

## Key Principles

- **Delegate to solve-task** — run-plan never implements, reviews, or delivers. It orchestrates.
- **Clean state between tasks** — verify and enforce clean git state before each task, clean up failed branches on retry
- **Re-check dependencies** — completing or skipping a task changes what's available next
- **Propagate skips** — if a dependency was skipped, its dependents cannot run
- **Autonomous stops on failure** — don't skip broken tasks silently
- **Confirm mode gives choice** — retry, skip, or abort at every decision point
- **Log everything** — start, progress, failures, and completion. Session logs enable recovery.
- **Update the plan** — keep the execution plan's status section current after the run
