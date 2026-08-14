---
description: Agree the big technical decisions for this piece of work, so `/speckit.plan` and `/speckit.implement` follow them. It scans your codebase, then asks a few guided questions to fill the gaps.
handoffs:
  - label: Build Specification (Stage 1)
    agent: speckit.specify
    prompt: Implement the feature specification based on the updated charter. I want to build...
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

## Voice & Audience

Everything you say to the user and write into the charter is read by a **mixed team**: engineers, product owners, and QA. Write plainly:

- Short, direct sentences. One point per sentence.
- No waffle, filler, or flowery prose. Cut any word that does not change the meaning.
- No metaphors or grand phrasing ("engineering DNA", "foundational technical direction", "guardrails"). State the plain fact.
- Be unambiguous: each sentence should have one possible reading.
- When a technical term is unavoidable, say what it means the first time you use it.
- Keep the decisions themselves precise. This is about wording, not about dropping detail.

## Outline

You are creating or updating the Engineering Charter. The charter is stored **beside `project.md`** at `specs/project-<name>/charter.md` when the work is part of a project; for a standalone feature it lives in the feature directory at `specs/<###-feature>/charter.md`. The exact target path is resolved for you by the setup script and exposed as the `CHARTER` field (see step 1) — never hardcode it. New charters are seeded from the read-only template at `memory/charter.md`, which is never overwritten.

> **Naming note**: the Engineering Charter was formerly called the "constitution". The `/speckit.constitution` command still works as a deprecated alias, and the setup script also exposes the path as `CONSTITUTION` for back-compat, but `charter` / `CHARTER` / `charter.md` are the current names. Repos created before the rename may still have a legacy `constitution.md` — the setup script resolves to it automatically when no `charter.md` exists yet.

The charter captures **high-level architectural decisions and overarching implementation principles** that directly drive how `/speckit.plan` structures the implementation and how `/speckit.implement` executes it. It goes beyond the agent file (which captures universal product truths) to capture initiative-specific engineering guidance. The seed template contains placeholder tokens in square brackets (e.g. `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`). Your job is to (a) scan the codebase for existing architectural patterns and implementation conventions, (b) run an interactive Q&A to surface decisions and principles that haven't been established yet, (c) draft the charter as a set of concrete decisions and principles, and (d) propagate amendments across dependent artifacts.

### Workflow Context (Unifyr Process)

This is **Stage 3 (Charter)** of the Unifyr process:

- **Team**: Engineering
- **Prerequisites**: spec.md from Stage 1, ideally clarified in Stage 2
- **Output**: Finalized charter.md with high-level architectural decisions and overarching implementation principles that drive planning and implementation
- **Next step**: `/speckit.plan` (Stage 4 - Engineering) — reads the charter to actively drive technology choices, architecture patterns, and migration approach

A finalized charter is required before `/speckit.plan` can produce a plan. Running this command (Stage 3) is the recommended path, but it is not mandatory beforehand — if you skip straight to `/speckit.plan`, it will create a charter inline (Phase -1) before planning proceeds.

### What is an Engineering Charter?

The charter records the **big technical decisions** for this piece of work — for example, "store data in PostgreSQL" or "every API gets a version number". It is not a code style guide. It is the small set of choices that the plan and the build must follow. Both `/speckit.plan` and `/speckit.implement` read it and stick to it. It covers only decisions specific to *this* work. Product-wide facts that rarely change live in the agent file (CLAUDE.md), not here.

| Aspect | Engineering Charter | Agent File (CLAUDE.md etc.) | Project.md |
|--------|-------------|---------------------------|------------|
| **Scope** | Project/epic set | Entire product/repo | Multi-feature project |
| **Owner** | Engineering | Engineering | Product |
| **About** | The big technical decisions the plan and build follow | Facts about the product that rarely change | Limits every spec has to stay inside |
| **Changes** | Per initiative, updated as principles evolve | Rarely, auto-regenerated from plans | Stable after creation |

