---
name: report
description: "Use when the user wants a progress report, session summary, or sprint recap for a project. Reads tasks, changelogs, plans, and specs to produce a structured report in reports/. Can be invoked at any point in the workflow. Requires vibeMCP tools."
---

# Report

Generate a structured report from the current state of a vibe workspace.

## Flow

```
brainstorming → task-breakdown → solve-task/run-plan → core-review
                                        │
                                   [report] ←── at any point
```

This skill is not sequential — it can be invoked at any time as a snapshot of project state.

## Prerequisites

- vibeMCP server with tools: `list_tasks`, `list_changelog`, `list_specs`, `list_plans`, `list_reports`, `read_doc`, `get_plan`, `tool_create_doc`

If vibeMCP is not connected, inform the user and stop.

## Setup

1. Find the workspace: look for `vibe: <project>` in CLAUDE.md
2. If no project found, ask the user
3. Determine report type from the user's request (see Report Types below)

## Report Types

| Type | Trigger phrases | Focus |
|------|----------------|-------|
| **progress** (default) | "report", "status", "how are we doing" | Task completion snapshot — what's done, what's left, what's blocked |
| **sprint** | "sprint report", "weekly report", "what did we ship" | Period-based recap — completed work, PRs, changelog entries |

If the request is ambiguous, default to **progress**.

## Process

### 1. Gather Data

Fetch all relevant state from vibeMCP:

```
list_tasks(project)
list_tasks(project, status="done")
list_tasks(project, status="in-progress")
list_tasks(project, status="blocked")
list_tasks(project, status="pending")
get_plan(project)
list_changelog(project)
list_reports(project)
```

### 2. Enrich Context

**For progress reports:**
- If blocked tasks exist, read each one to extract the blocking reason:
  ```
  read_doc(project, "tasks", <blocked-task-filename>)
  ```
- If an execution plan exists, parse the dependency graph to identify what's unblocked and ready next

**For sprint reports:**
- Read recent changelog entries (last 7 days or since the last sprint report):
  ```
  read_doc(project, "changelog", <entry>)
  ```
- Check for existing reports to determine the period boundary:
  ```
  list_reports(project)
  ```
  If a previous sprint report exists, the new period starts from its date.

### 3. Generate Report

#### Progress Report Format

```markdown
# Progress Report — <project>

Date: YYYY-MM-DD

## Summary
<2-3 sentences: overall project health, key highlight, main blocker if any>

## Task Status

| Status | Count | % |
|--------|-------|---|
| Done | N | XX% |
| In Progress | N | XX% |
| Pending | N | XX% |
| Blocked | N | XX% |
| **Total** | **N** | **100%** |

## In Progress
- NNN-task-name — <objective>
- ...

## Blocked
- NNN-task-name — <blocking reason or dependency>
- ...

## Recently Completed
- NNN-task-name (YYYY-MM-DD) — <summary from changelog if available>
- ...

## Up Next
<Top 2-3 pending tasks that have no unmet dependencies and are ready to start>

## Observations
<Risks, patterns, or noteworthy items — only if something stands out. Omit if nothing to flag.>
```

#### Sprint Report Format

```markdown
# Sprint Report — <project>

Period: YYYY-MM-DD to YYYY-MM-DD

## Summary
<What was accomplished this period — 2-3 sentences>

## Completed Tasks
| Task | Date | Summary |
|------|------|---------|
| NNN-name | YYYY-MM-DD | <from changelog> |
| ... | | |

## Key Changes
<Grouped by theme if multiple tasks relate to the same area.
Pull from changelog entries.>

## Remaining Work

| Status | Count |
|--------|-------|
| Pending | N |
| In Progress | N |
| Blocked | N |

## Blockers
- NNN-task-name — <reason>
(Omit section if none)

## Next Sprint
<What should be prioritized next based on the execution plan and current blockers>
```

### 4. Present and Write

Show the report to the user. Then write it:

```
tool_create_doc(
    project=<project>,
    folder="reports",
    filename="YYYY-MM-DD-<type>-report",
    content=<report>
)
```

Filename convention: `2026-03-23-progress-report.md`, `2026-03-23-sprint-report.md`.

If a report with the same name already exists (same type, same day), append a sequence number: `2026-03-23-progress-report-2.md`.

### 5. Suggest Next Steps

After a progress report with blockers:
```
Blockers detected. Consider:
- solve-task <NNN> — to unblock a specific task
- run-plan — to execute all ready tasks
```

After a sprint report:
```
Sprint complete. Next:
- task-breakdown — if new work needs to be planned
- run-plan — to start the next sprint
```

## Error Handling

| Error | Action |
|-------|--------|
| vibeMCP not connected | Inform user, stop |
| No tasks exist | Report with empty state — "No tasks found. Use task-breakdown to create tasks." |
| No changelog entries | Omit "Recently Completed" details, note counts only |
| Duplicate filename | Append sequence number |
| tool_create_doc fails | Show error, display report content so it's not lost |

## Key Principles

- **Read-only analysis** — this skill only reads project state. The only write is the report itself in `reports/`.
- **Data-driven** — every statement in the report must come from actual task/changelog data. No speculation.
- **No git dependency** — unlike solve-task or run-plan, this skill does not require a git repo or `gh` CLI.
- **Always use MCP tools** — never read task/changelog files directly with Read/Edit
- **Adaptive content** — omit empty sections rather than showing "None" everywhere. A project with no blockers doesn't need a Blockers section.
- **Actionable** — end with concrete next steps, not generic advice
