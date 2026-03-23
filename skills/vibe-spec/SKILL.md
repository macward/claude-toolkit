---
name: spec
description: "Use when the user wants to create a Software Design Document (SDD) for a feature or component. Reads design docs from plans/ and analyzes the codebase to produce a structured spec in specs/. Typically follows brainstorming and leads into sdd-evolve or task-breakdown. Requires vibeMCP tools."
---

# Spec

Create a Software Design Document (SDD) from a feature description, design doc, or user request.

## Flow

```
brainstorming (plans/) → [spec] (specs/) → sdd-evolve (specs/ v2)
                                          → task-breakdown (tasks/)
```

- If coming from `brainstorming`, a design doc should already exist in `plans/`. Read it first — it's your primary input.
- After creating the SDD, suggest `sdd-evolve` to iterate on the design or `task-breakdown` to start implementation.

## Prerequisites

- vibeMCP server with tools: `list_specs`, `list_plans`, `read_doc`, `tool_create_spec`

If vibeMCP is not connected, inform the user and stop.

## Setup

1. Find the workspace: look for `vibe: <project>` in CLAUDE.md
2. If no project found, ask the user

## Process

### 1. Check Existing Specs

```
list_specs(project)
```

If a spec for the same topic already exists, inform the user:
```
An SDD already exists: sdd-auth-service.md
Options:
- Read it and extend it with new scope
- Use sdd-evolve to iterate on it
- Create a new one with a different name
```

### 2. Gather Input

**If coming from brainstorming:**
```
list_plans(project)
read_doc(project, "plans", <design-doc>)
```
Extract the goal, scope, and decisions from the design doc. Do not re-ask the user for information already in the doc.

**If standalone request:**
Ask the user to describe what they want to build. One clarifying question max — prefer multiple choice.

### 3. Analyze the Codebase

Read relevant files in the project to understand:
- Current architecture and patterns in use
- Existing interfaces the new feature will interact with
- Naming conventions and module organization
- Tech stack constraints

This step is critical — the SDD must be grounded in the actual codebase, not abstract.

### 4. Draft the SDD

Generate the document following the structure below. **Adapt sections to scope** — a small change doesn't need all 10 sections. Skip sections that don't apply and note why.

```markdown
# SDD: <Title>

## 1. Metadata
- Author: AI-assisted
- Date: YYYY-MM-DD
- Status: draft
- Source: plans/<design-doc>.md (if applicable)

## 2. Overview
<What is being built and why — 2-3 paragraphs. State the problem,
the proposed solution, and the expected outcome.>

## 3. Proposed Architecture
<Components, responsibilities, and interactions. Include a text
diagram if it helps. Reference existing modules that will be
touched or extended.>

## 4. Data Model
<Entities, relationships, schemas. Show struct/class definitions
or table schemas as code blocks. Skip if no new data structures.>

## 5. API / Interfaces
<Public interfaces: endpoints, function signatures, protocols,
contracts. Include request/response examples. Skip if purely
internal refactoring.>

## 6. Directory Structure
<Where the new code lives. Show only new or modified paths,
not the entire project tree.>

## 7. Implementation Plan
<Ordered steps. Each step should be independently deployable
or at least testable. Include verification criteria per step.>

## 8. Dependencies
<External packages, internal modules, or services required.
Note version constraints if relevant.>

## 9. Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ... | High/Med/Low | High/Med/Low | ... |

## 10. Success Criteria
<How to verify the feature is complete and working.
Concrete, testable statements.>
```

### 5. Present Summary

Before writing, show the user a brief summary:
```
SDD: <Title>
Sections: <list of included sections>
Scope: <one-line description>
Filename: sdd-<slug>.md

Write to specs/?
```

Wait for confirmation.

### 6. Write the SDD

```
tool_create_spec(project, title=<title>, content=<full SDD content>)
```

The tool auto-generates the filename as `sdd-<slug>.md` and writes to `specs/`.

### 7. Suggest Next Steps

```
Created: specs/sdd-<slug>.md

Next:
- sdd-evolve — to review and iterate on the design
- task-breakdown — to turn this spec into implementation tasks
```

## Error Handling

| Error | Action |
|-------|--------|
| vibeMCP not connected | Inform user, stop |
| Duplicate spec exists | Show options (extend, evolve, new name) |
| No design doc and no description | Ask user what to build |
| Codebase read fails | Note which files couldn't be read, continue with available info |
| tool_create_spec fails | Show error, offer to retry or save content locally |

## Key Principles

- **Codebase-grounded** — always read relevant code before writing. An SDD that ignores the actual codebase is fiction.
- **Adaptive structure** — not every SDD needs 10 sections. A 20-line change doesn't need a Data Model section. Skip what doesn't apply.
- **Spec, not brainstorm** — brainstorming is exploratory and creative. This skill produces a formal technical document with concrete decisions.
- **Draft status** — every SDD starts as draft. Use `sdd-evolve` to iterate and promote.
- **Always use MCP tools** — never write spec files directly with Write/Edit
- **Don't duplicate input** — if a design doc exists, extract from it. Don't re-ask the user for things already decided.
- **Connect the flow** — reference where the input came from and where the user can go next
