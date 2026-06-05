<div align="center">
    <img src="./media/logo_large.webp" alt="Unifyr Spec Kit Logo" width="200" height="200"/>
    <h1>🌱 Unifyr Spec Kit</h1>
    <h3><em>Build high-quality software faster.</em></h3>
</div>

<p align="center">
    <strong>An open source toolkit that allows you to focus on product scenarios and predictable outcomes instead of vibe coding every piece from scratch.</strong>
</p>

<p align="center">
    <a href="https://github.com/gawainclaridge/spec-kit/actions/workflows/release.yml"><img src="https://github.com/gawainclaridge/spec-kit/actions/workflows/release.yml/badge.svg" alt="Release"/></a>
    <a href="https://github.com/gawainclaridge/spec-kit/stargazers"><img src="https://img.shields.io/github/stars/gawainclaridge/spec-kit?style=social" alt="GitHub stars"/></a>
    <a href="https://github.com/gawainclaridge/spec-kit/blob/main/LICENSE"><img src="https://img.shields.io/github/license/gawainclaridge/spec-kit" alt="License"/></a>
    <a href="https://gawainclaridge.github.io/spec-kit/"><img src="https://img.shields.io/badge/docs-GitHub_Pages-blue" alt="Documentation"/></a>
</p>

---

> **Fork Notice:** Unifyr Spec Kit is a fork of [GitHub's Spec Kit](https://github.com/github/spec-kit), tailored to Unifyr's agile scrum processes. Key changes from vanilla Spec Kit:
>
> | Change | What it adds | Why it matters for Unifyr |
> |--------|-------------|--------------------------|
> | **5-stage process** | Specification → Review → Constitution → Planning → Tasks with explicit team ownership (Product, Engineering, QA) | Maps directly to our sprint ceremonies and handoff points |
> | **Multi-feature projects** | `/speckit.project` command and `--project` flag group related specs under a shared project context | Supports epic-level planning where multiple features share constraints, users, and scope boundaries |
> | **Constitution enforcement** | Constitution is a hard prerequisite for `/speckit.plan` | Ensures high-level architectural decisions are agreed before any planning begins, reducing rework |
> | **Jira integration** | `--jira` flag on `/speckit.taskstoissues` creates Epic → Story → Sub-task hierarchy with Fibonacci story points | Tickets flow straight into our Jira boards with correct hierarchy and sizing |
> | **Per-story task files** | `--per-story` flag on `/speckit.tasks` generates separate task files per user story | Enables parallel story assignment across team members in a sprint |
> | **Complexity scoring** | Fibonacci-based story point estimates with calibration (8 pts ≈ 5 days) and split advisory at 20+ pts | Right-sizes features before sprint commitment; flags over-scoped work early |
> | **Mid-flight change guidance** | Amend-vs-restart decision framework, 3-4 iteration rule, impact matrix | Gives the team a shared playbook for handling scope changes without accumulating drift |
> | **Artifact stability framework** | constitution (very stable) → spec (stable) → plan (moderate) → tasks (volatile) | Everyone knows which artifacts are safe to change and which require re-approval |
> | **Sign-off tracking** | Advisory sign-off tables in spec, plan, and constitution | Makes approval status visible across Product, Engineering, and QA |
> | **Demo-able vertical slices** | Stories must be independently testable and demonstrable to QA/Product | Aligns with our sprint review format where every story is demoed |
>
> Upstream contributions are welcomed back. See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Table of Contents

- [🤔 What is Spec-Driven Development?](#-what-is-spec-driven-development)
- [⚡ Get Started](#-get-started)
- [🤖 Supported AI Agents](#-supported-ai-agents)
- [🔧 Specify CLI Reference](#-specify-cli-reference)
- [📚 Core Philosophy](#-core-philosophy)
- [🌟 Development Phases](#-development-phases)
- [🎯 Experimental Goals](#-experimental-goals)
- [🔧 Prerequisites](#-prerequisites)
- [📖 Learn More](#-learn-more)
- [📋 Detailed Process](#-detailed-process)
- [🔍 Troubleshooting](#-troubleshooting)
- [👥 Maintainers](#-maintainers)
- [💬 Support](#-support)
- [🙏 Acknowledgements](#-acknowledgements)
- [📄 License](#-license)

## 🤔 What is Spec-Driven Development?

Spec-Driven Development **flips the script** on traditional software development. For decades, code has been king — specifications were just scaffolding we built and discarded once the "real work" of coding began. Spec-Driven Development changes this: **specifications become executable**, directly generating working implementations rather than just guiding them.

## ⚡ Get Started

### 1. Install Specify CLI

Choose your preferred installation method:

#### Option 1: Persistent Installation (Recommended)

Install once and use everywhere:

```bash
uv tool install specify-cli --from git+https://github.com/gawainclaridge/spec-kit.git@unifyr-spec-kit
```

Then use the tool directly:

```bash
# Create new project
specify init <PROJECT_NAME>

# Or initialize in existing project
specify init . --ai claude
# or
specify init --here --ai claude

# Check installed tools
specify check
```

To upgrade Specify, see the [Upgrade Guide](./docs/upgrade.md) for detailed instructions. Quick upgrade:

```bash
uv tool install specify-cli --force --from git+https://github.com/gawainclaridge/spec-kit.git@unifyr-spec-kit
```

#### Option 2: One-time Usage

Run directly without installing:

```bash
uvx --from git+https://github.com/gawainclaridge/spec-kit.git@unifyr-spec-kit specify init <PROJECT_NAME>
```

**Benefits of persistent installation:**

- Tool stays installed and available in PATH
- No need to create shell aliases
- Better tool management with `uv tool list`, `uv tool upgrade`, `uv tool uninstall`
- Cleaner shell configuration

### The 5-Stage Process

Unifyr Spec Kit follows a structured 5-stage workflow aligned with team collaboration:

| Stage | Focus | Key Commands |
|-------|-------|-------------|
| **Stage 1: Specification** | Product | `/speckit.project`, `/speckit.specify` |
| **Stage 2: Review** | Product/Engineering/QA | `/speckit.clarify` |
| **Stage 3: Constitution** | Engineering | `/speckit.constitution` |
| **Stage 4: Planning** | Engineering | `/speckit.plan` |
| **Stage 5: Tasks** | Engineering | `/speckit.tasks`, `/speckit.taskstoissues`, `/speckit.implement` |

### 2. Create specifications (Stage 1: Specification)

Launch your AI assistant in the project directory. The `/speckit.*` commands are available in the assistant.

Set up your **agent file** (e.g., `CLAUDE.md`) with your product-level architecture and universal engineering truths.

For multi-feature projects, use **`/speckit.project`** first to create shared context across features:

```bash
/speckit.project my-project-name
```

Use **`/speckit.specify`** to describe what you want to build. Focus on the **what** and **why**, not the tech stack:

```bash
/speckit.specify Build an application that can help me organize my photos in separate photo albums. Albums are grouped by date and can be re-organized by dragging and dropping on the main page. Albums are never in other nested albums. Within each album, photos are previewed in a tile-like interface.
```

### 3. Review and refine (Stage 2: Review)

Use **`/speckit.clarify`** to identify and resolve ambiguities in your specification before planning:

```bash
/speckit.clarify Focus on security and performance requirements.
```

### 4. Create constitution (Stage 3: Constitution)

Use **`/speckit.constitution`** to establish high-level architectural decisions for this initiative. The command scans your codebase for technical signals, then runs an interactive Q&A to fill gaps across 10 architectural concern categories:

```bash
/speckit.constitution
```

Or seed it with known principles — the Q&A will confirm and fill gaps:

```bash
/speckit.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements
```

The constitution captures **high-level architectural decisions** — the foundational technical direction that directly informs Stage 4 (Planning) and Stage 5 (Implementation). It must be finalized before planning can proceed. See [Stage 3 details](#stage-3-constitution-engineering) for the full workflow.

### 5. Create implementation plan (Stage 4: Planning)

Use the **`/speckit.plan`** command to provide your tech stack and architecture choices. The constitution must be finalized before this step.

```bash
/speckit.plan The application uses Vite with minimal number of libraries. Use vanilla HTML, CSS, and JavaScript as much as possible. Images are not uploaded anywhere and metadata is stored in a local SQLite database.
```

### 6. Generate tasks and implement (Stage 5: Tasks)

Use **`/speckit.tasks`** to create an actionable task list:

```bash
/speckit.tasks
```

Optionally, create issue tracker tickets with **`/speckit.taskstoissues`**:

```bash
/speckit.taskstoissues --jira PROJ
```

Then use **`/speckit.implement`** to execute the plan:

```bash
/speckit.implement
```

For detailed step-by-step instructions, see the [detailed process](#-detailed-process) below or the [comprehensive methodology](./spec-driven.md).

## 🤖 Supported AI Agents

| Agent                                                                                | Support | Notes                                                                                                                                     |
| ------------------------------------------------------------------------------------ | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| [Qoder CLI](https://qoder.com/cli)                                                   | ✅      |                                                                                                                                           |
| [Amazon Q Developer CLI](https://aws.amazon.com/developer/learning/q-developer-cli/) | ⚠️      | Amazon Q Developer CLI [does not support](https://github.com/aws/amazon-q-developer-cli/issues/3064) custom arguments for slash commands. |
| [Amp](https://ampcode.com/)                                                          | ✅      |                                                                                                                                           |
| [Auggie CLI](https://docs.augmentcode.com/cli/overview)                              | ✅      |                                                                                                                                           |
| [Claude Code](https://www.anthropic.com/claude-code)                                 | ✅      |                                                                                                                                           |
| [CodeBuddy CLI](https://www.codebuddy.ai/cli)                                        | ✅      |                                                                                                                                           |
| [Codex CLI](https://github.com/openai/codex)                                         | ✅      |                                                                                                                                           |
| [Cursor](https://cursor.sh/)                                                         | ✅      |                                                                                                                                           |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli)                            | ✅      |                                                                                                                                           |
| [GitHub Copilot](https://code.visualstudio.com/)                                     | ✅      |                                                                                                                                           |
| [IBM Bob](https://www.ibm.com/products/bob)                                          | ✅      | IDE-based agent with slash command support                                                                                                |
| [Jules](https://jules.google.com/)                                                   | ✅      |                                                                                                                                           |
| [Kilo Code](https://github.com/Kilo-Org/kilocode)                                    | ✅      |                                                                                                                                           |
| [opencode](https://opencode.ai/)                                                     | ✅      |                                                                                                                                           |
| [Qwen Code](https://github.com/QwenLM/qwen-code)                                     | ✅      |                                                                                                                                           |
| [Roo Code](https://roocode.com/)                                                     | ✅      |                                                                                                                                           |
| [SHAI (OVHcloud)](https://github.com/ovh/shai)                                       | ✅      |                                                                                                                                           |
| [Windsurf](https://windsurf.com/)                                                    | ✅      |                                                                                                                                           |

## 🔧 Specify CLI Reference

The `specify` command supports the following options:

### Commands

| Command | Description                                                                                                                                             |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `init`  | Initialize a new Specify project from the latest template                                                                                               |
| `check` | Check for installed tools (`git`, `claude`, `gemini`, `code`/`code-insiders`, `cursor-agent`, `windsurf`, `qwen`, `opencode`, `codex`, `shai`, `qoder`) |

### `specify init` Arguments & Options

| Argument/Option        | Type     | Description                                                                                                                                                                                  |
| ---------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<project-name>`       | Argument | Name for your new project directory (optional if using `--here`, or use `.` for current directory)                                                                                           |
| `--ai`                 | Option   | AI assistant to use: `claude`, `gemini`, `copilot`, `cursor-agent`, `qwen`, `opencode`, `codex`, `windsurf`, `kilocode`, `auggie`, `roo`, `codebuddy`, `amp`, `shai`, `q`, `bob`, or `qoder` |
| `--script`             | Option   | Script variant to use: `sh` (bash/zsh) or `ps` (PowerShell)                                                                                                                                  |
| `--ignore-agent-tools` | Flag     | Skip checks for AI agent tools like Claude Code                                                                                                                                              |
| `--no-git`             | Flag     | Skip git repository initialization                                                                                                                                                           |
| `--here`               | Flag     | Initialize project in the current directory instead of creating a new one                                                                                                                    |
| `--force`              | Flag     | Force merge/overwrite when initializing in current directory (skip confirmation)                                                                                                             |
| `--skip-tls`           | Flag     | Skip SSL/TLS verification (not recommended)                                                                                                                                                  |
| `--debug`              | Flag     | Enable detailed debug output for troubleshooting                                                                                                                                             |
| `--github-token`       | Option   | GitHub token for API requests (or set GH_TOKEN/GITHUB_TOKEN env variable)                                                                                                                    |

### Examples

```bash
# Basic project initialization
specify init my-project

# Initialize with specific AI assistant
specify init my-project --ai claude

# Initialize with Cursor support
specify init my-project --ai cursor-agent

# Initialize with Qoder support
specify init my-project --ai qoder

# Initialize with Windsurf support
specify init my-project --ai windsurf

# Initialize with Amp support
specify init my-project --ai amp

# Initialize with SHAI support
specify init my-project --ai shai

# Initialize with IBM Bob support
specify init my-project --ai bob

# Initialize with PowerShell scripts (Windows/cross-platform)
specify init my-project --ai copilot --script ps

# Initialize in current directory
specify init . --ai copilot
# or use the --here flag
specify init --here --ai copilot

# Force merge into current (non-empty) directory without confirmation
specify init . --force --ai copilot
# or
specify init --here --force --ai copilot

# Skip git initialization
specify init my-project --ai gemini --no-git

# Enable debug output for troubleshooting
specify init my-project --ai claude --debug

# Use GitHub token for API requests (helpful for corporate environments)
specify init my-project --ai claude --github-token ghp_your_token_here

# Check system requirements
specify check
```

### Available Slash Commands

After running `specify init`, your AI coding agent will have access to these slash commands for structured development:

#### Core Commands

Essential commands for the Spec-Driven Development workflow:

| Command                 | Description                                                              |
| ----------------------- | ------------------------------------------------------------------------ |
| `/speckit.constitution` | Establish high-level architectural decisions and engineering principles that guide planning and implementation |
| `/speckit.specify`      | Define what you want to build (requirements and user stories)            |
| `/speckit.plan`         | Create technical implementation plans with your chosen tech stack        |
| `/speckit.tasks`        | Generate actionable task lists for implementation                        |
| `/speckit.implement`    | Execute all tasks to build the feature according to the plan             |

#### Project Management Commands

Commands for managing multi-feature projects:

| Command                  | Description                                                              |
| ------------------------ | ------------------------------------------------------------------------ |
| `/speckit.project`       | Create or manage a project definition for multi-feature projects         |
| `/speckit.taskstoissues` | Convert tasks to GitHub issues or Jira tickets with complexity scoring   |

#### Optional Commands

Additional commands for enhanced quality and validation:

| Command              | Description                                                                                                                          |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `/speckit.clarify`   | Analyze spec for gaps and clarify underspecified areas (Stage 2 review process)                                                      |
| `/speckit.analyze`   | Cross-artifact consistency & coverage analysis (run after `/speckit.tasks`, before `/speckit.implement`)                             |
| `/speckit.checklist` | Generate custom quality checklists that validate requirements completeness, clarity, and consistency (like "unit tests for English") |

#### Command Flags Reference

Key flags for commonly used commands:

| Command                  | Flag                   | Description                                              |
| ------------------------ | ---------------------- | -------------------------------------------------------- |
| `/speckit.specify`       | `--project <name>`     | Add spec to existing project branch instead of creating new branch |
| `/speckit.tasks`         | `--per-story`          | Generate separate task files per user story (tasks-us1.md, etc.) |
| `/speckit.project`       | `--list`               | List all specs in the project                            |
| `/speckit.project`       | `--add-spec`           | Add current spec to the project                          |
| `/speckit.taskstoissues` | `--jira <PROJECT-KEY>` | Create Jira tickets (Epic → Story → Sub-task hierarchy)  |
| `/speckit.taskstoissues` | `--github`             | Create GitHub issues (default)                           |

### Environment Variables

| Variable          | Description                                                                                                                                                                                                                                                                                            |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `SPECIFY_FEATURE` | Override feature detection for non-Git repositories. Set to the feature directory name (e.g., `001-photo-albums`) to work on a specific feature when not using Git branches.<br/>**Must be set in the context of the agent you're working with prior to using `/speckit.plan` or follow-up commands. |
| `SPECIFY_PROJECT` | Override project detection for multi-feature projects. Set to the project name (e.g., `taskify`) when working with project branches.                                                                                                                                                                 |

## 📚 Core Philosophy

Spec-Driven Development is a structured process that emphasizes:

- **Intent-driven development** where specifications define the "*what*" before the "*how*"
- **Rich specification creation** using guardrails and organizational principles
- **Multi-step refinement** rather than one-shot code generation from prompts
- **Heavy reliance** on advanced AI model capabilities for specification interpretation

## 🌟 Development Phases

| Phase                                    | Focus                    | Key Activities                                                                                                                                                     |
| ---------------------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **0-to-1 Development** ("Greenfield")    | Generate from scratch    | <ul><li>Start with high-level requirements</li><li>Generate specifications</li><li>Plan implementation steps</li><li>Build production-ready applications</li></ul> |
| **Creative Exploration**                 | Parallel implementations | <ul><li>Explore diverse solutions</li><li>Support multiple technology stacks & architectures</li><li>Experiment with UX patterns</li></ul>                         |
| **Iterative Enhancement** ("Brownfield") | Brownfield modernization | <ul><li>Add features iteratively</li><li>Modernize legacy systems</li><li>Adapt processes</li></ul>                                                                |

## 🎯 Experimental Goals

Our research and experimentation focus on:

### Technology independence

- Create applications using diverse technology stacks
- Validate the hypothesis that Spec-Driven Development is a process not tied to specific technologies, programming languages, or frameworks

### Enterprise constraints

- Demonstrate mission-critical application development
- Incorporate organizational constraints (cloud providers, tech stacks, engineering practices)
- Support enterprise design systems and compliance requirements

### User-centric development

- Build applications for different user cohorts and preferences
- Support various development approaches (from vibe-coding to AI-native development)

### Creative & iterative processes

- Validate the concept of parallel implementation exploration
- Provide robust iterative feature development workflows
- Extend processes to handle upgrades and modernization tasks

## 🔧 Prerequisites

- **Linux/macOS/Windows**
- [Supported](#-supported-ai-agents) AI coding agent.
- [uv](https://docs.astral.sh/uv/) for package management
- [Python 3.11+](https://www.python.org/downloads/)
- [Git](https://git-scm.com/downloads)

If you encounter issues with an agent, please open an issue so we can refine the integration.

## 📖 Learn More

- **[Complete Spec-Driven Development Methodology](./spec-driven.md)** - Deep dive into the full process
- **[Detailed Walkthrough](#-detailed-process)** - Step-by-step implementation guide with mid-flight change guidance

---

## 📋 Detailed Process

<details>
<summary>Click to expand the detailed step-by-step walkthrough</summary>

You can use the Specify CLI to bootstrap your project, which will bring in the required artifacts in your environment. Run:

```bash
specify init <project_name>
```

Or initialize in the current directory:

```bash
specify init .
# or use the --here flag
specify init --here
# Skip confirmation when the directory already has files
specify init . --force
# or
specify init --here --force
```

![Specify CLI bootstrapping a new project in the terminal](./media/specify_cli.gif)

You will be prompted to select the AI agent you are using. You can also proactively specify it directly in the terminal:

```bash
specify init <project_name> --ai claude
specify init <project_name> --ai gemini
specify init <project_name> --ai copilot

# Or in current directory:
specify init . --ai claude
specify init . --ai codex

# or use --here flag
specify init --here --ai claude
specify init --here --ai codex

# Force merge into a non-empty current directory
specify init . --force --ai claude

# or
specify init --here --force --ai claude
```

The CLI will check if you have Claude Code, Gemini CLI, Cursor CLI, Qwen CLI, opencode, Codex CLI, Qoder CLI, or Amazon Q Developer CLI installed. If you do not, or you prefer to get the templates without checking for the right tools, use `--ignore-agent-tools` with your command:

```bash
specify init <project_name> --ai claude --ignore-agent-tools
```

### Stage 1: Specification (Product)

#### Set up your agent file

Your agent file (e.g., `CLAUDE.md` for Claude Code) should contain your **product-level architecture** and universal engineering truths. This is auto-generated from plan.md files but includes a `Product Architecture` section at the top that you maintain manually.

#### Launch your AI agent

Go to the project folder and run your AI agent. In our example, we're using `claude`.

![Bootstrapping Claude Code environment](./media/bootstrap-claude-code.gif)

You will know that things are configured correctly if you see the `/speckit.constitution`, `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, and `/speckit.implement` commands available.

#### Create shared project context (`/speckit.project`) — optional

For multi-feature projects, use `/speckit.project` first to create shared context across features:

```text
/speckit.project taskify
```

This creates a `project.md` with out-of-scope items, shared constraints, and a features table that all specs in the project can reference.

#### Create project specifications (`/speckit.specify`)

Use the `/speckit.specify` command and provide the concrete requirements for the project you want to develop.

> [!IMPORTANT]
> Be as explicit as possible about *what* you are trying to build and *why*. **Do not focus on the tech stack at this point**.

An example prompt:

```text
Develop Taskify, a team productivity platform. It should allow users to create projects, add team members,
assign tasks, comment and move tasks between boards in Kanban style. In this initial phase for this feature,
let's call it "Create Taskify," let's have multiple users but the users will be declared ahead of time, predefined.
I want five users in two different categories, one product manager and four engineers. Let's create three
different sample projects. Let's have the standard Kanban columns for the status of each task, such as "To Do,"
"In Progress," "In Review," and "Done." There will be no login for this application as this is just the very
first testing thing to ensure that our basic features are set up. For each task in the UI for a task card,
you should be able to change the current status of the task between the different columns in the Kanban work board.
You should be able to leave an unlimited number of comments for a particular card. You should be able to, from that task
card, assign one of the valid users. When you first launch Taskify, it's going to give you a list of the five users to pick
from. There will be no password required. When you click on a user, you go into the main view, which displays the list of
projects. When you click on a project, you open the Kanban board for that project. You're going to see the columns.
You'll be able to drag and drop cards back and forth between different columns. You will see any cards that are
assigned to you, the currently logged in user, in a different color from all the other ones, so you can quickly
see yours. You can edit any comments that you make, but you can't edit comments that other people made. You can
delete any comments that you made, but you can't delete comments anybody else made.
```

After this prompt is entered, you should see Claude Code kick off the planning and spec drafting process. Claude Code will also trigger some of the built-in scripts to set up the repository.

Once this step is completed, you should have a new branch created (e.g., `001-create-taskify`), as well as a new specification in the `specs/001-create-taskify` directory.

The produced specification should contain an **Experience Vision** (a short narrative describing what success feels like from the customer's perspective), user stories, and functional requirements, as defined in the template.

#### Draft project principles (`/speckit.constitution`) — optional

Optionally, establish your project's high-level architectural decisions using the `/speckit.constitution` command. The constitution captures the architectural direction for a specific project or epic set — decisions that directly guide Stage 4 (Planning) and Stage 5 (Implementation):

```text
/speckit.constitution Create principles focused on code quality, testing standards, user experience consistency, and performance requirements. Include governance for how these principles should guide technical decisions and implementation choices.
```

This writes the constitution **beside your `project.md`** at `specs/project-<name>/constitution.md` (or, for a standalone feature, in the feature directory at `specs/<###-feature>/constitution.md`), seeded from the read-only `.specify/memory/constitution.md` template. The constitution is its own stage (Stage 3) and **must be finalized before** Stage 4 (Planning).

At this stage, your project folder contents should resemble the following:

```text
└── .specify
    ├── memory
    │  └── constitution.md
    ├── scripts
    │  ├── check-prerequisites.sh
    │  ├── common.sh
    │  ├── create-new-feature.sh
    │  ├── setup-plan.sh
    │  └── update-claude-md.sh
    ├── specs
    │  └── 001-create-taskify
    │      └── spec.md
    └── templates
        ├── plan-template.md
        ├── spec-template.md
        └── tasks-template.md
```

### Stage 2: Review (Product/Engineering/QA)

#### Clarify and refine (`/speckit.clarify`)

With the baseline specification created, you can go ahead and clarify any of the requirements that were not captured properly within the first shot attempt.

You should run the structured clarification workflow **before** creating a technical plan to reduce rework downstream. If the spec is missing an **Experience Vision**, clarify will block and ask you to write one before proceeding — this is the north star that anchors all downstream clarification.

Preferred order:

1. Use `/speckit.clarify` (structured) – sequential, coverage-based questioning that records answers in a Clarifications section.
2. Optionally follow up with ad-hoc free-form refinement if something still feels vague.

If you intentionally want to skip clarification (e.g., spike or exploratory prototype), explicitly state that so the agent doesn't block on missing clarifications.

Example free-form refinement prompt (after `/speckit.clarify` if still needed):

```text
For each sample project or project that you create there should be a variable number of tasks between 5 and 15
tasks for each one randomly distributed into different states of completion. Make sure that there's at least
one task in each stage of completion.
```

#### Validate the checklist

You should also ask Claude Code to validate the **Review & Acceptance Checklist**, checking off the things that are validated/pass the requirements, and leave the ones that are not unchecked. The following prompt can be used:

```text
Read the review and acceptance checklist, and check off each item in the checklist if the feature spec meets the criteria. Leave it empty if it does not.
```

It's important to use the interaction with Claude Code as an opportunity to clarify and ask questions around the specification - **do not treat its first attempt as final**.

### Stage 3: Constitution (Engineering)

The constitution captures your team's **high-level architectural decisions and overarching implementation principles** for this initiative — the foundational technical direction that directly informs how `/speckit.plan` structures the implementation and how `/speckit.implement` executes it. It sits between the specification (the **what**) and the plan (the **how, technically**), acting as the architectural DNA that ensures all downstream technical choices stay aligned. Where the agent file captures universal product truths that rarely change, the constitution captures initiative-specific engineering guidance that goes beyond those universals.

#### Why the constitution matters

Without a constitution, every planning session reinvents architectural decisions from scratch. With one, the AI has clear engineering guardrails: it knows which patterns to follow, what architectural boundaries to respect, which implementation principles to enforce, and where complexity must be justified. The constitution feeds directly into `/speckit.plan` (Stage 4) — where it actively drives technology choices, architecture patterns, testing strategy, and migration approach — and into `/speckit.implement` (Stage 5) — where it enforces consistency across every generated file.

#### Understanding the three context files

| File | Owner | About | Scope |
|------|-------|-------|-------|
| **Agent file** (CLAUDE.md etc.) | Engineering | Universal product truths | Entire product/repo |
| **Constitution** | Engineering | **Architectural decisions & implementation principles** that drive plan & implement | Project/epic set |
| **Project.md** | Product | **Universal constraints** that bound specifications | Multi-feature project |

- **Agent file**: Universal product architecture that rarely changes ("We deploy to AWS", "All APIs are REST"). The permanent product identity.
- **Constitution**: Initiative-specific architectural decisions AND overarching implementation principles that `/speckit.plan` and `/speckit.implement` use as guardrails. Goes beyond the agent file to capture decisions specific to this initiative ("Library-First architecture", "TDD mandatory", "Max 3 projects", "All APIs versioned", "Integration tests preferred over mocks").
- **Project.md**: Out-of-scope exclusions, shared constraints, and feature list that bound what specifications can include. Product-managed — ensures all feature specs stay within agreed boundaries.

#### Create the constitution (`/speckit.constitution`)

The command runs an interactive workflow:

1. **Codebase scan** — Detects existing architectural patterns and technical decisions across 10 categories, so the constitution reflects what you've already built:

   | Category | Architectural decisions it informs |
   |----------|-----------------------------------|
   | Testing Philosophy | Test strategy, coverage expectations, TDD vs integration-first |
   | Code Quality & Standards | Consistency standards, formatting conventions |
   | Architecture & Modularity | Module boundaries, monorepo structure, dependency direction |
   | Observability & Debugging | Logging strategy, tracing, monitoring approach |
   | CI/CD & Deployment | Deployment architecture, infrastructure patterns |
   | Security & Compliance | Auth approach, secret management, compliance posture |
   | Versioning & Breaking Changes | API versioning strategy, release process |
   | Simplicity & Constraints | Complexity budgets, dependency governance |
   | Migration & Compatibility | Migration strategy, backwards compatibility approach |
   | Internationalisation (i18n) | Translation architecture, locale handling |

   Each category is classified as **Detected** (strong signals — can draft a principle), **Partial** (some signals — needs confirmation), or **No Signal** (nothing found — needs a question).

2. **Interactive Q&A** — Up to 8 targeted questions, asked one at a time, covering gaps and ambiguities from the scan. Each question offers a recommended option with reasoning, and you can accept, pick an alternative, or provide a short custom answer.

3. **Free-text additions** — After the guided questions, you can add any additional principles in your own words (e.g., "All database migrations must be reversible", "No third-party analytics SDKs").

4. **Constitution generation** — Synthesizes scan results, Q&A answers, and free-text additions into a complete `constitution.md` with versioning, governance, and a derivation log.

```text
/speckit.constitution
```

If you already know your principles, provide them directly — the Q&A will confirm and fill gaps:

```text
/speckit.constitution This project follows TDD strictly. We use a microservices architecture. All APIs must be versioned.
```

#### Practical guidance

- **Preparation**: Clean up existing repo documentation (README, architecture notes) before drafting. The scan relies on what's in the repo.
- **Time investment**: Expect 2–3 days of senior engineering time for a thorough constitution on a new initiative.
- **Focus on architectural decisions**: Document the decisions you actually enforce, not generic best practices. "We use PostgreSQL for all persistent storage" is better than "Use appropriate database technology." These decisions directly constrain what `/speckit.plan` generates.
- **Start focused**: 5–7 concrete architectural decisions are better than 15 aspirational ones. You can always amend later.
- **Sign-off**: The constitution includes a Sign-Off table. While advisory, getting engineering and QA alignment before planning prevents rework.

> [!IMPORTANT]
> The constitution **must be finalized before** `/speckit.plan` (Stage 4) can proceed — the plan reads the constitution to shape technology choices, phase gates, and testing strategy. If you skip this step, `/speckit.plan` will detect the missing constitution and offer to run a condensed Q&A inline — but running the full `/speckit.constitution` command separately produces better, more thorough results.

### Stage 4: Planning (Engineering)

> [!NOTE]
> The constitution must be finalized before this stage (Stage 3). If you skip the constitution step, `/speckit.plan` will offer to create one inline.

#### Generate a plan (`/speckit.plan`)

You can now be specific about the tech stack and other technical requirements. Use the `/speckit.plan` command with a prompt like this:

```text
We are going to generate this using .NET Aspire, using Postgres as the database. The frontend should use
Blazor server with drag-and-drop task boards, real-time updates. There should be a REST API created with a projects API,
tasks API, and a notifications API.
```

The output of this step will include a number of implementation detail documents, with your directory tree resembling this:

```text
.
├── CLAUDE.md
├── memory
│  └── constitution.md
├── scripts
│  ├── check-prerequisites.sh
│  ├── common.sh
│  ├── create-new-feature.sh
│  ├── setup-plan.sh
│  └── update-claude-md.sh
├── specs
│  └── 001-create-taskify
│      ├── contracts
│      │  ├── api-spec.json
│      │  └── signalr-spec.md
│      ├── data-model.md
│      ├── plan.md
│      ├── quickstart.md
│      ├── research.md
│      └── spec.md
└── templates
    ├── CLAUDE-template.md
    ├── plan-template.md
    ├── spec-template.md
    └── tasks-template.md
```

Check the `research.md` document to ensure that the right tech stack is used, based on your instructions. You can ask Claude Code to refine it if any of the components stand out, or even have it check the locally-installed version of the platform/framework you want to use (e.g., .NET).

Additionally, you might want to ask Claude Code to research details about the chosen tech stack if it's something that is rapidly changing (e.g., .NET Aspire, JS frameworks), with a prompt like this:

```text
I want you to go through the implementation plan and implementation details, looking for areas that could
benefit from additional research as .NET Aspire is a rapidly changing library. For those areas that you identify that
require further research, I want you to update the research document with additional details about the specific
versions that we are going to be using in this Taskify application and spawn parallel research tasks to clarify
any details using research from the web.
```

During this process, you might find that Claude Code gets stuck researching the wrong thing - you can help nudge it in the right direction with a prompt like this:

```text
I think we need to break this down into a series of steps. First, identify a list of tasks
that you would need to do during implementation that you're not sure of or would benefit
from further research. Write down a list of those tasks. And then for each one of these tasks,
I want you to spin up a separate research task so that the net results is we are researching
all of those very specific tasks in parallel. What I saw you doing was it looks like you were
researching .NET Aspire in general and I don't think that's gonna do much for us in this case.
That's way too untargeted research. The research needs to help you solve a specific targeted question.
```

> [!NOTE]
> Claude Code might be over-eager and add components that you did not ask for. Ask it to clarify the rationale and the source of the change.

#### Validate the plan

With the plan in place, you should have Claude Code run through it to make sure that there are no missing pieces. You can use a prompt like this:

```text
Now I want you to go and audit the implementation plan and the implementation detail files.
Read through it with an eye on determining whether or not there is a sequence of tasks that you need
to be doing that are obvious from reading this. Because I don't know if there's enough here. For example,
when I look at the core implementation, it would be useful to reference the appropriate places in the implementation
details where it can find the information as it walks through each step in the core implementation or in the refinement.
```

This helps refine the implementation plan and helps you avoid potential blind spots that Claude Code missed in its planning cycle. Once the initial refinement pass is complete, ask Claude Code to go through the checklist once more before you can get to the implementation.

You can also ask Claude Code (if you have the [GitHub CLI](https://docs.github.com/en/github-cli/github-cli) installed) to go ahead and create a pull request from your current branch to `main` with a detailed description, to make sure that the effort is properly tracked.

> [!NOTE]
> Before you have the agent implement it, it's also worth prompting Claude Code to cross-check the details to see if there are any over-engineered pieces (remember - it can be over-eager). If over-engineered components or decisions exist, you can ask Claude Code to resolve them. Ensure that Claude Code follows the [constitution](base/memory/constitution.md) as the foundational piece that it must adhere to when establishing the plan.

### Stage 5: Tasks (Engineering)

#### Generate task breakdown (`/speckit.tasks`)

With the implementation plan validated, you can now break down the plan into specific, actionable tasks that can be executed in the correct order. Use the `/speckit.tasks` command to automatically generate a detailed task breakdown from your implementation plan:

```text
/speckit.tasks
```

This step creates a `tasks.md` file in your feature specification directory that contains:

- **Task breakdown organized by user story** - Each user story becomes a separate implementation phase with its own set of tasks
- **Dependency management** - Tasks are ordered to respect dependencies between components (e.g., models before services, services before endpoints)
- **Parallel execution markers** - Tasks that can run in parallel are marked with `[P]` to optimize development workflow
- **File path specifications** - Each task includes the exact file paths where implementation should occur
- **Constitution-driven testing** - Test tasks follow the constitution's testing philosophy (TDD, test-alongside, or as specified)
- **Checkpoint validation** - Each user story phase includes checkpoints to validate independent functionality
- **Jira placeholders** - `[JIRA-EPIC-KEY]` and `[JIRA-XXX]` placeholders for issue tracking integration

The generated tasks.md provides a clear roadmap for the `/speckit.implement` command, ensuring systematic implementation that maintains code quality and allows for incremental delivery of user stories.

**Per-story task files (optional)**: You can configure task generation to create separate files per user story for larger teams:

```text
/speckit.tasks --per-story
```

This creates:
- `tasks.md` - Master index with setup and foundational phases
- `tasks-us1.md`, `tasks-us2.md`, etc. - Individual story task files

You can also set this as the default in `.speckit/config.yaml`:

```yaml
tasks:
  format: per-story  # or "single" (default)
```

#### Create issue tickets (`/speckit.taskstoissues`)

After generating tasks, you can automatically create GitHub issues or Jira tickets:

```text
# Create GitHub issues (default)
/speckit.taskstoissues

# Create Jira tickets
/speckit.taskstoissues --jira PROJ
```

This will create tickets for each task and update the task files with actual ticket keys. Jira Story tickets include Fibonacci-based story point estimates in the standard Story Points field. Each story is created as a demo-able vertical slice linking to spec.md for acceptance criteria.

#### Implementation (`/speckit.implement`)

Once ready, use the `/speckit.implement` command to execute your implementation plan:

```text
/speckit.implement
```

The `/speckit.implement` command will:

- Validate that all prerequisites are in place (constitution, spec, plan, and tasks)
- Parse the task breakdown from `tasks.md`
- Execute tasks in the correct order, respecting dependencies and parallel execution markers
- Follow the testing approach defined in the constitution (TDD, test-alongside, or as specified)
- Provide progress updates and handle errors appropriately

> [!IMPORTANT]
> The AI agent will execute local CLI commands (such as `dotnet`, `npm`, etc.) - make sure you have the required tools installed on your machine.

Once the implementation is complete, test the application and resolve any runtime errors that may not be visible in CLI logs (e.g., browser console errors). You can copy and paste such errors back to your AI agent for resolution.

### Managing Changes Mid-Flight

Requirements change. Here's how to handle changes gracefully without losing momentum or accumulating drift.

#### When to amend vs restart

| Situation | Action | Example |
|-----------|--------|---------|
| Minor clarification | Amend the spec | "Add email validation to registration" |
| New edge case discovered | Amend the spec + re-run `/speckit.clarify` | "Handle concurrent edits on same task" |
| Tech stack change | Amend plan.md + regenerate tasks | "Switch from REST to GraphQL" |
| Fundamental scope change | Re-run from `/speckit.specify` | "Pivot from Kanban to calendar view" |
| Implementation drift | Restart from upstream artifact | See 3-4 iteration rule below |

#### The 3-4 iteration rule

If you've iterated more than 3-4 times on small fixes at the implementation level without resolving the issue, **stop patching and restart from the upstream artifact** (plan.md or spec.md). Continued patching compounds drift between what was specified and what gets built.

Signs you need to restart from upstream:
- Fixes keep introducing new issues
- The implementation no longer resembles the plan
- You're working around the architecture rather than with it
- Test failures cascade across unrelated stories

#### Impact matrix

| What Changed | Update plan.md? | Regenerate tasks? | Notify team? |
|--------------|-----------------|-------------------|--------------|
| Acceptance criteria wording | No | No | Optional |
| New functional requirement | Yes - add to plan | Yes | Yes |
| Removed requirement | Yes - remove from plan | Yes | Yes |
| New user story | Yes | Yes | Yes |
| Non-functional requirement | Yes | Maybe | Yes |
| Clarification (no scope change) | No | No | Optional |
| Tech stack decision | Yes | Yes | Yes |
| Data model change | Yes | Yes | Yes |

#### Artifact stability

| Artifact | Stability | Implication for Changes |
|----------|-----------|------------------------|
| constitution.md | Very Stable | Rarely needs changing; if it does, assess all downstream impact |
| spec.md | Stable | Changes require review; bump version and notify team |
| plan.md | Moderate | May evolve as technical decisions change; regenerate tasks after |
| tasks.md | Volatile | Regenerate from plan changes; don't edit directly |

#### Using the changelog

The Changelog section in spec.md serves as a communication tool:

| Version | When to bump | What it signals |
|---------|-------------|-----------------|
| 1.0 → 1.1 | Clarification or minor addition | "Check what changed, but your work is probably fine" |
| 1.1 → 1.2 | New requirement or edge case | "Review the change - your story may be affected" |
| 1.x → 2.0 | Major scope change | "Stop and re-plan - significant changes ahead" |

</details>

---

## 🔍 Troubleshooting

### Git Credential Manager on Linux

If you're having issues with Git authentication on Linux, you can install Git Credential Manager:

```bash
#!/usr/bin/env bash
set -e
echo "Downloading Git Credential Manager v2.6.1..."
wget https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.6.1/gcm-linux_amd64.2.6.1.deb
echo "Installing Git Credential Manager..."
sudo dpkg -i gcm-linux_amd64.2.6.1.deb
echo "Configuring Git to use GCM..."
git config --global credential.helper manager
echo "Cleaning up..."
rm gcm-linux_amd64.2.6.1.deb
```

## 👥 Maintainers

- Den Delimarsky ([@localden](https://github.com/localden))
- John Lam ([@jflam](https://github.com/jflam))

## 💬 Support

For support, please open a [GitHub issue](https://github.com/gawainclaridge/spec-kit/issues/new). We welcome bug reports, feature requests, and questions about using Spec-Driven Development.

## 🙏 Acknowledgements

This project is heavily influenced by and based on the work and research of [John Lam](https://github.com/jflam).

## 📄 License

This project is licensed under the terms of the MIT open source license. Please refer to the [LICENSE](./LICENSE) file for the full terms.
