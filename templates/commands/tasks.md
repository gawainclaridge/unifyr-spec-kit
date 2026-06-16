---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
handoffs:
  - label: Analyze For Consistency
    agent: speckit.analyze
    prompt: Run a project analysis for consistency
    send: true
  - label: Implement Project
    agent: speckit.implement
    prompt: Start the implementation in phases
    send: true
  - label: Create Jira Tickets
    agent: speckit.taskstoissues
    prompt: Create Jira tickets from tasks
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

### Workflow Context (Unifyr Process)

This is **Stage 5 (Tasks)** of the Unifyr process:

- **Team**: Engineering only
- **Prerequisites**:
  - plan.md MUST exist (constitution was finalized in Stage 3, plan created in Stage 4)
  - spec.md MUST exist (for user stories)
- **Output**: tasks.md (or per-story files) with Jira placeholders
- **Next steps**: `/speckit.taskstoissues`, `/speckit.implement`

## Outline

### Argument Parsing

Check for optional flags in the user input:

- `--per-story`: Generate separate task files per user story (Unifyr-style)
  - Creates `tasks.md` (master index) + `tasks-us1.md`, `tasks-us2.md`, etc.
  - Each per-story file links to a Jira story ticket
- `--spike` (alias `--no-tdd`): Waive strict TDD for this exploratory/throwaway feature — generate without mandatory test-first ordering and record a `Testing mode: Spike (TDD waived)` marker so `/speckit.implement` and `/speckit.analyze` honor it. Use only for genuine spikes; production code keeps strict TDD.
- Default (no flag): Single `tasks.md` file with all tasks organized by story internally, strict TDD

1. **Setup**: Run `{SCRIPT}` from repo root and parse FEATURE_DIR, CONSTITUTION, and AVAILABLE_DOCS list. All paths must be absolute. `CONSTITUTION` is this work's constitution path (beside project.md when in a project, else in the feature dir). For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

   **Check for config**: Read `.speckit/config.yaml` if exists for `tasks.format` setting:

   ```yaml
   tasks:
     format: single  # or "per-story"
   ```

   The `--per-story` flag overrides config.

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities)
   - **Required**: the constitution at `CONSTITUTION` (from step 1) — implementation principles, test type/coverage emphasis. (Test *timing* is fixed: strict TDD is mandatory, so test tasks are always generated before their implementation tasks.)
   - **Optional**: data-model.md (entities), contracts/ (API endpoints), research.md (decisions), quickstart.md (test scenarios)
   - **Check for project context**: Determine if feature is part of a project
     - Check if current directory is under `specs/project-<name>/`
     - If project.md exists, load project context:
       - **Jira Integration** → Use project's Epic key for `[JIRA-EPIC-KEY]` placeholder
       - **Shared Setup Tasks** → Reference any project-level shared setup if defined
   - Note: Not all projects have all documents. Generate tasks based on what's available.

3. **Execute task generation workflow**:
   - Load plan.md and extract tech stack, libraries, project structure
   - Load spec.md and extract user stories with their priorities (P1, P2, P3, etc.)
   - If data-model.md exists: Extract entities and map to user stories
   - If contracts/ exists: Map endpoints to user stories
   - If research.md exists: Extract decisions for setup tasks
   - Generate tasks organized by user story (see Task Generation Rules below)
   - Generate dependency graph showing user story completion order
   - Create parallel execution examples per user story
   - Validate task completeness (each user story has all needed tasks, independently testable)

4. **Add Jira placeholders**: Add Jira integration section to tasks.md:
   - Epic placeholder: `[JIRA-EPIC-KEY]`
   - Note that these are placeholders until `/speckit.taskstoissues` is run

5. **Generate tasks.md** (or per-story files if configured):

   **If single-file mode (default)**:
   Use `templates/tasks-template.md` as structure, fill with:
   - Correct feature name from plan.md
   - Jira Integration section with Epic placeholder
   - Phase 1: Setup tasks (project initialization)
   - Phase 2: Foundational tasks (blocking prerequisites for all user stories)
   - Phase 3+: One phase per user story (in priority order from spec.md)
   - Each phase includes: story goal, independent test criteria, tests (strict TDD — authored first and must FAIL before implementation), implementation tasks
   - Final Phase: Polish & cross-cutting concerns
   - All tasks must follow the strict checklist format (see Task Generation Rules below)
   - Clear file paths for each task
   - Dependencies section showing story completion order
   - Parallel execution examples per story
   - Implementation strategy section (MVP first, incremental delivery)

   **If per-story mode (`--per-story` flag or config)**:
   a. Generate master `tasks.md` with:
      - Jira Integration section with Epic placeholder
      - Phase 1: Setup tasks
      - Phase 2: Foundational tasks
      - User Story Reference Table (links to individual story files)
      - Final Phase: Polish & cross-cutting
   b. For each user story, generate `tasks-us[N].md` using `templates/story-tasks-template.md`:
      - Story-specific Jira Story placeholder
      - Acceptance criteria from spec.md
      - Testing tasks from plan.md Testing Scenarios
      - Implementation tasks for that story
      - Completion checkpoint

