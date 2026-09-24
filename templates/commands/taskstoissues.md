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

## Voice & Audience

Everything you say to the user and write into the generated files is read by a **mixed team**: engineers, product owners, and QA. Write plainly:

- Short, direct sentences. One point per sentence.
- No waffle, filler, or flowery prose. Cut any word that does not change the meaning.
- No metaphors or grand phrasing ("engineering DNA", "foundational technical direction", "guardrails"). State the plain fact.
- Be unambiguous: each sentence should have one possible reading.
- When a technical term is unavoidable, say what it means the first time you use it.
- Keep the content itself precise. This is about wording, not about dropping detail.

### Workflow Context (Unifyr Process)

This is **Stage 5 (Tasks)** - Issue Creation phase:

- **Team**: Engineering only
- **Prerequisites**: tasks.md MUST exist
- **Output**: GitHub issues or Jira tickets (Epic → one ticket per user story; no sub-tasks); `--sync` updates already-created Jira tickets instead of creating duplicates
- **Next step**: `/speckit.implement`

## Outline

### Argument Parsing

Check for optional flags in the user input:

- `--jira <PROJECT-KEY>`: Create Jira tickets instead of GitHub issues
  - Example: `/speckit.taskstoissues --jira PROJ`
- `--github` (default): Create GitHub issues
- `--sync`: Update already-created tickets instead of creating new ones. Sync refreshes only the
  Engineering part (task checklist, spec link and version pin). It never rewrites the text written
  for QA; when the spec has changed, it lists which How to test steps may be out of date and asks a
  person to update them. Stories with no existing ticket are still created fresh. **Jira only for
  now** — combining `--sync` with `--github` (or the default) is an ERROR: stop and tell the user
  sync is not yet supported for GitHub issues, use `--jira`.
  - Example: `/speckit.taskstoissues --jira PROJ --sync`

1. Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. From the executed script, extract the path to **tasks** (tasks.md and any tasks-us*.md files if per-story mode).

3. **Detect issue tracker**:

   **If `--jira <PROJECT-KEY>` flag provided**:
   - Use Jira integration (see Jira Workflow below)

   **If `--github` flag or no flag (default)**:
   - If `--sync` was also passed, ERROR: "Sync is not yet supported for GitHub issues — use `--jira`." and stop.
   - Get the Git remote by running:

     ```bash
     git config --get remote.origin.url
     ```

   > [!CAUTION]
   > ONLY PROCEED TO GITHUB STEPS IF THE REMOTE IS A GITHUB URL

4. **For GitHub**: For each task in the list, use the GitHub MCP server to create a new issue in the repository that is representative of the Git remote. Reference artifacts as **deep-links** (see the **Building Artifact Links** section), not bare paths. Issue titles and bodies follow the **Story Ticket Format** section below, same as Jira. GitHub has no custom fields, so everything goes in the issue body.

   > [!CAUTION]
   > UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL

5. **For Jira**: See Jira Workflow section below — including **Keeping Tickets Current (`--sync`)** if that flag was passed.

6. **Update task files**: After creating (not syncing) tickets, update the task files. This is the one edit allowed despite the "DO NOT EDIT" header in tasks.md:
   - Replace `[JIRA-EPIC-KEY]` and `[JIRA-STORY-KEY]` placeholders with actual ticket keys
   - Update status columns if present

---

## Complexity Scoring

Before creating tickets, evaluate each user story's complexity using a Fibonacci scale. This gives teams a common way to size work without tracking velocity.

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

Quality tends to drop when features exceed approximately 5 days of traditional engineering effort (~8 story points). If the total story points across all stories suggest the feature exceeds this threshold, recommend breaking the feature into multiple specs using `/speckit.project` and the `--project` flag on `/speckit.specify`. This guidance is advisory, not blocking.

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
- Stories should represent user-visible value, not technical layers
- The ticket is written **for QA and Product first, engineers second**. Someone who has never opened spec.md must be able to test the story from the ticket alone. The layout is set by the **Story Ticket Format** section below.
- **How to test is the ticket's acceptance criteria.** Do not copy the spec's Acceptance Scenarios onto the ticket. Turn them into steps QA can follow in the product, and tag each step with the scenario it checks, e.g. "(AC 2)". **Every Acceptance Scenario must be covered by at least one step.** The tags, the spec link and the version pin keep the ticket traceable to the spec.
- **If the spec's Acceptance Scenarios are too thin or too technical to test from, fix the spec, not the ticket.** Write the best steps you can, then tell the user which stories look thin and suggest `/speckit.clarify` to strengthen spec.md (bumping its version).

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

