---
description: Establish high-level architectural decisions and overarching implementation principles through interactive codebase scanning and guided Q&A. These directly drive `/speckit.plan` and `/speckit.implement`.
handoffs:
  - label: Build Specification (Stage 1)
    agent: speckit.specify
    prompt: Implement the feature specification based on the updated constitution. I want to build...
  - label: Clarify Spec (Stage 2)
    agent: speckit.clarify
    prompt: Review and clarify the specification
  - label: Create Technical Plan (Stage 4)
    agent: speckit.plan
    prompt: Create a technical plan for the spec. I am building with...
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --paths-only
  ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

You are creating or updating the project constitution. The constitution is stored **beside `project.md`** at `specs/project-<name>/constitution.md` when the work is part of a project; for a standalone feature it lives in the feature directory at `specs/<###-feature>/constitution.md`. The exact target path is resolved for you by the setup script and exposed as the `CONSTITUTION` field (see step 1) — never hardcode it. New constitutions are seeded from the read-only template at `.specify/memory/constitution.md`, which is never overwritten.

The constitution captures **high-level architectural decisions and overarching implementation principles** that directly drive how `/speckit.plan` structures the implementation and how `/speckit.implement` executes it. It goes beyond the agent file (which captures universal product truths) to capture initiative-specific engineering guidance. The seed template contains placeholder tokens in square brackets (e.g. `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`). Your job is to (a) scan the codebase for existing architectural patterns and implementation conventions, (b) run an interactive Q&A to surface decisions and principles that haven't been established yet, (c) draft the constitution as a set of concrete decisions and principles, and (d) propagate amendments across dependent artifacts.

### Workflow Context (Unifyr Process)

This is **Stage 3 (Constitution)** of the Unifyr process:

- **Team**: Engineering
- **Prerequisites**: spec.md from Stage 1, ideally clarified in Stage 2
- **Output**: Finalized constitution.md with high-level architectural decisions and overarching implementation principles that drive planning and implementation
- **Next step**: `/speckit.plan` (Stage 4 - Engineering) — reads the constitution to actively drive technology choices, architecture patterns, testing strategy, and migration approach

Constitution MUST be finalized before `/speckit.plan` can proceed.

### What is a Constitution?

The constitution captures **high-level architectural decisions and overarching implementation principles** for a specific initiative. It is engineering-managed and provides the foundational technical direction that `/speckit.plan` and `/speckit.implement` use as guardrails. Think of it as the engineering DNA — not code standards, but the big decisions and principles that shape everything downstream. It goes beyond the agent file (universal product truths) to capture initiative-specific guidance that the plan and implementation phases actively rely on.

| Aspect | Constitution | Agent File (CLAUDE.md etc.) | Project.md |
|--------|-------------|---------------------------|------------|
| **Scope** | Project/epic set | Entire product/repo | Multi-feature project |
| **Owner** | Engineering | Engineering | Product |
| **About** | Architectural decisions & implementation principles that drive plan & implement | Universal product truths | Universal constraints that bound specifications |
| **Changes** | Per initiative, updated as principles evolve | Rarely, auto-regenerated from plans | Stable after creation |

**Key distinctions**:

- The **agent file** captures universal product architecture that rarely changes (e.g., "We deploy to AWS", "All APIs are REST"). The constitution captures initiative-specific **architectural decisions AND overarching implementation principles** that go beyond those universals to directly shape planning and implementation (e.g., "Library-First architecture", "TDD mandatory", "Integration tests preferred over mocks", "All APIs versioned", "Microservices with event-driven communication").
- **Project.md** captures universal constraints that bound what specifications can include (out-of-scope exclusions, shared constraints, feature list). It is Product-managed and constrains the WHAT. The constitution captures the engineering HOW — the big decisions and principles that `/speckit.plan` translates into concrete technology choices, testing strategy, and phase structure.

**Preparation guidance**: Before drafting a constitution, clean up existing repo documentation first. Document YOUR architectural decisions, not generic best practices. Focus on the big decisions that will directly constrain what `/speckit.plan` generates.

The constitution includes:

- High-level architectural decisions (e.g., monolith vs microservices, module boundaries, API patterns)
- Overarching implementation principles that go beyond the agent file (e.g., testing philosophy, code quality approach, observability strategy)
- Non-negotiable technical constraints and rules
- Definition of done
- AI-specific guidelines
- Governance for how these decisions evolve

Follow this execution flow:

