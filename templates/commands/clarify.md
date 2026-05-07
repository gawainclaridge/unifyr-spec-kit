---
description: Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.
handoffs:
  - label: Create Constitution (Stage 3)
    agent: speckit.constitution
    prompt: Create project constitution with principles for...
  - label: Build Technical Plan (Stage 4)
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
scripts:
   sh: scripts/bash/check-prerequisites.sh --json --paths-only
   ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

### Workflow Context (Unifyr Process)

This is **Stage 2 (Review)** of the Unifyr process:
- **Teams**: Product, Engineering, QA (cross-functional)
- **Purpose**: Analyze spec for gaps, add edge cases, clarify ambiguities
- **Prerequisites**: Completed spec.md from Stage 1
- **Output**: Clarified spec ready for planning
- **Next step**: `/speckit.constitution` (Stage 3 - Engineering) or `/speckit.plan` (Stage 4)

## Outline

Goal: Detect and reduce ambiguity or missing decision points in the active feature specification and record the clarifications directly in the spec file.

Note: This clarification workflow is expected to run (and be completed) BEFORE invoking `/speckit.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

Execution steps:

1. Run `{SCRIPT}` from repo root **once** (combined `--json --paths-only` mode / `-Json -PathsOnly`). Parse minimal JSON payload fields:
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - (Optionally capture `IMPL_PLAN`, `TASKS` for future chained flows.)
   - If JSON parsing fails, abort and instruct user to re-run `/speckit.specify` or verify feature branch environment.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check for project context**: Determine if feature is part of a project
   - Check if current directory is under `specs/project-<name>/`
   - If project.md exists, load project context:
     - **Out of Scope** → Don't flag items as unclear if they're defined as out-of-scope at project level
     - **Shared Constraints** → Reference project constraints when analyzing spec gaps
     - **Target Users** → Don't ask clarifying questions about users if defined at project level
   - Use project context to reduce redundant clarification questions

3. Load the current spec file. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: Clear / Partial / Missing. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).
   - **Experience Vision gate (BLOCKING)**: Check that the spec contains a completed `## Experience Vision` section with a narrative paragraph (not placeholder text). If missing or still contains placeholder text like "[Write the experience vision here":
     - Do NOT proceed with the ambiguity scan.
     - Inform the user: "Experience Vision is missing. This is the north star that both engineering and Product hold up at sprint review — without it, clarification has no anchor. Please describe what success feels like from the customer's perspective (3-5 sentences, plain language, not AC or user stories)."
     - Wait for the user's response.
     - Write their response into the `## Experience Vision` section of the spec, replacing the placeholder.
     - Then proceed with the rest of the clarify workflow.
   - **Project-aware scanning**: If project.md was loaded, consider project-level definitions as "Clear" for spec-level scanning

   Functional Scope & Behavior:
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation

   Domain & Data Model:
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

   Interaction & UX Flow:
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization notes

   Non-Functional Quality Attributes:
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery expectations)
   - Security & privacy (authN/Z, data protection, threat assumptions)
   - Compliance / regulatory constraints (if any)

   Observability & Telemetry (MUST ASK while Partial/Missing — see step 4a):
   - Product analytics events (user-visible actions, naming convention)
   - Structured log fields (required fields, PII redaction)
   - Metrics (counters, histograms for ops visibility)
   - Traces (span names, propagation)
   - Audit trail (immutable state-change records, if applicable)
   - Dashboards (existing dashboard target, or new dashboard need)
   - NOTE: SLOs and alert thresholds are deliberately excluded — they are owned
     by the regression process, not feature specs.

   Integration & External Dependencies:
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions

   Edge Cases & Failure Handling:
   - Negative scenarios
   - Rate limiting / throttling
   - Conflict resolution (e.g., concurrent edits)

   Constraints & Tradeoffs:
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives

   Terminology & Consistency:
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms

   Completion Signals:
   - Acceptance criteria testability
   - Measurable Definition of Done style indicators

   Misc / Placeholders:
   - TODO markers / unresolved decisions
   - Ambiguous adjectives ("robust", "intuitive") lacking quantification

   For each category with Partial or Missing status, add a candidate question opportunity unless:
   - Clarification would not materially change implementation or validation strategy
   - Information is better deferred to planning phase (note internally)

4. Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Do NOT output them all at once. Apply these constraints:
    - Maximum of 10 total questions across the whole session.
    - Each question must be answerable with EITHER:
       - A short multiple‑choice selection (2–5 distinct, mutually exclusive options), OR
       - A one-word / short‑phrase answer (explicitly constrain: "Answer in <=5 words"), OR
       - An **example-led reaction** (see step 4a) — present feature-specific examples in a table and ask the team which apply / what to add / what to remove.
    - Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation.
    - Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., security posture) is unresolved.
    - Exclude questions already answered, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
    - Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests.
    - If more than 5 categories remain unresolved, select the top 5 by (Impact * Uncertainty) heuristic.

4a. **Must-ask categories** (override the impact-ranking above): some categories are easy for the team to overlook and MUST be asked while their spec section is still placeholder text or genuinely Partial/Missing. They reserve a slot in the queue ahead of impact-ranked questions. Clarify is run iteratively, so a must-ask question that doesn't fit in this session will surface in the next run until the section is populated.

    Current must-ask categories:

    - **Observability & Telemetry** — check the spec's `## Observability & Telemetry` section. If the buckets still contain `[Populated during /speckit.clarify]` or are empty, ask the example-led observability question below.

    **Example-led question format** (for unfamiliar topics like observability where the team is new to the domain): rather than asking blank-slate questions ("name your telemetry events"), generate concrete examples derived from THIS feature's domain and ask the team to react. Treat "we don't need this bucket" as a valid, encouraged answer when justified.

    Observability question template — generate buckets specific to the feature being specified, not generic boilerplate:

    ```markdown
    ## Question [N]: Observability & Telemetry

    **Why we're asking**: This is easy to overlook and expensive to retrofit. The goal here is to surface what we'd want to *see in production* for this feature. Skip any bucket that genuinely doesn't apply — just say so with a one-line reason.

    Below are likely telemetry items for this feature. Which apply? What's missing? What should be removed?

    | Bucket | Proposed (specific to this feature) |
    |--------|-------------------------------------|
    | Product analytics events | e.g. `<Object> <Verbed>` with properties [...] (derived from primary user actions in spec) |
    | Structured log fields | e.g. `tenant_id`, `user_id`, `feature=<feature_name>` on every log line |
    | Metrics | e.g. counter `<feature>_<action>_total{...}`, histogram `<feature>_<operation>_ms` |
    | Traces | e.g. span `<feature>.<primary_operation>`, parent inherited from inbound HTTP trace |
    | Audit trail | e.g. <state-change> persisted with actor + before/after + reason — or "N/A: <reason>" |
    | Dashboards | e.g. new row on `<existing-dashboard-name>`, or "no new dashboard, joins existing X" |

    **NOTE**: SLOs and alert thresholds are intentionally excluded — those are owned by the regression process.

    **How to answer**: A free-form reply works. You can say things like "events look right, drop the audit trail bucket, add a metric for X", or paste an edited version of the table.
    ```

    When integrating the answer (per step 6), replace the placeholders in the spec's `## Observability & Telemetry` subsections with the agreed items. If a bucket is dropped, leave it as `N/A: <reason from team>` rather than removing the heading.

5. Sequential questioning loop (interactive):
    - Present EXACTLY ONE question at a time.
    - For multiple‑choice questions:
       - **Analyze all options** and determine the **most suitable option** based on:
          - Best practices for the project type
          - Common patterns in similar implementations
          - Risk reduction (security, performance, maintainability)
          - Alignment with any explicit project goals or constraints visible in the spec
       - Present your **recommended option prominently** at the top with clear reasoning (1-2 sentences explaining why this is the best choice).
       - Format as: `**Recommended:** Option [X] - <reasoning>`
       - Then render all options as a Markdown table:

       | Option | Description |
       |--------|-------------|
       | A | <Option A description> |
       | B | <Option B description> |
       | C | <Option C description> (add D/E as needed up to 5) |
       | Short | Provide a different short answer (<=5 words) (Include only if free-form alternative is appropriate) |

       - After the table, add: `You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes" or "recommended", or provide your own short answer.`
    - For short‑answer style (no meaningful discrete options):
       - Provide your **suggested answer** based on best practices and context.
       - Format as: `**Suggested:** <your proposed answer> - <brief reasoning>`
       - Then output: `Format: Short answer (<=5 words). You can accept the suggestion by saying "yes" or "suggested", or provide your own answer.`
    - After the user answers:
       - If the user replies with "yes", "recommended", or "suggested", use your previously stated recommendation/suggestion as the answer.
       - Otherwise, validate the answer maps to one option or fits the <=5 word constraint.
       - If ambiguous, ask for a quick disambiguation (count still belongs to same question; do not advance).
       - Once satisfactory, record it in working memory (do not yet write to disk) and move to the next queued question.
    - Stop asking further questions when:
       - All critical ambiguities resolved early (remaining queued items become unnecessary), OR
       - User signals completion ("done", "good", "no more"), OR
       - You reach 5 asked questions.
    - Never reveal future queued questions in advance.
    - If no valid questions exist at start, immediately report no critical ambiguities.

