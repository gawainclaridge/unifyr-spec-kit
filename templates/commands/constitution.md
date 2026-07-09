---
description: "[Deprecated alias] Renamed to /speckit.charter. Establishes the Engineering Charter (architectural decisions & implementation principles) that drive /speckit.plan and /speckit.implement."
handoffs:
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

## Deprecated alias

`/speckit.constitution` has been **renamed to `/speckit.charter`** (the artifact is now the "Engineering Charter"). This alias still works and will for a deprecation period, but please switch to `/speckit.charter`.

**Do this now:**

1. Tell the user once, briefly: "Note: `/speckit.constitution` is now `/speckit.charter` — running the charter workflow."
2. Load the command file `charter.md` from this same commands directory (`.specify` install location, alongside this file) and **follow its instructions exactly**, passing along the `$ARGUMENTS` above unchanged.
3. Everything the charter command does — the codebase scan, Q&A, drafting, and writing to the resolved `CHARTER` path — applies identically here. The setup script still exposes the target path as both `CHARTER` and the legacy `CONSTITUTION` (same value), and resolves an existing legacy `constitution.md` automatically when no `charter.md` exists yet.

Do not maintain any separate behavior in this file — it exists only to forward to `/speckit.charter`.
