---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
handoffs:
  - label: Create Tasks (Stage 5)
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

### Workflow Context (Unifyr Process)

This is **Stage 4 (Planning)** of the Unifyr process:

- **Team**: Engineering only
- **Prerequisites**:
  - spec.md exists and ideally clarified (Stage 2)
  - constitution.md MUST be finalized (Stage 3 - run `/speckit.constitution` first if not done). The constitution provides architectural decisions and implementation principles that actively drive the plan's technology choices, architecture, testing strategy, and migration approach.
- **Output**: plan.md with technical architecture, testing scenarios, design documents — all shaped by the constitution
- **Next step**: `/speckit.tasks` (Stage 5 - Engineering)

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH, CONSTITUTION. `CONSTITUTION` is the absolute path to this work's constitution (beside project.md when in a project, else in the feature dir). For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Verify prerequisites**:
   - **Constitution finalized**: Check if the file at `CONSTITUTION` (from step 1) exists and is finalized
     - If found AND no remaining placeholder tokens (`[ALL_CAPS]`): proceed normally.
     - If found BUT has remaining placeholder tokens: WARN "Constitution exists but is incomplete (N placeholders remain). Would you like to complete it now with a quick Q&A? (yes/no)"
       - If yes: Execute **Phase -1** (see below).
       - If no: ERROR "Constitution must be finalized before planning. Run /speckit.constitution first."
     - If NOT found: WARN "No constitution found. A constitution is required before planning. Would you like to create one now with a quick Q&A? (yes/no)"
       - If yes: Execute **Phase -1** (see below).
       - If no: ERROR "Constitution must be finalized before planning. Run /speckit.constitution first."
     - If found but Sign-Off section shows "Pending": WARN "Constitution not yet signed off - consider finalizing before proceeding"
   - **Spec sign-off check** (advisory): Check spec Sign-Off table status
     - If not signed off: WARN "Spec not yet signed off - plan may need revision after sign-off"
   - **Check for project context**: Determine if feature is part of a project
     - Check if current directory is under `specs/project-<name>/`
     - If project.md exists, load and apply project context (see step 2b)

2b. **Load project.md** (if feature is part of a project):

- Read `specs/project-<name>/project.md`:
  - **Shared Constraints** → Validate plan doesn't violate these constraints
  - **Shared Tech Decisions** → Inherit stack choices (if defined at project level)
  - **Out of Scope** → Ensure plan doesn't include any excluded items
  - **Jira Integration** → Use Epic key for linking
- Add "Project Alignment" check to plan validation:
  - Plan MUST NOT include features listed in project Out of Scope
  - Plan MUST respect Shared Constraints
  - Plan SHOULD inherit Shared Tech Decisions unless spec explicitly overrides

3. **Load context**: Read FEATURE_SPEC and the constitution at `CONSTITUTION`. Load IMPL_PLAN template (already copied).

3b. **Apply constitution to plan decisions**: The constitution contains high-level architectural decisions and overarching implementation principles that MUST actively drive the plan — not just serve as a compliance gate. As you fill each plan section, use the constitution to:

- **Technical Context**: Inherit technology choices, framework preferences, and constraints from the constitution. If the constitution specifies a testing philosophy (e.g., "TDD mandatory", "integration tests preferred over mocks"), reflect that in the Testing field. If it specifies storage decisions, reflect those in the Storage field.
- **Project Structure**: Follow the constitution's architecture and modularity decisions (e.g., "Library-First", "microservices", "monolith") when choosing the project layout.
- **Testing Scenarios**: Strict TDD is the default — design tests so they are authored and FAIL before implementation, and structure the plan so `/speckit.tasks` can order test tasks before their implementation tasks. Use the constitution only to choose test *types* and emphasis (integration-first vs unit-first, mock vs real dependencies, coverage gate) — never to defer or skip test-first ordering. (Genuine spikes can waive TDD at tasks/implement time via `--spike`.)
- **Migration Plan**: Follow the constitution's versioning and migration decisions (e.g., "reversible migrations required", "API version coexistence period").
- **Phase structure**: If the constitution defines observability or security requirements, ensure the plan includes tasks that address them.

   The constitution goes beyond the agent file (universal product truths) — it captures initiative-specific decisions that the plan must actively incorporate, not just validate against.