1. **Resolve target path and load base content**: Run `{SCRIPT}` from repo root and parse its output for `CONSTITUTION` (the absolute path this constitution will be written to) and `REPO_ROOT`. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
   - **If the file at `CONSTITUTION` already exists**: load it — you are AMENDING an existing constitution. Preserve prior decisions, version history, and sign-offs unless this run changes them.
   - **Otherwise** (new constitution): load the read-only seed template at `.specify/memory/constitution.md` as the starting structure, then write the result to `CONSTITUTION`.
   - Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`.
   - **Location reminder**: `CONSTITUTION` resolves to `specs/project-<name>/constitution.md` (beside project.md) when the work is part of a project, or `specs/<###-feature>/constitution.md` for a standalone feature. The seed template at `.specify/memory/constitution.md` is never overwritten.
   **IMPORTANT**: The user might require less or more principles than the ones used in the template. If a number is specified, respect that - follow the general template. You will update the doc accordingly.

2. **Codebase scan**: Scan the repository root for existing architectural patterns, implementation conventions, and technical decisions across 10 categories. The goal is to understand what architectural decisions and implementation principles have **already been established** (implicitly or explicitly) so the Q&A can focus on gaps. For each category, check for the listed file patterns and classify as **Detected** (strong signals found, can draft an architectural decision), **Partial** (some signals but the decision isn't clear), or **No Signal** (no decision evident, need to ask).

   | # | Category | Scan Targets |
   |---|----------|-------------|
   | 1 | Testing Philosophy | Test runner configs (`jest.config.*`, `vitest.config.*`, `pytest.ini`, `setup.cfg [tool:pytest]`, `.nycrc`, `karma.conf.*`), test directories and structure (colocated vs separate), coverage thresholds in CI configs, TDD signals (`test:watch` scripts, test-first commit patterns), mock libraries vs real-dependency patterns (testcontainers, docker-compose test profiles), CI test gates (required checks, coverage enforcement) |
   | 2 | Code Quality & Standards | `.eslintrc*`, `.prettierrc*`, `ruff.toml`, `pyproject.toml [tool.ruff]`, `.editorconfig`, `.golangci.yml`, `Makefile` lint targets |
   | 3 | Architecture & Modularity | `package.json` workspaces, `nx.json`, `turbo.json`, `Cargo.toml` workspace, `go.work`, monorepo vs single-package signals |
   | 4 | Observability & Debugging | Logging library deps (`winston`, `pino`, `structlog`, `slog`), APM deps (`datadog`, `newrelic`, `opentelemetry`), Sentry/Bugsnag configs |
   | 5 | CI/CD & Deployment | `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `Dockerfile*`, `docker-compose.yml`, `k8s/`, `terraform/`, `Procfile` |
   | 6 | Security & Compliance | `.env.example`, `vault` references, SAST/DAST tool configs (`.snyk`, `.trivyignore`), OAuth/JWT library deps, GDPR/SOC2 references in docs |
   | 7 | Versioning & Breaking Changes | `CHANGELOG.md`, version fields in manifests, `.changeset/`, `semantic-release` config, `.releaserc*`, API version prefixes in routes |
   | 8 | Simplicity & Constraints | Dependency count, lock file presence, `renovate.json`, `dependabot.yml`, explicit deny lists in docs |
   | 9 | Migration & Compatibility | API version prefixes in routes, DB migration directories (`migrations/`, `alembic/`, `db/migrate/`), deprecation notices in docs, feature flag libraries |
   | 10 | Internationalisation (i18n) | Locale directories, translation files (`.po`, `.json`, `.yaml` in `locales/`), string externalisation patterns, AI translation pipeline configs |

   Present results to the user:

   ```markdown
   ## Codebase Scan Results

   I scanned your repository for existing architectural patterns, implementation conventions, and technical decisions. Here's what I found:

   | Category | Status | Architectural Decision Inferred |
   |----------|--------|-------------------------------|
   | Testing Philosophy | [status] | [decision inferred or gap identified] |
   | Code Quality & Standards | [status] | [decision inferred or gap identified] |
   | ... | ... | ... |

   I'll ask questions to surface the architectural decisions and implementation principles that aren't clear yet.
   ```

3. **Interactive Q&A loop**: Generate and ask targeted questions to surface architectural decisions and implementation principles that haven't been established yet. The goal is to produce concrete decisions and principles that `/speckit.plan` actively uses to drive technology choices, architecture patterns, testing strategy, and migration approach — not abstract guidance, but specific technical direction (e.g., "PostgreSQL for all persistent storage", "Library-First with max 3 projects", "TDD mandatory with 80% coverage gate", "Integration tests preferred over mocks").

   **3a. Generate question queue** (internal, not shown to user):
   - For each category with status **Partial** or **No Signal**: generate a question.
   - For each **Detected** category with material ambiguity (e.g., coverage set to 80% but no TDD enforcement level): generate a confirmation question.
   - Rank by `Impact * Uncertainty` (Testing > Security > Architecture > CI/CD > Quality > Migration > i18n > Observability > Versioning > Simplicity as default priority, adjustable by context).
   - Select top **8** questions maximum. If more remain, defer lowest-priority to "Deferred" with rationale.

   **Critical: Testing Philosophy is FIXED — strict TDD is mandatory and NON-NEGOTIABLE.** This fork enforces strict Test-Driven Development across the entire pipeline: `/speckit.tasks` always orders test tasks before their implementation tasks, and `/speckit.implement` always follows red-green-refactor (write failing tests → confirm RED → implement to GREEN → refactor). **Do NOT ask the user whether to use TDD, test-alongside, or test-after — the test-timing decision is already made.** Every constitution MUST carry a "Test-First Development (NON-NEGOTIABLE)" principle stating this; the seed template already includes it as a fixed principle, so retain it verbatim (do not turn it back into an open question).

   The testing question(s) you DO ask cover only the dimensions that remain open *within* strict TDD:
   - **Test type preference**: Unit tests, integration tests, contract tests, or a specific mix
   - **Mock vs real dependencies**: Mock-heavy isolation or real-dependency testing (testcontainers, docker-compose)
   - **Coverage expectations**: Specific thresholds or qualitative gates (e.g., "80% line coverage", "all public APIs tested")

   If the scan detected test tooling, confirm the test-type/mocking/coverage choices above — never re-open the test-timing decision. Example question: "Within our mandatory TDD workflow, what should tests emphasise?" with options like "A: Integration-first — real dependencies, contract tests before unit tests", "B: Unit-first — fast isolated unit tests with mocks, integration tests for critical paths", "C: Balanced mix with an explicit coverage gate".

   **3b. Sequential questioning** (interactive, EXACTLY ONE question at a time):

   For **multiple-choice questions** (2-5 distinct, mutually exclusive options):
   - Identify the **most suitable option** based on best practices, project patterns, risk reduction, and codebase signals.
   - Present: `**Recommended:** Option [X] - <reasoning (1-2 sentences)>`
   - Render all options in a Markdown table with Option, Description columns.
   - Include row: `Short | Provide a different short answer (<=5 words)`
   - Add: "You can reply with the option letter (e.g., 'A'), accept the recommendation by saying 'yes' or 'recommended', or provide your own short answer."

   For **short-answer questions**:
   - Present: `**Suggested:** <proposed answer> - <brief reasoning>`
   - Output: "Format: Short answer (<=5 words). You can accept the suggestion by saying 'yes' or 'suggested', or provide your own answer."

   **Answer validation**:
   - If user replies "yes", "recommended", or "suggested": use the recommendation as the answer.
   - Otherwise validate the answer maps to an option or fits <=5 word constraint.
   - If ambiguous, ask for quick disambiguation (does NOT count as a new question).
   - Once satisfactory, record in **working memory** (do NOT write to disk yet).

   **Stop conditions** (exit loop when ANY is true):
   - All queued questions have been asked.
   - User signals completion ("done", "good", "no more", "proceed").
   - All critical ambiguities are resolved early.
   - Maximum of 8 questions reached.

   Never reveal future queued questions in advance.

   **3c. Free-text additions prompt** (always offered, even if Q&A stopped early):

   ```markdown
   ## Additional Principles

   The guided questions covered the core categories. Do you have any additional
   principles, rules, or constraints you want to add to the constitution?

   You can:
   - Type one or more principles in your own words (I'll integrate them)
   - Say "none" or "done" to proceed with what we have

   Examples: "All database migrations must be reversible",
   "No third-party analytics SDKs", "Every PR requires senior approval"
   ```

   Classify each free-text principle into the best-fit constitution section (Core Principles for non-negotiables, Section 2/3 for constraints or workflow rules, Governance for procedural rules).

4. **Draft the constitution** (focus: concrete architectural decisions and implementation principles, not abstract guidance):
   - Synthesize from four sources (in priority order):
     a. User input from `$ARGUMENTS` (if any)
     b. Q&A answers (for Partial/No Signal categories)
     c. Codebase scan inferences (for Detected categories)
     d. Free-text additions (user-authored decisions and principles)
     e. Repo context (README, docs) as fallback
   - Replace every placeholder with concrete text (no bracketed tokens left except intentionally retained—explicitly justify any left).
   - Frame each section as an **architectural decision or implementation principle** — something specific enough for `/speckit.plan` to actively use when making technology choices, structuring architecture, designing tests, and planning migrations. Good: "All persistent storage uses PostgreSQL with Alembic migrations". Bad: "Use appropriate database technology". Good: "Library-First — every feature starts as a standalone library with CLI interface". Bad: "Keep things modular". Good: "Integration tests preferred over mocks; real databases in test environments". Bad: "Write good tests".
   - Remember: the constitution captures engineering guidance that goes **beyond** what's in the agent file. The agent file has universal product truths; the constitution adds initiative-specific decisions and principles.
   - Determine number of Core Principles based on Q&A results (may be 3-10, not locked to 5).
   - Map taxonomy categories to constitution sections:
     - Categories 1-5 → Core Principles (testing, quality, architecture, observability, CI/CD)
     - Categories 6-8 → Section 2 (security, versioning, simplicity as constraints)
     - Categories 9-10 → Section 2 or 3 (migration, i18n as workflow rules)
     - Governance always fills the Governance section
   - Preserve heading hierarchy; comments can be removed once replaced.
   - Ensure each Principle section: succinct name, paragraph or bullet list of non-negotiable decisions, explicit rationale if not obvious.
   - Ensure Governance section lists amendment procedure, versioning policy, and compliance review expectations.
   - For governance dates: `RATIFICATION_DATE` = today for new constitutions, `LAST_AMENDED_DATE` = today.
   - `CONSTITUTION_VERSION` must increment per semantic versioning:
     - MAJOR: Backward incompatible governance/principle removals or redefinitions.
     - MINOR: New principle/section added or materially expanded guidance.
     - PATCH: Clarifications, wording, typo fixes, non-semantic refinements.

5. **Consistency propagation checklist** (convert to active validations):
   - Read `/templates/plan-template.md` and ensure any "Constitution Check" or rules align with updated principles.
   - Read `/templates/spec-template.md` for scope/requirements alignment—update if constitution adds/removes mandatory sections or constraints.
   - Read `/templates/tasks-template.md` and ensure task categorization reflects new or removed principle-driven task types (e.g., observability, versioning, testing discipline).
   - Read each command file in `/templates/commands/*.md` (including this one) to verify no outdated references remain.
   - Read any runtime guidance docs (e.g., `README.md`, `docs/quickstart.md`, or agent-specific guidance files if present). Update references to principles changed.

6. **Produce a Sync Impact Report** (prepend as an HTML comment at top of the constitution file after update):
   - Version change: old → new
   - List of modified principles (old title → new title if renamed)
   - Added sections
   - Removed sections
   - Templates requiring updates (✅ updated / ⚠ pending) with file paths
   - Follow-up TODOs if any placeholders intentionally deferred.

7. **Validation before final output**:
   - No remaining unexplained bracket tokens.
   - Version line matches report.
   - Dates ISO format YYYY-MM-DD.
   - Principles are declarative, testable, and free of vague language ("should" → replace with MUST/SHOULD rationale where appropriate).

8. **Write** the completed constitution to the resolved `CONSTITUTION` path (overwrite). Create the parent directory if it does not yet exist. **Never write to the seed template at `.specify/memory/constitution.md`** — it stays pristine so future constitutions can be seeded from it.

9. **Add Sign-Off section** (if not present) to track team approvals:

   ```markdown
   ## Sign-Off

   | Stage | Team | Approver | Date | Status |
   |-------|------|----------|------|--------|
   | Draft | Product | | | Pending |
   | Review | Engineering | | | Pending |
   | Review | QA | | | Pending |
   | Final Sign-Off | All | | | Pending |
   ```

10. **Completion report**: Output a final summary to the user with:
    - New version and bump rationale.
    - Q&A summary: N questions asked, M answered, K free-text additions.
    - Coverage summary table (all 10 categories with status: Resolved, Deferred, Clear, Outstanding).
    - Any files flagged for manual follow-up.
    - Sign-Off status (all Pending for new constitutions)
    - If Outstanding or Deferred remain, recommend running `/speckit.constitution` again.
    - Reminder: Constitution must be signed off before `/speckit.plan` can proceed — the plan actively uses these architectural decisions and implementation principles to drive technology choices, architecture patterns, testing strategy, and migration approach.
    - Suggested next command: `/speckit.plan` (Stage 4) — will use the constitution to actively drive the plan, not just check compliance.
    - Suggested commit message (e.g., `docs: amend constitution to vX.Y.Z (principle additions + governance update)`).

Formatting & Style Requirements:

- Use Markdown headings exactly as in the template (do not demote/promote levels).
- Wrap long rationale lines to keep readability (<100 chars ideally) but do not hard enforce with awkward breaks.
- Keep a single blank line between sections.
- Avoid trailing whitespace.

If the user supplies partial updates (e.g., only one principle revision), still perform validation and version decision steps.

If critical info missing (e.g., ratification date truly unknown), insert `TODO(<FIELD_NAME>): explanation` and include in the Sync Impact Report under deferred items.

Do not create a new template; always write to the resolved `CONSTITUTION` path. The seed template at `.specify/memory/constitution.md` is read-only — copy from it when creating a new constitution, but never overwrite it.
