This is the first Unifyr Spec Kit release featuring the **5-stage Specification-Driven Development workflow**. Download the template package for your AI assistant and script environment below.

## What's New in v1.0.0

- **5-stage workflow**: Specification → Review → Charter → Planning → Tasks
- **Engineering Charter promoted to Stage 3**: Interactive codebase scanning (10 categories) and guided Q&A to surface architectural decisions and implementation principles
- **Charter-driven testing**: Testing approach (TDD, test-alongside, test-after) determined by the charter, not hardcoded
- **Plan actively driven by charter**: Step 3b ensures charter shapes technology choices, architecture, testing strategy, and migration approach
- **Phase -1 auto-trigger**: Plan detects missing charter and offers inline creation
- **Migration & Compatibility and i18n** added as charter taxonomy categories
- **Three context files distinguished**: agent file (universal product truths), charter (architectural decisions & implementation principles), project.md (universal constraints bounding specifications)

## Changelog

- feat: promote charter to Stage 3 with interactive Q&A, 5-stage process
- feat: rebrand to Unifyr Spec Kit, update install URLs, align docs
- feat: incorporate team feedback — complexity scoring, charter docs
- feat: add /speckit.project to Stage 1 and enable project.md consumption
- fix: add missing scripts frontmatter to charter command