6. Integration after EACH accepted answer (incremental update approach):
    - Maintain in-memory representation of the spec (loaded once at start) plus the raw file contents.
    - For the first integrated answer in this session:
       - Ensure a `## Clarifications` section exists (create it just after the highest-level contextual/overview section per the spec template if missing).
       - Under it, create (if not present) a `### Session YYYY-MM-DD` subheading for today.
    - Append a bullet line immediately after acceptance: `- Q: <question> → A: <final answer>`.
    - Then immediately apply the clarification to the most appropriate section(s):
       - Functional ambiguity → Update or add a bullet in Functional Requirements.
       - User interaction / actor distinction → Update User Stories or Actors subsection (if present) with clarified role, constraint, or scenario.
       - Data shape / entities → Update Data Model (add fields, types, relationships) preserving ordering; note added constraints succinctly.
       - Non-functional constraint → Add/modify measurable criteria in Non-Functional / Quality Attributes section (convert vague adjective to metric or explicit target).
       - Observability & telemetry answer → Update the matching subsections under `## Observability & Telemetry`: Product Analytics Events, Structured Log Fields, Metrics, Traces, Audit Trail, Dashboards. Replace the `[Populated during /speckit.clarify]` placeholders with the agreed items. For dropped buckets, write `- N/A: <reason from team>` rather than removing the subsection. Also append the Q→A bullet under `## Clarifications` per the standard pattern.
       - Edge case / negative flow → Add a new bullet under Edge Cases / Error Handling (or create such subsection if template provides placeholder for it).
       - Terminology conflict → Normalize term across spec; retain original only if necessary by adding `(formerly referred to as "X")` once.
    - If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
    - Save the spec file AFTER each integration to minimize risk of context loss (atomic overwrite).
    - Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.
    - Keep each inserted clarification minimal and testable (avoid narrative drift).

7. Validation (performed after EACH write plus final pass):
   - Clarifications session contains exactly one bullet per accepted answer (no duplicates).
   - Total asked (accepted) questions ≤ 5.
   - Updated sections contain no lingering vague placeholders the new answer was meant to resolve.
   - No contradictory earlier statement remains (scan for now-invalid alternative choices removed).
   - Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`.
   - Terminology consistency: same canonical term used across all updated sections.

8. Write the updated spec back to `FEATURE_SPEC`.

9. Report completion (after questioning loop ends or early termination):
   - Number of questions asked & answered.
   - Path to updated spec.
   - Sections touched (list names).
   - Coverage summary table listing each taxonomy category with Status: Resolved (was Partial/Missing and addressed), Deferred (exceeds question quota or better suited for planning), Clear (already sufficient), Outstanding (still Partial/Missing but low impact).
   - If any Outstanding or Deferred remain, recommend whether to proceed to `/speckit.plan` or run `/speckit.clarify` again later post-plan.
   - Suggested next command.

Behavior rules:

- If no meaningful ambiguities found (or all potential questions would be low-impact), respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding.
- If spec file missing, instruct user to run `/speckit.specify` first (do not create a new spec here).
- Never exceed 5 total asked questions (clarification retries for a single question do not count as new questions).
- Avoid speculative tech stack questions unless the absence blocks functional clarity.
- Respect user early termination signals ("stop", "done", "proceed").
- If no questions asked due to full coverage, output a compact coverage summary (all categories Clear) then suggest advancing.
- If quota reached with unresolved high-impact categories remaining, explicitly flag them under Deferred with rationale.

Context for prioritization: {ARGS}
