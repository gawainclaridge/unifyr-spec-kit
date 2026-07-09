---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
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

This is **Stage 5 (Tasks)** - Implementation phase:

- **Team**: Engineering only
- **Prerequisites**:
  - tasks.md MUST exist (charter was finalized in Stage 3, plan in Stage 4)
  - the charter provides architectural decisions and implementation principles that guide HOW tasks are executed. Test *timing* defaults to strict TDD (red-green-refactor) as a pipeline invariant (waived only in **spike mode** — see step 4b); test *types*/coverage default sensibly for the stack (the charter does not own testing).
  - Recommended: Issue tickets created via `/speckit.taskstoissues`
- **Output**: Implemented feature code

## Outline

1. Run `{SCRIPT}` from repo root and parse FEATURE_DIR, CHARTER, and AVAILABLE_DOCS list. All paths must be absolute. `CHARTER` is this work's Engineering Charter path (beside project.md when in a project, else in the feature dir); the script also emits `CONSTITUTION` as a deprecated alias and resolves a legacy `constitution.md` when no `charter.md` exists yet. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Verify prerequisites**:
   - **Tasks required**: Verify tasks.md exists in FEATURE_DIR
     - If NOT found: ERROR "Tasks must be generated before implementation. Run /speckit.tasks first."

3. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     - Completed items: Lines matching `- [X]` or `- [x]`
     - Incomplete items: Lines matching `- [ ]`
   - Create a status table:

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

   - Calculate overall status:
     - **PASS**: All checklists have 0 incomplete items
     - **FAIL**: One or more checklists have incomplete items

   - **If any checklist is incomplete**:
     - Display the table with incomplete item counts
     - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 4

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 4

4. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **REQUIRED**: Read the charter at `CHARTER` (from step 1) for architectural decisions and implementation principles. (Test *timing* defaults to strict TDD; test *types*/coverage default sensibly for the stack; spike mode waives TDD — see step 4b.)
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4b. **Determine the testing mode, then apply it.**

   The mode is **Spike (TDD waived)** if ANY of these hold; otherwise it is **Strict TDD (default)**:

- the user passed `--spike` (alias `--no-tdd`) in the input, or explicitly says this is a spike / throwaway / exploratory effort; or
- tasks.md carries a `Testing mode: Spike` marker (set by `/speckit.tasks --spike`).

   **Strict TDD (default) — the implementation contract**: every unit of behavior is built with the red-green-refactor cycle. Test *types* (unit/integration/contract mix), mock-vs-real dependencies, and coverage default sensibly for the stack; the charter is consulted for non-testing principles (code quality, architecture, observability) — never to weaken, defer, or skip test-first ordering. For each unit of work (endpoint, model, service, branch of behavior), follow this cycle and do not skip steps:

- **RED**: Write the test(s) first and run them. Confirm they FAIL for the right reason (a genuine assertion/behavior failure, not a typo, missing import, or collection error). A test that passes immediately, or errors out before reaching its assertion, is not a valid RED — fix the test until it fails meaningfully. **Never write implementation code before a failing test exists.**
- **GREEN**: Write the minimum implementation needed to make the failing test(s) pass. Run the tests and confirm they now pass.
- **REFACTOR**: Clean up implementation and tests while keeping the suite green. Re-run after refactoring.
- **Reorder if needed**: If tasks.md sequenced an implementation task before its test task, reorder at execution time so the test is authored and failing first. Test-first ordering wins over any conflicting task sequence.

   **Spike mode (TDD waived)**: tests are optional and may be written after the code or omitted — do NOT force red-green-refactor or reorder to test-first. State in your progress that TDD was waived because this is a spike. Use this only for genuine exploration/throwaway work; anything that ships as production code goes through Strict TDD.

   **Both modes always apply:**

- **Code quality**: Apply the charter's principles about code style, documentation, and observability.
- **Architecture enforcement**: Follow the charter's modularity and dependency-direction decisions as you create files.
- **Execution verification is MANDATORY** (independent of testing mode): every task and phase boundary MUST be verified against ground truth before it is marked complete — compile/build the affected code and run the relevant tests, linters, and static analysis. Even a spike must compile/build and pass whatever tests/lint exist. Never mark a task `[X]` based on self-assessment (e.g., ticking a checklist item) when an executable check is available — a passing build/test run is the only acceptable evidence of completion.

5. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc* exists → create/verify .eslintignore
   - Check if eslint.config.* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

6. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

7. Execute implementation following the task plan:
   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **Strict TDD by default** (see step 4b): execute the test task(s) for each unit before its implementation — confirm RED, implement to GREEN, then refactor; reorder if the task list put implementation first. In **spike mode** this is waived (tests optional / may come after).
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints (verify-and-iterate)**: At every task and phase boundary, run the project's verification commands and confirm they pass GREEN before proceeding (see the self-correction loop in step 9). Do not start a dependent task on a red build.

8. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests first by default (strict TDD)**: For every component, write and run its failing test(s) before writing any implementation (see step 4b). Never defer testing to a later phase. Exception: **spike mode** — tests optional / may come after.
   - **Core development**: Implement models, services, CLI commands, endpoints — each preceded by its failing test, then implemented to green
   - **Integration work**: Database connections, middleware, logging, external services — with their integration tests written first (test type/emphasis per stack defaults)
   - **Polish and validation**: Performance optimization, documentation, final coverage check against the coverage target

9. Progress tracking and error handling:
   - Report progress after each completed task
   - **Verify-and-iterate (self-correction loop)**: After implementing each task — and at every phase boundary — run the project's verification commands: build/compile, the relevant test suite, and linters/static analysis. Discover the exact commands from plan.md's Technical Context, the charter's quality gates, and the repo's build tooling (e.g., the build file, package scripts, CI config). If verification fails: read the actual error output, diagnose and fix the root cause, then re-run. Repeat up to a small bounded number of attempts (default: 3). Never mark a task `[X]` while its verification is red, and never start a dependent task on a red build.
   - If a non-parallel task is still failing after the bounded self-correction attempts: halt, and report the failing command, its output, your diagnosis, and suggested next steps.
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

10. Completion validation:
    - Verify all required tasks are completed
    - Check that implemented features match the original specification
    - **Run the full relevant verification suite (build, tests, linters/static analysis) and confirm it passes GREEN — this is required, not conditional.** Validate coverage against the coverage target if one is defined. Do NOT report success on the basis of self-assessment, completed checklist items, or "should pass" reasoning — only an actual passing run counts as evidence of completion.
    - Confirm the implementation follows the technical plan and adheres to charter principles
    - Report final status with summary of completed work and charter compliance

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/speckit.tasks` first to regenerate the task list.
