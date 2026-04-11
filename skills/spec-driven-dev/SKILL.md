---
name: spec-driven-dev
description: >
  Spec-driven development pipeline with 6 phases: Explore, Requirements,
  Design, Task Plan, Implementation, Review. Enforces human approval gates
  between phases. Use when user wants structured feature development, spec-first
  approach, or says "I want to add feature X", "new feature", "implement",
  "build". Keywords: spec, requirements, design document, TDD plan, task plan,
  implementation, code review, pipeline, approval gates, WHEN/SHALL.
---

# Spec-Driven Development

You are operating in **spec-driven development mode**.
This project uses a 6-phase pipeline with human approval gates between each phase.

## Pipeline

```
Explore → [APPROVE] → Requirements → [APPROVE] → Design → [APPROVE] → Task Plan → [APPROVE] → Implementation → [APPROVE] → Review → [APPROVE] → Done
```

Each phase has a dedicated prompt template. Read the template for the **current** phase before generating any output.

## Quick Reference

| Action | Command |
|--------|---------|
| Check state | `sh ./scripts/pipeline.sh status` |
| Start feature | `sh ./scripts/pipeline.sh init [--branch] <name>` |
| Register output | `sh ./scripts/pipeline.sh artifact [path]` |
| Advance phase | `sh ./scripts/pipeline.sh approve` (only after user says "approve") |
| Mark task done | `sh ./scripts/pipeline.sh task T-N` (implementation phase only) |
| Check docs | `sh ./scripts/pipeline.sh docs-check` |
| Multi-feature | Add `--feature <name>` before any command |

**Hard rules:** check status first · never skip phases · never auto-approve · save artifacts to `.spec/features/<feature>/` · max 3 revisions then ask user

**Config:** `.spec/config.yaml` → `context` (all phases), `rules.<phase>` (per phase), `test_skill`, `test_reference`, `docs_dir`, `auto_branch`, `branch_prefix`

**Phase flow:** read template → generate artifact → save → `artifact` → present → wait for "approve" → `approve`

## Phases

| # | Phase          | Template                        | Produces                        |
|---|----------------|---------------------------------|---------------------------------|
| 1 | Explore        | `./templates/explore.md`        | Exploration & research document |
| 2 | Requirements   | `./templates/requirements.md`   | Formal requirements document    |
| 3 | Design         | `./templates/design.md`         | Architecture & design document  |
| 4 | Task Plan      | `./templates/task-plan.md`      | TDD implementation plan         |
| 5 | Implementation | `./templates/implementation.md` | Implementation report           |
| 6 | Review         | `./templates/review.md`         | Code review document            |

## State Machine

The pipeline state is managed via a shell script. Use these commands:

```sh
# Check current phase and progress
sh ./scripts/pipeline.sh status

# Start a new feature pipeline
sh ./scripts/pipeline.sh init <feature-name>

# Start with auto-branch (creates git branch <prefix><name>)
sh ./scripts/pipeline.sh init --branch <feature-name>

# Register the artifact you generated for the current phase
sh ./scripts/pipeline.sh artifact [path]

# Advance to the next phase (only after user says "approve")
sh ./scripts/pipeline.sh approve

# View revision history for current or specified phase
sh ./scripts/pipeline.sh revisions [phase]

# View all features and their status
sh ./scripts/pipeline.sh history

# Check project documentation status
sh ./scripts/pipeline.sh docs-check

# Mark an implementation task as completed (enables resume)
sh ./scripts/pipeline.sh task <T-N>
```

### Parallel Pipelines

When multiple features are active simultaneously, add `--feature <name>` before the command:

```sh
sh ./scripts/pipeline.sh --feature auth-flow status
sh ./scripts/pipeline.sh --feature payment approve
```

Without the flag, the pipeline auto-detects the active feature. If more than one is active, it will error and prompt you to use `--feature`.

## Project Configuration

If the file `.spec/config.yaml` exists in the project root, read it before starting any phase.

