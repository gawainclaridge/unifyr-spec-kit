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
  - tasks.md MUST exist (constitution was finalized in Stage 3, plan in Stage 4)
  - constitution.md provides the testing philosophy, architectural decisions, and implementation principles that guide HOW tasks are executed
  - Recommended: Issue tickets created via `/speckit.taskstoissues`
- **Output**: Implemented feature code

## Outline

1. Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

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
   - **REQUIRED**: Read `/memory/constitution.md` for testing philosophy, architectural decisions, and implementation principles
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4b. **Apply constitution to implementation approach**: The constitution's testing philosophy and implementation principles determine HOW tasks are executed — not just WHAT gets built. Before beginning execution:
   - **Testing approach**: Read the constitution's testing decisions to determine:
     - Whether to follow strict TDD (tests before code), test-alongside (tests with each component), or test-after
     - Whether to prefer unit tests, integration tests, or a specific mix
     - Coverage expectations and quality gates
   - **Code quality**: Apply any constitution principles about code style, documentation, observability
   - **Architecture enforcement**: Follow the constitution's modularity and dependency direction decisions as you create files
   - If the constitution is silent on testing, default to: write tests alongside implementation (not deferred to a polish phase)
   - **Execution verification is MANDATORY and independent of test-authoring timing**: Whatever the testing philosophy (test-first, test-alongside, or test-after), every unit of work MUST be verified against ground truth before it is marked complete — compile/build the affected code and run the relevant tests, linters, and static analysis. "Test-After" governs only WHEN new tests are authored; it never waives in-loop verification. Never mark a task `[X]` based on self-assessment (e.g., ticking a checklist item) when an executable check is available — a passing build/test run is the only acceptable evidence of completion.

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
   - **Follow constitution's testing philosophy** (see step 4b): If TDD — execute test tasks before implementation. If test-alongside — write tests with each component. If test-after — complete implementation then test. If constitution is silent, write tests alongside.
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints (verify-and-iterate)**: At every task and phase boundary, run the project's verification commands and confirm they pass GREEN before proceeding (see the self-correction loop in step 9). Do not start a dependent task on a red build.

8. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests per constitution**: Follow the testing approach determined in step 4b. If constitution mandates TDD, write tests before implementation for each component. If test-alongside, write tests with each component. Never defer all testing to a final phase.
   - **Core development**: Implement models, services, CLI commands, endpoints — each with their tests as dictated by the testing approach
   - **Integration work**: Database connections, middleware, logging, external services — with integration tests if constitution requires them
   - **Polish and validation**: Performance optimization, documentation, final coverage check against constitution requirements

9. Progress tracking and error handling:
   - Report progress after each completed task
   - **Verify-and-iterate (self-correction loop)**: After implementing each task — and at every phase boundary — run the project's verification commands: build/compile, the relevant test suite, and linters/static analysis. Discover the exact commands from plan.md's Technical Context, the constitution's quality gates, and the repo's build tooling (e.g., the build file, package scripts, CI config). If verification fails: read the actual error output, diagnose and fix the root cause, then re-run. Repeat up to a small bounded number of attempts (default: 3). Never mark a task `[X]` while its verification is red, and never start a dependent task on a red build.
   - If a non-parallel task is still failing after the bounded self-correction attempts: halt, and report the failing command, its output, your diagnosis, and suggested next steps.
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

10. Completion validation:
    - Verify all required tasks are completed
    - Check that implemented features match the original specification
    - **Run the full relevant verification suite (build, tests, linters/static analysis) and confirm it passes GREEN — this is required, not conditional.** Validate coverage against the constitution's threshold if one is defined. Do NOT report success on the basis of self-assessment, completed checklist items, or "should pass" reasoning — only an actual passing run counts as evidence of completion.
    - Confirm the implementation follows the technical plan and adheres to constitution principles
    - Report final status with summary of completed work and constitution compliance

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/speckit.tasks` first to regenerate the task list.