6. **Report**: Output path to generated tasks.md (and per-story files if applicable) and summary:
   - Total task count
   - Task count per user story
   - Parallel opportunities identified
   - Independent test criteria for each story
   - Suggested MVP scope (typically just User Story 1)
   - Format validation: Confirm ALL tasks follow the checklist format (checkbox, ID, labels, file paths)
   - Jira integration status: placeholders ready for `/speckit.taskstoissues`
   - If per-story mode: list of generated story task files

Context for task generation: {ARGS}

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.

## Task Generation Rules

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

**Strict TDD is the default — test tasks come before their implementation tasks.** Test *timing* is not a constitution choice: by default every implementation task must be preceded by a test task that is authored first and expected to FAIL before the implementation makes it pass (red-green-refactor). Read the constitution at `CONSTITUTION` only to choose test *types* and emphasis (integration-first vs unit-first, mock vs real dependencies, coverage gate) — never to defer, reorder, or skip test-first ordering.

**Spike exception**: in spike mode (`--spike`/`--no-tdd`, or the user designates the feature exploratory/throwaway), test-first ordering is waived — tests may be omitted or placed after implementation. Record the testing mode near the top of tasks.md (just under the title) so `/speckit.implement` and `/speckit.analyze` honor it: write `Testing mode: Spike (TDD waived)` for a spike, otherwise `Testing mode: Strict TDD`.

### Checklist Format (REQUIRED)

Every task MUST strictly follow this format:

```text
- [ ] [TaskID] [P?] [Story?] Description with file path
```

**Format Components**:

1. **Checkbox**: ALWAYS start with `- [ ]` (markdown checkbox)
2. **Task ID**: Sequential number (T001, T002, T003...) in execution order
3. **[P] marker**: Include ONLY if task is parallelizable (different files, no dependencies on incomplete tasks)
4. **[Story] label**: REQUIRED for user story phase tasks only
   - Format: [US1], [US2], [US3], etc. (maps to user stories from spec.md)
   - Setup phase: NO story label
   - Foundational phase: NO story label  
   - User Story phases: MUST have story label
   - Polish phase: NO story label
5. **Description**: Clear action with exact file path

**Examples**:

- ✅ CORRECT: `- [ ] T001 Create project structure per implementation plan`
- ✅ CORRECT: `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py`
- ✅ CORRECT: `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
- ✅ CORRECT: `- [ ] T014 [US1] Implement UserService in src/services/user_service.py`
- ❌ WRONG: `- [ ] Create User model` (missing ID and Story label)
- ❌ WRONG: `T001 [US1] Create model` (missing checkbox)
- ❌ WRONG: `- [ ] [US1] Create User model` (missing Task ID)
- ❌ WRONG: `- [ ] T001 [US1] Create model` (missing file path)

### Task Organization

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Endpoints/UI needed for that story
     - Tests for that story (strict TDD — test tasks authored first and ordered before implementation; omit only if the user explicitly says no tests)
   - Mark story dependencies (most stories should be independent)

2. **From Contracts**:
   - Map each contract/endpoint → to the user story it serves
   - Each contract → a contract test task [P] ordered BEFORE its implementation task in that story's phase (strict TDD — the contract test must fail first)

3. **From Data Model**:
   - Map each entity to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase

4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
   - Story-specific setup → within that story's phase

### Phase Structure

- **Phase 1**: Setup (project initialization, test framework setup — always required since TDD is mandatory)
- **Phase 2**: Foundational (blocking prerequisites - MUST complete before user stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3...)
  - Strict TDD ordering (mandatory): Tests (written first, must FAIL) → Models → Services → Endpoints → Integration
  - Each phase should be a complete, independently testable increment
- **Final Phase**: Polish & Cross-Cutting Concerns (NOT where tests go — tests belong with their implementation phase)