- **`context`** — project-wide background (tech stack, conventions, repo structure). Treat as extra context for ALL phases.
- **`rules.<phase>`** — phase-specific rules that supplement (not replace) the template instructions.
- **`test_skill`** (optional) — name of an installed skill for test generation. If present, delegate test specification (Design §2.8) and test task creation (Implementation) to this skill. Pass Correctness Properties and Coverage Matrix as input.
- **`test_reference`** (optional) — glob or file paths pointing to representative test files. If present, use these as the style reference for all generated tests. If absent, auto-discover adjacent tests.
- **`docs_dir`** (optional) — directory for project documentation, default: `.spec`. The agent reads documentation from this directory for project context and writes generated docs here.
- **`doc_freshness_days`** (optional) — number of days after which a generated doc is considered stale, default: `30`. Used by `pipeline.sh docs-check` to flag outdated documentation.
- **`rules.docs`** (optional) — rules for documentation generation, analogous to `rules.explore` etc. Example: `"Skip FILES.md — no file storage"`, `"Always include Mermaid diagrams in ARCHITECTURE.md"`.
- **`auto_branch`** (optional) — boolean, default: `false`. When `true`, `pipeline.sh init` automatically creates a git branch `<branch_prefix><feature-name>` without needing `--branch`. Use `--no-branch` to override.
- **`branch_prefix`** (optional) — string, default: `feature/`. Prefix for auto-created branches. Examples: `bug/`, `fix/`, `hotfix/`, or empty string for no prefix.

Phase-specific rule keys: `rules.explore`, `rules.requirements`, `rules.design`, `rules.task-plan`, `rules.implementation`, `rules.review`, `rules.docs`.

Injection order: **context → phase rules → template instructions.**

If the file does not exist, skip this step.

## Pre-flight Checklist

Before starting any pipeline work, follow these steps in order:

1. **Check pipeline state**: run `pipeline.sh status`.
   - If exactly one active pipeline exists → resume from the current phase. Do NOT run `init` again.
   - If no active pipeline → proceed to step 2.
   - If multiple active pipelines → ask the user which feature to work on, then use `--feature <name>` with all subsequent commands.
2. **Read project config**: check if `.spec/config.yaml` exists.
   - If yes → read it, apply `context` to all phases, note `rules.*` for each phase.
   - If no → proceed without config (defaults apply).
3. **Check documentation**: run `pipeline.sh docs-check`.
   - **Docs directory missing** → suggest: *"Project documentation (<docs_dir>/) not found. I can generate it to better understand your codebase. Say 'generate docs' or 'skip'."* This is a soft suggestion — the pipeline works without documentation.
   - **Docs exist, stale files found** → suggest: *"Some docs are outdated (<file>: <N> days old). Regenerate before starting? Say 'update docs' or 'skip'."* If user agrees, read `./templates/docs-maintenance.md` for the Stale doc regeneration workflow.
   - **Docs exist, all fresh** → use as supplementary context for ALL phases. Read `<docs_dir>/README.md` for the documentation map.
4. **Start pipeline**: run `pipeline.sh init <feature-name>`.

For documentation generation, staleness checks, and regeneration workflows, read `./templates/docs-maintenance.md`.

## When to Use This Pipeline

**Use the pipeline for:**
- New features ("add user authentication", "implement search")
- Significant changes to existing features (new behavior, API changes, schema migrations)
- Bug fixes that require investigation and design (root cause unknown, multiple components affected)

**Do NOT use the pipeline for:**
- Trivial changes: typo fixes, config tweaks, single-field additions, comment updates
- Dependency updates with no code changes
- Pure refactors with no behavioral change (unless they are large and risky)

For trivial changes, just make the change directly — no pipeline needed. The skill is designed for work that **benefits from structured thinking before coding**.

### Fast-track mode

For **bug fixes with a known reproduction** or other small, well-understood changes:

- All 6 phases still apply — do not skip phases.
- Each phase produces a **minimal artifact**: 1-paragraph exploration, 1–2 requirements, focused design (CPs only for the bug scenario), 4–5 tasks (RED→GREEN→CODE→VERIFY→GATE), brief implementation report, short review.
- Each template contains a "Fast-track mode" section with phase-specific minimums. Follow those rules when fast-track applies.

