# Project Context Command

Load complete project context at the start of a work session. Shows active tasks, last session notes, and suggests next steps.

## Setup

**Read the vibe workspace from CLAUDE.md:**
1. Look for `vibe: <project-name>` in the project's CLAUDE.md
2. If not found, inform user and suggest running `/vibe-init` first

## Process

### 1. Get Active Tasks

```
mcp__vibeMCP__list_tasks(project=<project>, status="in-progress")
```

- List all tasks currently being worked on
- Note how long they've been in progress (from file metadata if available)

### 2. Check Pending Tasks

```
mcp__vibeMCP__list_tasks(project=<project>, status="pending")
```

- Count pending tasks for context
- Identify next logical task if no in-progress tasks

### 3. Generate Summary

Display a concise summary:

```
Project: <project-name>

In Progress:
- 003-auth-middleware (started 2 days ago)

Pending: 3 tasks (004, 005, 006)

Suggested next step:
- Continue with 003-auth-middleware
- Or run /next-task to pick a new task
```

## Output Format

```
Project: <project>

In Progress:
- <task-number>-<task-name> [time context if available]
  [brief description from task objective]

Pending: <N> tasks

Suggested:
- [specific recommendation based on state]
```

## Rules

1. **Always use MCP tools** - Never access filesystem directly
2. **Be concise** - This is meant for quick context, not full briefing
3. **Prioritize actionable info** - Focus on what to do next
4. **Handle missing data gracefully** - If no tasks exist, inform the user
5. **Suggest clear next step** - Either continue in-progress or pick next task

## Examples

**No in-progress tasks:**
```
Project: vibeMCP

In Progress: None

Pending: 2 tasks (004-tests, 005-docs)

Suggested: Run /next-task to start 004-tests
```

**Multiple in-progress tasks:**
```
Project: backend-api

In Progress:
- 003-auth-service
- 007-logging (started today)

Pending: 4 tasks

Suggested: Focus on completing 003-auth-service first
```

**Fresh project (no prior work):**
```
Project: new-project

In Progress: None

Pending: 5 tasks (001 through 005)

Suggested: Run /solve-task 001 to start first task
```
