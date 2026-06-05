---
description: Convert existing tasks into GitHub issues or Jira tickets for the feature based on available design artifacts.
tools: ['github/github-mcp-server/issue_write']
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

### Workflow Context (Unifyr Process)

This is **Stage 5 (Tasks)** - Issue Creation phase:

- **Team**: Engineering only
- **Prerequisites**: tasks.md MUST exist
- **Output**: GitHub issues or Jira tickets (Epic → Story → Sub-task)
- **Next step**: `/speckit.implement`

## Outline

### Argument Parsing

Check for optional flags in the user input:

- `--jira <PROJECT-KEY>`: Create Jira tickets instead of GitHub issues
  - Example: `/speckit.taskstoissues --jira PROJ`
- `--github` (default): Create GitHub issues

1. Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. From the executed script, extract the path to **tasks** (tasks.md and any tasks-us*.md files if per-story mode).

3. **Detect issue tracker**:

   **If `--jira <PROJECT-KEY>` flag provided**:
   - Use Jira integration (see Jira Workflow below)

   **If `--github` flag or no flag (default)**:
   - Get the Git remote by running:

     ```bash
     git config --get remote.origin.url
     ```

   > [!CAUTION]
   > ONLY PROCEED TO GITHUB STEPS IF THE REMOTE IS A GITHUB URL

4. **For GitHub**: For each task in the list, use the GitHub MCP server to create a new issue in the repository that is representative of the Git remote.

   > [!CAUTION]
   > UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL

5. **For Jira**: See Jira Workflow section below.

6. **Update task files**: After creating tickets, update the task files:
   - Replace `[JIRA-XXX]` or `[JIRA-EPIC-KEY]` placeholders with actual ticket keys
   - Update status columns if present

---

## Complexity Scoring

Before creating tickets, evaluate each user story's complexity using a Fibonacci scale. This gives teams a shared sizing language without requiring velocity tracking.

### Scale

| Points | Meaning | Pre-AI Engineering Equivalent |
|--------|---------|-------------------------------|
| 1 | Trivial change | Few hours |
| 2 | Small, well-understood | Half a day |
| 3 | Moderate, some unknowns | 1-2 days |
| 5 | Significant, multiple components | 2-3 days |
| 8 | Large, cross-cutting | ~5 days |
| 13 | Very large, high uncertainty | 1-2 weeks |
| 20 | Epic-sized, should be broken down | 2+ weeks |

**Calibration**: 8 points = approximately 5 days of traditional engineering effort (pre-AI assistance).

### Scoring Heuristic

For each story, evaluate these factors and take the median:

| Factor | Low (1-2) | Medium (3-5) | High (8-13) | Very High (20) |
|--------|-----------|--------------|-------------|----------------|
| Sub-task count | 1-3 tasks | 4-6 tasks | 7-10 tasks | 10+ tasks |
| Schema changes | None | 1-2 entities | 3-5 entities | Major redesign |
| API surface | 0-1 endpoints | 2-3 endpoints | 4-6 endpoints | New service |
| UI complexity | None / minor | Single view | Multiple views | Complex interactions |
| Dependencies | Self-contained | 1-2 shared components | Cross-story deps | External integrations |
| Risk / novelty | Well-known patterns | Some new tech | Significant unknowns | Research required |

**Process**: Evaluate each factor per story, take the median value, round to the nearest Fibonacci number.

### Feature Sizing Guidance

Teams report a quality cliff when features exceed approximately 5 days of traditional engineering effort (~8 story points). If the total story points across all stories suggest the feature exceeds this threshold, recommend breaking the feature into multiple specs using `/speckit.project` and the `--project` flag on `/speckit.specify`. This guidance is advisory, not blocking.

### Output

After ticket creation, output a complexity summary table:

```text
| Story | Points | Rationale |
|-------|--------|-----------|
| US1 - [Title] | [N] | [Key factor driving the score] |
| US2 - [Title] | [N] | [Key factor driving the score] |
| **Total** | **[Sum]** | |
```

If total exceeds 20 points, add advisory: "Consider breaking this feature into smaller specs via `--project` mode."

---

## Story Design Principles

Stories created in the issue tracker should be **demo-able vertical slices**, not horizontal layers.

### Rules

- Each story MUST be independently demonstrable to QA/Product
- Story description links to the relevant spec.md section for acceptance criteria (do NOT duplicate full AC in the ticket)
- Story description includes brief **Demo Criteria**: 1-2 sentences describing what can be shown when complete
- Stories should represent user-visible value, not technical layers

### Anti-Patterns (avoid these story titles)

- "Implement database schema" (horizontal layer, not demonstrable)
- "Create API endpoints" (technical task, not user value)
- "Build frontend components" (partial, not independently testable)
- "Write unit tests" (supporting task, not a story)

### Good Story Examples

- "User can register and log in" (demo-able: show the registration flow)
- "User can create and view projects" (demo-able: create a project, see it listed)
- "User can drag tasks between board columns" (demo-able: drag and drop a card)

---

## Jira Workflow

When `--jira <PROJECT-KEY>` is provided:

### Ticket Hierarchy

```text
Epic (Feature)
├── Story (User Story 1)
│   ├── Sub-task (T001)
│   └── Sub-task (T002)
├── Story (User Story 2)
│   ├── Sub-task (T003)
│   └── Sub-task (T004)
└── ...
```

### Execution Steps

1. **Create Epic** (if not exists):
   - Title: Feature name from tasks.md
   - Description: Start with the **Experience Vision** paragraph from spec.md (the full text, not a link), followed by links to spec.md and plan.md. This ensures the north star is visible directly on the epic without navigating to other documents.
   - Note: If Epic already exists, use existing key

2. **For each User Story phase**:
   - Create Story ticket linked to Epic
   - Title: User Story title from spec.md
   - Description: Spec Reference link to the relevant section in spec.md + Demo Criteria (1-2 sentences describing what can be demonstrated when complete). Do NOT duplicate full acceptance criteria in the ticket.
   - Story Points: Set using the standard Jira `Story Points` estimate field with the Fibonacci score from the Complexity Scoring step

3. **For each task within a story**:
   - Create Sub-task linked to Story
   - Title: Task description
   - Include file paths in description

4. **If per-story mode (tasks-us*.md files exist)**:
   - Process each story task file
   - Update `[JIRA-XXX]` placeholders in each file

### Required Information

For Jira integration, you need:

- Project key (provided via `--jira <KEY>`)
- Jira instance URL (from environment or user input)

### Example

```bash
# Create Jira tickets in PROJ project
/speckit.taskstoissues --jira PROJ
```

> [!CAUTION]
> ALWAYS CONFIRM THE CORRECT PROJECT KEY BEFORE CREATING TICKETS