## Story Ticket Format

Every story ticket (Jira or GitHub) uses this layout. It applies to fresh creation and to stories created during a `--sync` run.

Build the ticket from **the whole spec**, not only the user story's own fields. Much of what QA and Product need (why the change matters, who notices it, what Support must know) is in the Experience Vision, Non-Goals, Edge Cases and Adoption & Rollout sections. Read all of them, plus plan.md and tasks.md, before writing a ticket.

### Check the Jira project first

Before creating any ticket, read the project's issue types and each candidate type's field metadata once. Decide, and state in the run output:

- **Issue type**: default to Story. If the feature is internal work (refactors, flag retirements, dependency or security upgrades) **and** the project has a type such as "Tech Debt", propose that type and confirm with the user before creating anything. Internal work can still change what customers see (e.g. a rename), so always ask; never decide alone. Use the chosen type's fields for every check below.
- **Story points field**: find the estimate field by name. Prefer "Story point estimate" (team-managed projects) or "Story Points" (company-managed). Never use a field marked "Legacy". If more than one candidate remains, ask the user which one.
- **Engineering Notes field**: a field named "Engineering Notes" or "Dev Notes" (ignore case). If it exists, the Engineering content goes there instead of the description.
- **Feature flag field**: a field whose name starts with "Feature Flag" (ignore case). If the story adds, changes or removes feature flags, list their code names there, comma-separated.

### Title

Write a plain-language title that **names the specific thing being changed**, so a QA engineer knows what the story is about from the board alone.

- Start from the spec.md user story heading, but do not copy it if it is vague. Add the missing specifics: which feature, flag, screen or report.
- Never put code names (enums, constants, config keys) in the title. If no display name can be found, describe the thing in plain words from the spec instead.
- Keep it under about 90 characters.
- ❌ "Remove flags that are already superseded" (which flags?)
- ❌ "Retire the UNIFYR_ONE_MCP and AI_CREDIT_PRICING_MANAGEMENT flags" (code names)
- ✅ "Retire the Analytics IQ and Collateral IQ - Asset Enrichment feature flags"
- When you had to rewrite a vague heading, list the heading and your title in the run output and suggest updating spec.md to match.

### Naming things

Outside the Engineering content, call features, flags, settings and screens by the **name users see in the product**. The first time you mention one, you may put its code name in brackets after it, e.g. "Analytics IQ (`ANALYTICS_IQ`)".

Take display names only from a real source: spec.md, plan.md or the codebase (UI labels, translation files, flag metadata files). **Never make one up.** Plain descriptions the spec itself uses ("the MCP connection page") are fine. If there is neither, use the code name and list it in the run output so the user can fix it.

Code names are fine inside How to test steps where QA needs them to do the check, e.g. a setting with no UI label, or a name to search for in an API response.

### Description layout

Use these headings, in this order. Sections marked *optional* appear only when the spec has something real to say; leave them out rather than writing "N/A".

Keep every section short: say each thing once, in the section it belongs to. Aim for about 5-8 test steps; more only when each one checks something different. If the customers affected are themselves admins, use only "What changes for admins" and leave out "What customers will notice".

Leave fields this layout does not mention (such as Acceptance Criteria or QA Notes) empty: How to test holds the acceptance criteria, and QA fills in their own fields.

