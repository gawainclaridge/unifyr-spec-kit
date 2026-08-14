---
description: Create or manage a project definition for multi-feature projects with shared context.
handoffs:
  - label: Create Specification
    agent: speckit.specify
    prompt: Create a feature specification for this project. --project {PROJECT_NAME} I want to build...
  - label: Create Engineering Charter
    agent: speckit.charter
    prompt: Create project charter with principles for...
scripts:
  sh: scripts/bash/create-project.sh --json "{ARGS}"
  ps: scripts/powershell/create-project.ps1 -Json "{ARGS}"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Voice & Audience

Everything you say to the user and write into the generated files is read by a **mixed team**: engineers, product owners, and QA. Write plainly:

- Short, direct sentences. One point per sentence.
- No waffle, filler, or flowery prose. Cut any word that does not change the meaning.
- No metaphors or grand phrasing ("engineering DNA", "foundational technical direction", "guardrails"). State the plain fact.
- Be unambiguous: each sentence should have one possible reading.
- When a technical term is unavoidable, say what it means the first time you use it.
- Keep the content itself precise. This is about wording, not about dropping detail.

### Workflow Context (Unifyr Process)

This is **Stage 1 (Specification)** of the Unifyr process:

- **Team**: Product
- **Purpose**: Define the shared constraints and context that every feature specification in a multi-feature project must follow
- **Prerequisites**: None
- **Output**: project.md with out-of-scope exclusions, shared constraints, and a features table. Every specification must stay within these.
- **Next step**: `/speckit.specify --project <name>` to add features (specs must stay within project boundaries)

## Outline

This command creates or manages a project.md file for multi-feature projects. A project sets the **limits that every specification must follow** — out-of-scope exclusions, shared constraints, and common context. All feature specs created under a project must respect these limits.

### When to Use Projects

Use projects when:

- Multiple features share significant context (target users, constraints, tech decisions)
- Features are part of a larger initiative (e.g., "Taskify Platform")
- You want to avoid repeating shared information in each spec.md

### Argument Parsing

The first argument is the project name:

- `/speckit.project taskify` - Create or manage the "taskify" project
- `/speckit.project taskify --list` - List all specs in the project
- `/speckit.project taskify --add-spec` - Add current spec to the project

### Execution Flow

1. **Parse Arguments**:
   - Extract project name from first argument
   - Check for optional flags: `--list`, `--add-spec`

2. **Check for existing project**:
   - Look for branch `project-<name>`
   - Look for directory `specs/project-<name>/`
   - Look for `specs/project-<name>/project.md`

3. **If project exists and no flags**:
   - Display project summary (name, status, features count)
   - Show Features table from project.md
   - Offer options: add spec, update project, view details

4. **If project exists with `--list` flag**:
   - Read project.md Features table
   - Display all linked specifications with their status

5. **If project exists with `--add-spec` flag**:
   - Get current feature from git branch or SPECIFY_FEATURE
   - Add entry to Features table in project.md
   - Update spec.md to reference the project

6. **If project does NOT exist**:
   a. Run `{SCRIPT}` to:
      - Create branch `project-<name>` from main
      - Create directory `specs/project-<name>/`
      - Copy `templates/project-template.md` to `specs/project-<name>/project.md`

   b. Gather project information from user:
      - Project overview/description
      - Target users (shared across features)
      - Out-of-scope items (project-level exclusions)
      - Shared constraints

   c. Fill project.md template:
      - Replace [PROJECT NAME] with provided name
      - Fill Project Overview section
      - Fill Target Users section
      - Fill Out of Scope section
      - Fill Shared Constraints section
      - Initialize Features table (empty)
      - Initialize Jira Integration placeholders
      - Initialize Changelog with version 1.0

   d. Write completed project.md to `specs/project-<name>/project.md`

7. **Report**:
   - Project branch name
   - Project.md path
   - Next steps:
     - "Run `/speckit.specify --project <name> <description>` to add features"
     - "Run `/speckit.charter` to create project charter"

## Project Structure

When a project is created:

```text
specs/
└── project-<name>/
    ├── project.md           # Project definition (shared context)
    ├── 001-feature-a/       # First feature
    │   ├── spec.md
    │   ├── plan.md
    │   └── tasks.md
    ├── 002-feature-b/       # Second feature
    │   ├── spec.md
    │   ├── plan.md
    │   └── tasks.md
    └── ...
```

## Guidelines

### Project vs Spec Scope

Project.md sets the **constraints that every specification must follow**. Feature specs must stay within them.

| Aspect | Project (project.md) — bounds specs | Feature (spec.md) — within project bounds |
|--------|-------------------------------------|------------------------------------------|
| Scope exclusions | Out of Scope (project-wide exclusions) | Non-Goals (feature-specific, within project bounds) |
| Users | Shared target users (universal) | Feature-specific user journeys |
| Constraints | Shared constraints (all specs must respect) | Feature-specific requirements (must not violate shared) |
| Tech decisions | Shared stack (if decided, inherited by all) | Feature-specific implementation details |

### Naming Conventions

- Project branch: `project-<kebab-case-name>` (e.g., `project-taskify`)
- Project directory: `specs/project-<name>/`
- Feature directories within project: `specs/project-<name>/###-<feature>/`

### Jira Integration

Projects map to Jira Epics:

- Project → Epic
- Feature specs → Stories under the Epic
- Tasks → tracked as a checklist on each Story (no Jira sub-tasks)

Update Jira Integration section with:

- Jira Project key
- Epic key (once created)
