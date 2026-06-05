# [PROJECT_NAME] Constitution
<!-- The constitution captures high-level architectural decisions and overarching
     implementation principles for this initiative. These directly drive how
     /speckit.plan structures the implementation and how /speckit.implement executes it.
     It goes beyond the agent file (universal product truths) to capture initiative-specific
     engineering guidance. Focus on concrete, actionable decisions and principles
     that constrain downstream technical choices — not abstract best practices. -->

## Core Architectural Decisions

### Test-First Development (NON-NEGOTIABLE)
<!-- FIXED PRINCIPLE: This fork enforces strict TDD pipeline-wide. Keep this principle in
     every constitution verbatim. /speckit.constitution must NOT turn it back into a Q&A choice. -->
Strict Test-Driven Development is mandatory across this initiative and is not subject to the
constitution Q&A:

- Every unit of behavior is built **red-green-refactor**: write a failing test first, confirm it
  FAILS for the right reason, write the minimum code to make it pass, then refactor with the suite
  green.
- `/speckit.tasks` MUST order test tasks before their implementation tasks. `/speckit.implement`
  MUST author and run the failing test before writing implementation, and reorder any task list
  that violates this.
- No implementation code is written before a failing test exists. A task is "done" only when its
  tests were observed RED then GREEN and the build / lint / static-analysis checks pass.
- The remaining testing choices (test types & mix, mock vs real dependencies, coverage gate) are
  captured in the principles below, but they may never weaken or defer this test-first ordering.

### [PRINCIPLE_1_NAME]
<!-- Example: I. Library-First Architecture -->
[PRINCIPLE_1_DESCRIPTION]
<!-- Example: Every feature starts as a standalone library with CLI interface; Libraries must be self-contained, independently testable, documented; This decision shapes how /speckit.plan structures phases and module boundaries -->

### [PRINCIPLE_2_NAME]
<!-- Example: II. Text-Based Interfaces -->
[PRINCIPLE_2_DESCRIPTION]
<!-- Example: Every library exposes functionality via CLI; Text in/out protocol: stdin/args → stdout, errors → stderr; Support JSON + human-readable formats; This ensures observability and testability across all components -->

### [PRINCIPLE_3_NAME]
<!-- Example: III. Code Quality & Standards -->
[PRINCIPLE_3_DESCRIPTION]
<!-- Example: Lint + format gates enforced in CI; type checking required; no merge on failing quality gates -->

### [PRINCIPLE_4_NAME]
<!-- Example: IV. Testing Emphasis (test TYPES & coverage — test TIMING is fixed by the Test-First principle above) -->
[PRINCIPLE_4_DESCRIPTION]
<!-- Example: Integration-first — prefer real databases over mocks; contract tests for all public APIs; 80% line coverage gate; unit tests for pure logic -->

### [PRINCIPLE_5_NAME]
<!-- Example: V. Simplicity Constraints / VI. Versioning Strategy / VII. Observability & Telemetry Conventions -->
[PRINCIPLE_5_DESCRIPTION]
<!--
  Example (Simplicity): Maximum 3 projects for initial implementation
  Example (Versioning): MAJOR.MINOR.BUILD with semantic-release
  Example (Observability & Telemetry — capture project-wide conventions here so feature
  specs only carry feature-specific instances):
    - Logging: structured JSON via <library>; every log line includes tenant_id, user_id,
      request_id, feature=<feature_name>; ERROR pages oncall, WARN does not.
    - PII: <list of fields> redacted at the logger before emission; never logged in plain text.
    - Tracing: OpenTelemetry, span name pattern `<feature>.<operation>`, parent inherited
      from inbound HTTP trace.
    - Metrics: Prometheus-style; counters as `<feature>_<action>_total`, histograms as
      `<feature>_<operation>_ms`.
    - Product analytics: Segment → Amplitude; event names follow `Object Verbed` convention.
    - Dashboards: new features extend existing per-team Grafana board unless their domain
      warrants a new one.
    - SLOs and alert thresholds: managed in the regression process, not in feature specs.
-->

## [SECTION_2_NAME]
<!-- Example: Technical Constraints, Security Architecture, Migration Strategy, etc. -->

[SECTION_2_CONTENT]
<!-- Example: "All persistent storage uses PostgreSQL with Alembic migrations",
     "Auth via OAuth2 with JWT tokens", "All user-facing strings externalised for AI translation",
     "Breaking changes require migration plan with rollback strategy" -->

## [SECTION_3_NAME]
<!-- Example: Development Workflow, Quality Gates, Deployment Architecture, etc. -->

[SECTION_3_CONTENT]
<!-- Example: "CI pipeline: lint → test → build → deploy to staging",
     "All PRs require contract test pass before merge",
     "Feature flags for all user-facing changes" -->

## Governance
<!-- How these architectural decisions evolve. Constitution supersedes all other practices.
     Amendments require documentation, approval, and downstream impact assessment. -->

[GOVERNANCE_RULES]
<!-- Example: All PRs/reviews must verify compliance with architectural decisions;
     Complexity beyond these decisions must be justified in plan.md;
     Use [GUIDANCE_FILE] for runtime development guidance -->

<!--
## Derivation Log (auto-generated by /speckit.constitution Q&A)
Records how each architectural decision was derived. Do not edit manually.
### Session YYYY-MM-DD
- Category: [category] → Decision: [name] (Source: Detected/Q&A/User-authored)
-->

**Version**: [CONSTITUTION_VERSION] | **Ratified**: [RATIFICATION_DATE] | **Last Amended**: [LAST_AMENDED_DATE]
<!-- Example: Version: 2.1.1 | Ratified: 2025-06-13 | Last Amended: 2025-07-16 -->