```markdown
### What this is
[1-3 plain sentences: what is changing, in product terms. Source: the user story narrative.]

### Why now
[1-2 sentences on why the change matters. Source: Experience Vision and the user story narrative.
Not the "Why this priority" line: that explains the order of the work.]

### What customers will notice
[Optional. What changes for customers, or "Nothing." with a one-line reason. Source: Experience
Vision, Non-Goals, Adoption & Rollout.]

### What changes for admins
[Optional. What changes in admin or internal screens, including anything that must keep working
alongside the change. Source: Experience Vision, Functional Requirements, Edge Cases.]

### How to test
1. [A step QA can do in the product, and what they should see.] (AC 1)
2. [...] (AC 2)
3. [A "still works" check: existing behaviour that must not change.] (FR-005)

[Build the steps from the Acceptance Scenarios, the Functional Requirements this story covers, the
Independent Test line, Edge Cases, and any verification tasks in tasks.md. Every Acceptance Scenario
needs at least one step tagged with it. Tag a step with an FR only when the story's text, its
scenarios or its tasks clearly point to that FR. End with the Demo Criteria: 1-2 sentences on what can be
shown in sprint review.]

### Risk
[What could break or who could be affected, and how to recover. Source: Edge Cases, the "Why this
priority" line, plan.md. If nothing material, write "Low: [one-line reason]". Never leave this out.]

### Release note
[Optional. How the change must be released, e.g. several steps in order, or both regions.
Source: plan.md, tasks.md phases, Functional Requirements about releases.]

### Note for Support and CSM
[Optional. What customer-facing teams must know or must not promise. Source: Adoption & Rollout,
Non-Goals.]

### Engineering
[Only when there is no Engineering Notes field; otherwise put this in that field, without the
heading.]
Source: [spec.md vX.Y → User Story N](deep-link)

- [x] T0xx [done task] ([deep-link to the task's line in tasks.md])
- [ ] T0xx [open task] ([deep-link])
- ~~T0xx [dropped task]~~ (dropped: [reason from tasks.md])
```

**Task status**: copy each task's state from tasks.md. `[X]`/`[x]` → ticked. Marked DROPPED or NOT DONE with a reason → struck through with the reason, so nobody picks up work the team decided against. Task wording stays as in tasks.md; code names are fine here.

**Before creating the ticket, check coverage**: list each Acceptance Scenario and the step(s) tagged with it. If one has no step, add a step. If the Independent Test says no functional test is needed but a scenario describes something a user can see (a setting, a screen, a result), still write a QA step for it and tell the user about the mismatch so they can fix the spec.

Apply the **Voice & Audience** rules to everything outside the Engineering content.

---

## Building Artifact Links (deep-link to source)

Ticket descriptions reference repo artifacts (spec.md, plan.md, tasks.md, charter.md). Emit these as **clickable deep-links to the source host on the correct branch** — Jira and GitHub render bare paths as plain text you cannot click.

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

**5. Spec version (pin)**: read the artifact's current version — the `**Version**:` header, or the latest row of its `## Changelog` table — and include it in the reference text as a stable version pin, e.g. `spec.md v2.6 → User Story 2`. The deep-link targets the **live project branch** (so a reader always sees the current spec), while the version records which revision the ticket's test steps were written against. When the spec's changelog later advances past the pinned version, that mismatch is the signal to re-check the ticket's How to test steps against the newer AC. A line anchor (step 4) drifts as the spec is edited; the version does not, so always pair the two.

Worked examples (project `acme`, branch `project-acme`, spec v2.6, US2 heading on line 88):

- Cloud: `[spec.md v2.6 → User Story 2](https://bitbucket.org/unifyr/platform/src/project-acme/specs/project-acme/spec.md#lines-88)`
- Server: `[spec.md v2.6 → User Story 2](https://bitbucket.example.com/projects/UNI/repos/platform/browse/specs/project-acme/spec.md?at=refs/heads/project-acme#88)`

> [!NOTE]
> A link only resolves once the branch and files are pushed to the remote. Ensure the project branch (with its spec.md/plan.md/tasks.md) is pushed before creating tickets; if it isn't, warn the user and push first, or fall back to bare paths.
>
> The deep-link tracks the **live project branch**, which is correct while the feature is still in progress and the spec is still being clarified — the ticket always resolves to the current AC. The **version pin (step 5)** is what makes that safe: it records the revision the ticket was written against, so drift is detectable. Once the feature merges and the spec stops moving, the link MAY be repointed to the merge-commit permalink for a frozen historical record; until then, prefer the branch link, never a mutable default branch (`master`/`main`) URL, which silently drifts with no version to detect it.

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
   - Description: Start with the **Experience Vision** paragraph from spec.md (the full text, not a link), followed by **deep-links** to spec.md and plan.md (see the **Building Artifact Links** section). This puts the feature's goal directly on the epic, so readers do not have to open other documents.
   - Note: If Epic already exists, use existing key

