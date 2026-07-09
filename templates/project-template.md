<!--
  ARTIFACT STABILITY: Very Stable
  This project definition provides universal constraints that bound all feature specifications.
  Out-of-scope exclusions and shared constraints apply to ALL specs under this project.
  Changes affect all linked specifications — amend with care.
-->

# Project: [PROJECT NAME]

**Project Branch**: `project-[project-name]`
**Created**: [DATE]
**Status**: Active
**Version**: 1.0

## Project Overview

[High-level description of the project encompassing multiple features. Explain the business context and overall goals.]

## Target Users

<!--
  Define user types that apply across all features in this project.
  Feature-specific user details belong in individual spec.md files.
-->

- **[User Type 1]**: [Description and primary needs]
- **[User Type 2]**: [Description and primary needs]

## Out of Scope

<!--
  IMPORTANT: This section defines what is OUT OF SCOPE for the entire project.
  These are project-level exclusions that apply to ALL features.
  Feature-specific exclusions ("Non-Goals") belong in individual spec.md files.
-->

### Project-Level Exclusions

- **OOS-001**: [What is explicitly excluded from this project, e.g., "Mobile native applications"]
- **OOS-002**: [What is explicitly excluded, e.g., "Integration with legacy System X"]
- **OOS-003**: [What is explicitly excluded, e.g., "Multi-tenant architecture"]

### Deferred to Future Projects

- [Item that may be addressed in a future project]
- [Item that is out of scope now but on the roadmap]

## Shared Constraints

<!--
  Constraints that apply to ALL features in this project.
  Feature-specific constraints belong in individual spec.md or plan.md files.
-->

- **SC-001**: [Constraint, e.g., "Must run on existing infrastructure"]
- **SC-002**: [Constraint, e.g., "Must integrate with existing auth system"]
- **SC-003**: [Constraint, e.g., "Must comply with GDPR requirements"]

## Features in This Project

<!--
  Track all features/specs that belong to this project.
  Update this table as features are added.
-->

| # | Feature | Spec Path | Status | Priority |
|---|---------|-----------|--------|----------|
| 001 | [Feature 1 Name] | specs/project-[name]/001-[feature]/spec.md | Draft | P1 |
| 002 | [Feature 2 Name] | specs/project-[name]/002-[feature]/spec.md | Draft | P2 |
| 003 | [Feature 3 Name] | specs/project-[name]/003-[feature]/spec.md | Draft | P3 |

## Shared Technical Decisions

<!--
  Document technical decisions that apply to ALL features in this project.
  Feature-specific technical decisions belong in individual plan.md files.
  Fill this section during Stage 4 (Planning) or leave empty if not yet decided.
-->

### Technology Stack (Shared)

- **Language**: [e.g., TypeScript 5.x]
- **Framework**: [e.g., Next.js 14]
- **Database**: [e.g., PostgreSQL 16]
- **Authentication**: [e.g., Existing OAuth2 system]

### Architectural Patterns (Shared)

- [Pattern 1]: [Why chosen for this project]
- [Pattern 2]: [Why chosen for this project]

## Project Engineering Charter Extensions

<!--
  Project-specific principles that extend the base charter.
  These apply to all features in this project.
-->

- [Project Principle 1]: [Why this principle matters for the project]
- [Project Principle 2]: [Why this principle matters for the project]

## Jira Integration

<!--
  Link to project-level Jira tracking.
-->

**Jira Project**: [JIRA-PROJECT-KEY]
**Epic**: [JIRA-EPIC-KEY] - [Project Name]

## Changelog

| Version | Date | Author | Change Description |
|---------|------|--------|-------------------|
| 1.0 | [DATE] | [Author] | Initial project definition |