4. **Scope alignment check**: Before proceeding with planning:
   - Extract all user stories from spec.md
   - Verify plan will address each story
   - If plan would add features beyond spec scope:
     - WARN "Plan would exceed spec scope"
     - List the additional features
     - Recommend: "Amend spec.md first and get Product sign-off before continuing"
     - Allow user to confirm they want to proceed anyway

5. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context — actively driven by constitution decisions (see step 3b), mark genuine unknowns as "NEEDS CLARIFICATION"
   - Fill Constitution Check section from constitution (both compliance gates AND decisions that shaped the plan)
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md, migration plan — all shaped by constitution's architectural decisions and implementation principles
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design — verify the design still aligns with constitution decisions

6. **Generate Testing Scenarios**: For each user story:
   - Extract acceptance criteria from spec.md
   - Generate happy path test scenarios
   - Generate edge case test scenarios
   - Generate error handling test scenarios
   - Add to plan.md "Testing Scenarios" section

7. **Initialize Sign-Off table** in plan.md with "Pending" statuses

8. **Fill Spec Reference section** in plan.md:
   - Link to source spec.md
   - Record spec version from changelog
   - Update Scope Alignment Check checkboxes

9. **Stop and report**: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.
   - Include summary of Testing Scenarios generated
   - Note Sign-Off status (all Pending for new plans)

## Phases

### Phase -1: Constitution Creation (auto-triggered, optional)

This phase executes a condensed version of `/speckit.constitution` inline when no constitution exists or when it is incomplete. It enables planning to proceed without a separate command invocation. The resulting constitution provides architectural decisions and implementation principles that actively drive the plan — not just compliance gates.

1. Load the seed template at `.specify/memory/constitution.md`
2. **Codebase scan**: Scan repo root for technical signals across the 10-category taxonomy (Testing, Code Quality, Architecture, Observability, CI/CD, Security, Versioning, Simplicity, Migration, i18n). Classify each as Detected / Partial / No Signal.
3. Present scan results table to user.
4. **Q&A loop**: Ask up to 8 targeted questions (one at a time) following the same format as `/speckit.constitution` Step 3 (multiple-choice with recommended option, or short-answer with suggestion). Record answers in working memory. **Critical**: Strict TDD is mandatory and NON-NEGOTIABLE — do NOT ask whether to use TDD, test-alongside, or test-after. The testing question(s) may only cover test type preference (unit, integration, contract), mock vs real dependencies, and coverage expectations. Always retain the seed template's "Test-First Development (NON-NEGOTIABLE)" principle verbatim.
5. **Free-text additions**: Prompt user for any additional principles.
6. **Draft and write constitution**: Synthesize scan + Q&A + free-text and write the completed constitution to the resolved `CONSTITUTION` path (beside project.md when in a project, else in the feature dir). Never overwrite the seed template at `.specify/memory/constitution.md`.
7. **Add Sign-Off section** with Pending statuses.
8. Report: "Constitution v1.0.0 created. Proceeding to planning..."
9. Continue to Step 3 (Load context).

**Note**: Phase -1 does NOT run consistency propagation or the sync impact report. For a full validation pass, run `/speckit.constitution` separately.

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Generate Migration Plan**: For each breaking change or new capability:
   - Identify affected consumers (APIs, DB schemas, config formats, user-facing interfaces)
   - Define migration strategy: backwards-compatible rollout, feature flags, deprecation timeline
   - If DB changes: require reversible migrations (up + down)
   - If API changes: define version coexistence period
   - Output to "Migration Plan" section in plan.md

4. **Agent context update**:
   - Run `{AGENT_SCRIPT}`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

**Output**: data-model.md, /contracts/*, quickstart.md, agent-specific file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