**Key distinctions**:

- The **agent file** holds product-wide facts that rarely change (e.g., "We deploy to AWS", "All APIs are REST"). The charter holds the decisions specific to *this* work that go beyond those (e.g., "Library-First architecture", "Prefer integration tests over mocks", "All APIs versioned", "Microservices talking over events").
- **Project.md** lists the limits every spec has to stay inside (what's out of scope, shared constraints, the feature list). Product owns it, and it shapes *what* gets built. The charter covers the engineering side — *how* it gets built — which `/speckit.plan` then turns into concrete technology choices and a phase plan.

**Testing is deliberately NOT a charter concern.** Strict TDD is a **pipeline invariant** enforced by `/speckit.tasks` and `/speckit.implement` (test tasks ordered first; red-green-refactor), independent of the charter. Do NOT add testing principles or ask testing questions here. Test type/coverage emphasis, where it matters, is applied as a sensible default at plan/tasks time or surfaced through `/speckit.clarify`.

**Preparation guidance**: Before drafting a charter, clean up existing repo documentation first. Document YOUR architectural decisions, not generic best practices. Focus on the big decisions that will directly constrain what `/speckit.plan` generates.

The charter includes:

- High-level architectural decisions (e.g., monolith vs microservices, module boundaries, API patterns)
- Overarching implementation principles that go beyond the agent file (e.g., code quality approach, observability strategy)
- Non-negotiable technical constraints and rules
- Definition of done
- AI-specific guidelines
- Governance for how these decisions evolve

Follow this execution flow:

1. **Resolve target path and load base content**: Run `{SCRIPT}` from repo root and parse its output for `CHARTER` (the absolute path this charter will be written to) and `REPO_ROOT`. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").
   - **If the file at `CHARTER` already exists**: load it — you are AMENDING an existing charter. Preserve prior decisions, version history, and sign-offs unless this run changes them.
   - **Otherwise** (new charter): load the read-only seed template at `memory/charter.md` as the starting structure, then write the result to `CHARTER`.
   - Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`.
   - **Location reminder**: `CHARTER` resolves to `specs/project-<name>/charter.md` (beside project.md) when the work is part of a project, or `specs/<###-feature>/charter.md` for a standalone feature. The seed template at `memory/charter.md` is never overwritten.
   **IMPORTANT**: The user might require less or more principles than the ones used in the template. If a number is specified, respect that - follow the general template. You will update the doc accordingly.

2. **Codebase scan**: Scan the repository root for existing architectural patterns, implementation conventions, and technical decisions across 10 categories. The goal is to understand what architectural decisions and implementation principles have **already been established** (implicitly or explicitly) so the Q&A can focus on gaps. For each category, check for the listed file patterns and classify as **Detected** (strong signals found, can draft an architectural decision), **Partial** (some signals but the decision isn't clear), or **No Signal** (no decision evident, need to ask).

   | # | Category | Scan Targets |
   |---|----------|-------------|
   | 1 | Code Quality & Standards | `.eslintrc*`, `.prettierrc*`, `ruff.toml`, `pyproject.toml [tool.ruff]`, `.editorconfig`, `.golangci.yml`, `Makefile` lint targets |
   | 2 | Architecture & Modularity | `package.json` workspaces, `nx.json`, `turbo.json`, `Cargo.toml` workspace, `go.work`, monorepo vs single-package signals |
   | 3 | Observability & Debugging | Logging library deps (`winston`, `pino`, `structlog`, `slog`), APM deps (`datadog`, `newrelic`, `opentelemetry`), Sentry/Bugsnag configs |
   | 4 | CI/CD & Deployment | `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, `Dockerfile*`, `docker-compose.yml`, `k8s/`, `terraform/`, `Procfile` |
   | 5 | Security & Compliance | `.env.example`, `vault` references, SAST/DAST tool configs (`.snyk`, `.trivyignore`), OAuth/JWT library deps, GDPR/SOC2 references in docs |
   | 6 | Versioning & Breaking Changes | `CHANGELOG.md`, version fields in manifests, `.changeset/`, `semantic-release` config, `.releaserc*`, API version prefixes in routes |
   | 7 | Simplicity & Constraints | Dependency count, lock file presence, `renovate.json`, `dependabot.yml`, explicit deny lists in docs |
   | 8 | Migration & Compatibility | API version prefixes in routes, DB migration directories (`migrations/`, `alembic/`, `db/migrate/`), deprecation notices in docs, feature flag libraries |
   | 9 | Internationalisation (i18n) | Locale directories, translation files (`.po`, `.json`, `.yaml` in `locales/`), string externalisation patterns, AI translation pipeline configs |
   | 10 | UX & Design Inputs | Component library / design-system signals (`.storybook/`, design tokens, `tailwind.config.*`, theme files, `components/ui`), accessibility linters (`eslint-plugin-jsx-a11y`, `axe`), design-file references (e.g. Figma links in README/docs). **Figma/design-file supply is OPTIONAL** — many features (APIs, backend, infra, refactors) have no design surface; classify **No Signal** and move on. |

   Present results to the user:

   ```markdown
   ## What I found in your codebase

   I looked through your code for decisions you've already made. Here's what I found:

   | Area | Status | What I found (or what's missing) |
   |----------|--------|-------------------------------|
   | Code Quality & Standards | [status] | [what I found, or the gap] |
   | Architecture & Modularity | [status] | [what I found, or the gap] |
   | ... | ... | ... |

   Where something isn't clear yet, I'll ask you about it.
   ```

3. **Interactive Q&A loop**: Generate and ask targeted questions to surface architectural decisions and implementation principles that haven't been established yet. The goal is to produce concrete decisions and principles that `/speckit.plan` actively uses to drive technology choices, architecture patterns, and migration approach — not abstract guidance, but specific technical direction (e.g., "PostgreSQL for all persistent storage", "Library-First with max 3 projects", "Integration tests preferred over mocks", "Design system: internal component library is the source of truth").

   **3a. Generate question queue** (internal, not shown to user):
   - For each category with status **Partial** or **No Signal**: generate a question.
   - For each **Detected** category with material ambiguity: generate a confirmation question.
   - Rank by `Impact * Uncertainty` (Security > Architecture > CI/CD > Quality > UX & Design Inputs > Migration > i18n > Observability > Versioning > Simplicity as default priority, adjustable by context).
   - Select top **8** questions maximum. If more remain, defer lowest-priority to "Deferred" with rationale.

   **Do NOT ask about testing.** Testing is not a charter category — strict TDD is a pipeline invariant owned by `/speckit.tasks` and `/speckit.implement`. Never add a testing principle to the charter or ask the user about test timing, type, mocking, or coverage.

   **UX & Design Inputs — treat as optional.** Only ask if the feature/initiative has a user-facing surface. A valid, encouraged answer is "no UI / not applicable". When it does apply, the question covers: which component library or design system is the source of truth, where design assets come from and the handoff process (Figma is one option, not a requirement), and the accessibility standard to hold to.

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
   ## Anything to add?

   That covers the main areas. Anything else to add — a rule, a limit, or a principle?

   - Type one or more in your own words and I'll include them.
   - Say "none" or "done" to move on.

   Examples: "All database migrations must be reversible",
   "No third-party analytics SDKs", "Every PR needs a senior review"
   ```

   Classify each free-text principle into the best-fit charter section (Core Principles for non-negotiables, Section 2/3 for constraints or workflow rules, Governance for procedural rules).

4. **Draft the charter** (focus: concrete architectural decisions and implementation principles, not abstract guidance):
   - Synthesize from four sources (in priority order):
     a. User input from `$ARGUMENTS` (if any)
     b. Q&A answers (for Partial/No Signal categories)
     c. Codebase scan inferences (for Detected categories)
     d. Free-text additions (user-authored decisions and principles)
     e. Repo context (README, docs) as fallback
   - Replace every placeholder with concrete text (no bracketed tokens left except intentionally retained—explicitly justify any left).
   - Frame each section as an **architectural decision or implementation principle** — something specific enough for `/speckit.plan` to actively use when making technology choices, structuring architecture, and planning migrations. Good: "All persistent storage uses PostgreSQL with Alembic migrations". Bad: "Use appropriate database technology". Good: "Library-First — every feature starts as a standalone library with CLI interface". Bad: "Keep things modular".
   - Remember: the charter captures engineering guidance that goes **beyond** what's in the agent file. The agent file has universal product truths; the charter adds initiative-specific decisions and principles.
   - Determine number of Core Principles based on Q&A results (may be 3-10, not locked to 5).
   - Map taxonomy categories to charter sections:
     - Core Principles → code quality, architecture, observability, CI/CD, UX & design inputs
     - Section 2 (constraints) → security, versioning, simplicity
     - Section 2 or 3 (workflow rules) → migration, i18n
     - Governance always fills the Governance section
   - Preserve heading hierarchy; comments can be removed once replaced.
   - Ensure each Principle section: succinct name, paragraph or bullet list of non-negotiable decisions, explicit rationale if not obvious.
   - Ensure Governance section lists amendment procedure, versioning policy, and compliance review expectations.
   - For governance dates: `RATIFICATION_DATE` = today for new charters, `LAST_AMENDED_DATE` = today.
   - `CHARTER_VERSION` must increment per semantic versioning:
     - MAJOR: Backward incompatible governance/principle removals or redefinitions.
     - MINOR: New principle/section added or materially expanded guidance.
     - PATCH: Clarifications, wording, typo fixes, non-semantic refinements.

5. **Consistency propagation checklist** (convert to active validations):
   - Read `/templates/plan-template.md` and ensure any "Charter Check" or rules align with updated principles.
   - Read `/templates/spec-template.md` for scope/requirements alignment—update if charter adds/removes mandatory sections or constraints.
   - Read `/templates/tasks-template.md` and ensure task categorization reflects new or removed principle-driven task types (e.g., observability, versioning).
   - Read each command file in `/templates/commands/*.md` (including this one) to verify no outdated references remain.
   - Read any runtime guidance docs (e.g., `README.md`, `docs/quickstart.md`, or agent-specific guidance files if present). Update references to principles changed.

6. **Produce a Sync Impact Report** (prepend as an HTML comment at top of the charter file after update):
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

8. **Write** the completed charter to the resolved `CHARTER` path (overwrite). Create the parent directory if it does not yet exist. **Never write to the seed template at `memory/charter.md`** — it stays pristine so future charters can be seeded from it.

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
    - Sign-Off status (all Pending for new charters)
    - If Outstanding or Deferred remain, recommend running `/speckit.charter` again.
    - Reminder: the charter needs sign-off before `/speckit.plan` can run — the plan reads these decisions to choose the technology, shape the architecture, and plan any migration.
    - Suggested next command: `/speckit.plan` (Stage 4) — it builds the plan around the charter, not just a compliance check against it.
    - Suggested commit message (e.g., `docs: amend charter to vX.Y.Z (principle additions + governance update)`).

Formatting & Style Requirements:

- Use Markdown headings exactly as in the template (do not demote/promote levels).
- Wrap long rationale lines to keep readability (<100 chars ideally) but do not hard enforce with awkward breaks.
- Keep a single blank line between sections.
- Avoid trailing whitespace.

If the user supplies partial updates (e.g., only one principle revision), still perform validation and version decision steps.

If critical info missing (e.g., ratification date truly unknown), insert `TODO(<FIELD_NAME>): explanation` and include in the Sync Impact Report under deferred items.

Do not create a new template; always write to the resolved `CHARTER` path. The seed template at `memory/charter.md` is read-only — copy from it when creating a new charter, but never overwrite it.