**When to activate:** The agent activates fast-track when the user describes a bug with a known reproduction step, or a small, scoped change where investigation is unnecessary. At the start, announce: *"Using fast-track mode — all 6 phases, minimal artifacts."* If the user says "full pipeline", switch to the standard (non-abbreviated) flow.

**Scope:** This pipeline is designed for a **single project or monorepo**. It is not intended for features that span multiple independent repositories. Within a monorepo, use one `.spec/` directory at the repository root.

## Rules

1. **MUST check status first.** Run `pipeline.sh status` before doing anything. Never generate phase output without checking status. If multiple active pipelines exist, use `--feature <name>` with all commands.
2. **Never skip phases.** Follow the order: explore → requirements → design → task-plan → implementation → review.
3. **Never auto-approve.** Wait for the user to explicitly say "approve" or equivalent.
4. **Read the template.** Before generating output for a phase, read the corresponding template file.
5. **Save artifacts.** Save generated documents to `.spec/features/<feature>/` and register them with `pipeline.sh artifact`.
6. **Each phase produces one artifact** that becomes input for the next phase.
7. **Artifacts are cumulative.** Each phase reads all prior artifacts.
8. **Revision limit.** If the user rejects the same artifact 3 times in a row, stop generating and ask: "We've gone through 3 revisions — could you clarify what's missing or what direction you'd prefer?" Do not continue revising without explicit guidance. The review phase's internal fix cycle has a separate limit: **maximum 3 fix cycles** (see `templates/review.md` Iteration Workflow). After 3 fix cycles without `PASS`, escalate to user.
9. **Surface uncertainty.** If you are unsure about intent, scope, or technical approach — say so explicitly. State the assumption you would make and ask the user to confirm or correct it. Never silently assume.
10. **Write in the user's language.** Detect the user's language from their first message and use it for ALL pipeline artifacts and conversational replies. What stays in English:
    - Formal grammar keywords: `WHEN`, `SHALL`, `the system`
    - Requirement IDs: `REQ-X.Y`
    - Task IDs: `T-N`
    - Instruction keywords: `CRITICAL`, `IMPORTANT`, `NOTE`, `DO NOT`, `GOAL`
    - Correctness Property format: `Property N`, `Category`, `For all`, `Validates`
    - Code identifiers, file paths, shell commands, Mermaid node labels
    - Documentation in `<docs_dir>/` (`.spec/`) — always English (see `templates/docs/README.md`)

    Everything else — prose, section headers, descriptions, interview questions, explanations — is written in the user's language.

## Error Recovery

- **Revising an artifact:** Overwrite the file, re-register with `pipeline.sh artifact`, and present the updated version to the user. The previous version is automatically saved as a revision in the feature’s `revisions/` directory. Use `pipeline.sh revisions` to view past revisions.


## Documentation Maintenance

After the pipeline reaches `phase=done`, read `./templates/docs-maintenance.md` § Documentation Maintenance to check if project documentation needs updating.

## Quick Start (for the agent)

When the user says something like "I want to add feature X":

1. Follow the **Pre-flight Checklist** (status → config → docs-check → init)
2. Read `./templates/explore.md` — investigate the problem space (use `.spec/` docs as context if available)
3. Generate the exploration document → save to `.spec/features/<feature>/explore.md`
4. Run `pipeline.sh artifact`
5. Present to user → wait for "approve"
6. Run `pipeline.sh approve` → phase advances to requirements
7. Read `./templates/requirements.md` → follow its interview process
8. Generate the requirements document → save, register artifact, present, wait for approve
9. Repeat for design phase
10. Read `./templates/task-plan.md` → generate TDD implementation plan (no code yet)
11. Save, register artifact, present, wait for approve
12. Read `./templates/implementation.md` → execute the task plan (write tests, write code, mark tasks done)
13. Save implementation report, register artifact, present, wait for approve
14. Read `./templates/review.md` → review the written code against all prior artifacts
15. If findings exist → agent fixes code using TDD fix plan (exploration test → fix → re-test) → re-reviews → repeats until verdict is `PASS` (max 3 fix cycles; escalates to user if not resolved)
16. Present final review document (verdict `PASS`) → wait for approve
17. After review is approved → `pipeline.sh approve` → pipeline complete
18. Check if documentation needs updating (see Documentation Maintenance)
