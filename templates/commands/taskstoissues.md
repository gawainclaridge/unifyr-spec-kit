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
- **Output**: GitHub issues or Jira tickets (Epic → Story; no sub-tasks)
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

4. **For GitHub**: For each task in the list, use the GitHub MCP server to create a new issue in the repository that is representative of the Git remote. Reference artifacts as **deep-links** (see the **Building Artifact Links** section), not bare paths.

   > [!CAUTION]
   > UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL

5. **For Jira**: See Jira Workflow section below.

6. **Update task files**: After creating tickets, update the task files:
   - Replace `[JIRA-EPIC-KEY]` and `[JIRA-STORY-KEY]` placeholders with actual ticket keys
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
| Task count | 1-3 tasks | 4-6 tasks | 7-10 tasks | 10+ tasks |
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
- Story description deep-links to the relevant spec.md section for acceptance criteria (see the **Building Artifact Links** section); do NOT duplicate full AC in the ticket
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

## Building Artifact Links (deep-link to source)

Ticket descriptions reference repo artifacts (spec.md, plan.md, tasks.md, charter.md). Emit these as **clickable deep-links to the source host on the correct branch** — Jira and GitHub render bare paths as dead text.

**1. Resolve the repo web base** from the origin remote:

```bash
git remote get-url origin
```

Parse it, auto-detecting the host (strip a trailing `.git` and any `user@` credentials):

- **Bitbucket Cloud** (host `bitbucket.org`): SSH `git@bitbucket.org:WS/REPO.git` or HTTPS `https://USER@bitbucket.org/WS/REPO.git` → base `https://bitbucket.org/WS/REPO`. File URL: `BASE/src/<branch>/<path>`, line anchor `#lines-<N>`.
- **Bitbucket Server / Data Center** (any other host; URL contains `/scm/` or port `:7999`): `https://HOST/scm/PROJ/REPO.git` or `ssh://git@HOST:7999/PROJ/REPO.git` → base `https://HOST/projects/PROJ/repos/REPO`. File URL: `BASE/browse/<path>?at=refs/heads/<branch>`, line anchor `#<N>`.
- **GitHub** (host `github.com`): base `https://github.com/OWNER/REPO`. File URL: `BASE/blob/<branch>/<path>`, line anchor `#L<N>`.
- **Unrecognized host**: skip deep-linking — fall back to the bare repo-relative path and say so in the output.

**2. Choose the branch** the artifacts live on:

- If the artifacts are under `specs/project-<name>/` → use the project branch `project-<name>`.
- Otherwise → use the current feature branch (`git rev-parse --abbrev-ref HEAD`).

**3. Build the repo-relative path** by stripping REPO_ROOT from the absolute artifact path (e.g. `specs/project-acme/spec.md`); URL-encode spaces as `%20`.

**4. Section anchor (optional)**: for a Story that points at one user-story section, find that heading's 1-based line number in spec.md and append the host-specific line anchor from step 1.

Worked examples (project `acme`, branch `project-acme`, US2 heading on line 88):

- Cloud: `https://bitbucket.org/unifyr/platform/src/project-acme/specs/project-acme/spec.md#lines-88`
- Server: `https://bitbucket.example.com/projects/UNI/repos/platform/browse/specs/project-acme/spec.md?at=refs/heads/project-acme#88`

> [!NOTE]
> A link only resolves once the branch and files are pushed to the remote. Ensure the project branch (with its spec.md/plan.md/tasks.md) is pushed before creating tickets; if it isn't, warn the user and push first, or fall back to bare paths.

---

## Jira Workflow

When `--jira <PROJECT-KEY>` is provided:

### Ticket Hierarchy

```text
Epic (Feature)
├── Story (User Story 1)
├── Story (User Story 2)
└── ...
```

### Execution Steps

1. **Create Epic** (if not exists):
   - Title: Feature name from tasks.md
   - Description: Start with the **Experience Vision** paragraph from spec.md (the full text, not a link), followed by **deep-links** to spec.md and plan.md (see the **Building Artifact Links** section). This ensures the north star is visible directly on the epic without navigating to other documents.
   - Note: If Epic already exists, use existing key

2. **For each User Story phase**:
   - Create Story ticket linked to Epic
   - Title: User Story title from spec.md
   - Description: A **deep-link** to the relevant section in spec.md (see the **Building Artifact Links** section — include the section's line anchor) + Demo Criteria (1-2 sentences describing what can be demonstrated when complete). Do NOT duplicate full acceptance criteria in the ticket.
   - Story Points: Set using the standard Jira `Story Points` estimate field with the Fibonacci score from the Complexity Scoring step

3. **Task breakdown (no Jira sub-tasks — we never go below Story)**: embed the story's tasks (T0xx from tasks.md) as a **checklist in the Story description** so the breakdown stays visible and trackable on the Story itself:
   - Render each as a checklist item — `- [ ] T0xx <description>` — with a **deep-link** to the relevant artifact/section (see the **Building Artifact Links** section).
   - Do NOT create Sub-task issues.

4. **If per-story mode (tasks-us*.md files exist)**:
   - Process each story task file as a single Story ticket (its tasks become that Story's checklist, per step 3)
   - Update the `[JIRA-STORY-KEY]` placeholder in each file with the created Story key

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