2. **For each User Story phase**:
   - If its `[JIRA-STORY-KEY]` placeholder in tasks.md already holds a real key, the ticket exists. Do not create a duplicate: skip the story, list it in the run output, and suggest `--sync`.
   - Create the ticket, using the issue type chosen in **Check the Jira project first**, linked to the Epic
   - Title, description and fields: follow the **Story Ticket Format** section. The `Source:` line in the Engineering section is a **deep-link** to the story's section in spec.md (see the **Building Artifact Links** section — include the section's line anchor **and the spec version pin, step 5**), so the ticket is always traceable back to its source and revision.
   - Story Points: write the Fibonacci score from the Complexity Scoring step into the estimate field found in **Check the Jira project first**

3. **Task breakdown (no Jira sub-tasks — we never go below Story)**: list the story's tasks (T0xx from tasks.md) as a **checklist in the Engineering section** (the Engineering Notes field, or the description if there is no such field), so the breakdown stays visible and trackable on the ticket itself:
   - Render each as a checklist item with a **deep-link** to the relevant artifact/section (see the **Building Artifact Links** section), showing its status from tasks.md (see **Task status** under **Story Ticket Format**).
   - Task descriptions stay as written in tasks.md. Code names are fine here, because this section is for engineers.
   - Do NOT create Sub-task issues.

4. **If per-story mode (tasks-us*.md files exist)**:
   - Process each story task file as a single Story ticket (its tasks become that Story's checklist, per step 3)
   - Update the `[JIRA-STORY-KEY]` placeholder in each file with the created Story key

### Keeping Tickets Current (`--sync`)

`--sync` updates existing tickets instead of creating duplicates. It only ever rewrites the
Engineering content. Everything written for QA belongs to the team once the ticket exists.

1. **Detect existing tickets**: for each User Story phase, check whether its `[JIRA-STORY-KEY]`
   placeholder in tasks.md (or the relevant tasks-us*.md, per-story mode) already holds a real ticket
   key from a prior run.
   - No key found → create the ticket fresh, exactly as a non-sync run would.
   - Key found → update it (next steps).

2. **Refresh the Engineering content** (in the Engineering Notes field, or under `### Engineering`):
   the task checklist with current statuses, the spec link, and the version pin. If you cannot find
   the Engineering content on the ticket (the heading was renamed or removed), do not guess: list the
   ticket as "not synced: no Engineering section" and move on.

3. **Flag test steps that may be out of date.** If the spec version has moved past the ticket's pin:
   1. Find the pinned spec.md revision in git history (the commit where `**Version**:` or the
      changelog reached that version) and compare its Acceptance Scenarios and Functional
      Requirements for this story with the current ones.
   2. For each scenario or requirement that was added, changed or removed, find the How to test
      steps on the ticket tagged with it (e.g. "(AC 2)").
   3. Show the user: the change in the spec, and the steps that cite it (or "no step covers this" for
      a new scenario). Suggest new wording for each step.
   4. **Do not edit How to test, or any other section written for QA, yourself.** Ask the user, per
      ticket, whether to apply the suggested wording, and apply it only if they say yes. If the
      pinned revision cannot be found, say so and show the current scenarios instead.

4. **Never change** the title, the issue type, status, assignee, sprint, comments, the feature flag
   field, or Story Points (re-score only if the user explicitly asks for a rescope).

5. **Report a sync summary**: for each story, whether it was **created**, **updated** (Engineering
   refreshed, pin moved forward), **already current** (pin matches the spec), **needs QA review**
   (spec changed; list the steps to check), or **not synced** (with the reason).

### Required Information

For Jira integration, you need:

- Project key (provided via `--jira <KEY>`)
- Jira instance URL (from environment or user input)

### Example

```bash
# Create Jira tickets in PROJ project
/speckit.taskstoissues --jira PROJ

# Refresh already-created tickets after spec.md changed (creates any still-missing ones too)
/speckit.taskstoissues --jira PROJ --sync
```

> [!CAUTION]
> ALWAYS CONFIRM THE CORRECT PROJECT KEY BEFORE CREATING TICKETS
