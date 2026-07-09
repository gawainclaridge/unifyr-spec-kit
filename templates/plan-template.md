<!--
  ARTIFACT STABILITY: Stable
  This plan must NOT exceed the scope of the referenced specification.
  If technical planning reveals need for scope expansion, STOP and amend spec.md first.
  Changes require spec review if scope is affected.
-->

# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Spec Reference

**Source Specification**: `/specs/[###-feature-name]/spec.md`
**Spec Version**: [Version from spec changelog]
**Spec Sign-Off Date**: [Date spec was signed off, or "Pending"]

### Scope Alignment Check

- [ ] All plan items trace to requirements in spec.md
- [ ] No features added beyond spec scope
- [ ] If scope expansion needed: spec.md amended and re-approved

> **WARNING**: If this plan requires features not in the spec, STOP and update the spec first.
> Get Product sign-off on spec changes before continuing with planning.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Charter Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*
*The Engineering Charter actively drives this plan's decisions — not just compliance gates.*

### Decisions That Shaped This Plan

<!-- List architectural decisions and implementation principles from the charter
     that actively influenced technology choices, architecture, and
     migration approach in this plan. Show how each decision mapped to a plan choice. -->

| Charter Decision | How It Shaped This Plan |
|-----------------------|------------------------|
| [e.g., "Library-First architecture"] | [e.g., "Project structure uses standalone library modules"] |
| [e.g., "PostgreSQL for all storage"] | [e.g., "Data model targets Postgres with Alembic migrations"] |

### Compliance Gates

[Gates determined based on charter file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Migration Plan

<!--
  Required if any breaking changes or schema migrations are introduced.
  Populated during Phase 1 of /speckit.plan.
  Leave empty if no breaking changes or migrations are needed.
-->

| Change | Affected Consumers | Strategy | Rollback Plan |
|--------|--------------------|----------|---------------|

## Complexity Tracking

> **Fill ONLY if Charter Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Testing Scenarios

<!--
  Define testing scenarios for each unit of work.
  Strict TDD is mandatory: these scenarios become test tasks that are authored first and must
  FAIL before implementation. QA should review and extend these during Stage 4 (Planning).
  These scenarios inform the task breakdown in /speckit.tasks (tests ordered before implementation).
-->

### User Story 1: [Title from spec]

**Happy Path Tests:**

1. **Scenario**: [Description]
   - **Given**: [Precondition]
   - **When**: [Action]
   - **Then**: [Expected result]

**Edge Case Tests:**

1. **Scenario**: [Description]
   - **Given**: [Edge condition]
   - **When**: [Action]
   - **Then**: [Expected handling]

**Error Handling Tests:**

1. **Scenario**: [Description]
   - **Given**: [Error condition]
   - **When**: [Action]
   - **Then**: [Graceful failure behavior]

### User Story 2: [Title from spec]

[Same structure as above...]

---

## Sign-Off *(advisory)*

<!--
  Track team approvals for this implementation plan.
  Sign-off is advisory and does not block workflow progression.
-->

| Stage | Team | Approver | Date | Status |
|-------|------|----------|------|--------|
| Plan Draft | Engineering | | | Pending |
| Plan Review | QA | | | Pending |
| Charter Check | Engineering | | | Pending |
| Final Sign-Off | All | | | Pending |
