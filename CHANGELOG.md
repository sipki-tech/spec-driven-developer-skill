# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2026-04-22

### Added
- **Standalone documentation workflow** — first-class docs generation/update flow without starting a feature pipeline. Driven by user phrases like *"generate documentation"*, *"update docs"*, *"actualize documentation"*. Uses its own state machine: `.spec/.docs-queue.kv`.
- **`docs-init [--all|--update|<template>...]`** — creates the docs queue. `--all` queues every template from `templates/docs/`. `--update` queues only stale templates (uses scope-aware staleness from `docs-check`). Explicit template names queue exactly those.
- **`docs-next`** — prints next pending template (name + path, tab-separated). Prints a fresh-chat hint to stderr after position 3 (sequential mode safety).
- **`docs-done <template>`** — marks a template as completed and advances the queue. Reports remaining count.
- **`docs-status`** — JSON queue status: `total`, `completed`, `current`, `pending[]`, `mode`, `docs_dir`, `created_at`. Returns `{"exists": false}` when no queue.
- **`docs-reset`** — clears `.spec/.docs-queue.kv` (with completion summary).
- **Subagent execution mode** for docs workflow — recommended default when toolset supports dispatch (Task tool, Composer, etc.). Up to 3 subagents in parallel, each one template. Controller verifies metadata after each (file exists, `<!-- generated: ... -->` on line 1, ≥ 50 lines), with max 2 retries before escalation. Sequential mode is fallback when subagent unavailable.

### Changed
- **`docs-maintenance.md`** — new top-level section "Standalone Documentation Workflow" with Step 2.5 "Evaluate Execution Strategy" (subagent default + sequential fallback). Pre-pipeline check now routes "generate docs" / "update docs" answers through the new queue commands. Legacy ad-hoc regeneration steps preserved as reference.
- **`SKILL.md`** — added "generate documentation", "update docs", "actualize the documentation" to frontmatter keywords. New "Standalone Documentation Workflow" section before Pre-flight Checklist. Quick Reference and State Machine sections list the new commands.
- **`pipeline.sh` version bumped to 1.4.0**, help text updated.

### Added (antipatterns)
- **Documentation (Standalone Workflow)** section with 5 entries: "All templates in one window", "Sequential when subagent available", "Bundled subagent dispatch", "Skipping metadata verification", "Running `init <feature>` for docs request".

## [1.3.0] - 2026-04-17

### Added
- **`finish` command** — `pipeline.sh finish merge|discard|archive` finalizes a feature after the pipeline completes: merges the feature branch into main (or discards/archives it), removes the git worktree if one was created, and marks the feature as `done`.
- **Worktree support** — `pipeline.sh init --worktree <feature>` creates a dedicated git worktree for the feature branch. `auto_worktree: true` in `.spec/config.yaml` enables this by default. Worktrees are automatically removed on `finish` and `abandon`.
- **Step 0: Fresh Verification in Review** — before accepting an implementation report, the agent must re-run the full test suite, build, and lint. Reusing stdout from a previous run is explicitly prohibited.
- **Complexity field in Task Plan** — optional `Complexity: mechanical|standard|complex` annotation per task in the Task Plan template. Used by the implementation agent to evaluate execution strategy.
- **Prohibited Formulations in Task Plan** — new section listing 7 banned placeholder patterns (e.g. "Add necessary tests", "Handle edge cases", "Update as needed") with corrected examples and a Quality Checklist entry.
- **Root Cause Investigation in Explore fast-track** — 4-step investigation procedure (read errors → reproduce → check recent changes → trace data flow) with a hard guard: DO NOT propose a fix without identifying the root cause. Root cause is now a required field in the Explore output format.
- **Step 1.5: Evaluate Execution Strategy in Implementation** — optional hint for agents that support subagent dispatch. When 6+ tasks are present and at least one is `Complexity: complex`, the agent may act as a controller and delegate individual tasks to subagents. Strict rules: one subagent per task, controller verifies tests after each, GATE task always stays with the controller.

### Changed
- **`SKILL.md`** — added Branch Finishing section, updated Quick Reference (`init [--branch|--worktree]`), State Machine (`finish merge|discard|archive`), and Config table (`auto_worktree`, `worktree_dir` keys).

### Removed
- **`ROADMAP.md`** — removed; all planned items have been implemented.

### Fixed (antipatterns)
- **Symptom-level fix** — added to `antipatterns.md` § Explore: proposing a fix that masks the symptom without identifying the root cause.
- **Unsupervised subagent** — added to `antipatterns.md` § Implementation: dispatching a subagent and accepting its output without running the test suite.

## [1.2.0] - 2026-04-14

### Added
- **`config-check` command** — validates `.spec/config.yaml` keys against a whitelist and checks types (`doc_freshness_days` numeric, `auto_branch` boolean). Flags unknown keys (e.g. typos like `ruls.explore`).
- **`inject` command** — `pipeline.sh inject <phase> <path>` registers a pre-written artifact, skips intermediate phases (marked `(injected)` in history), and jumps to the target phase. Lightweight content validation for requirements (`WHEN`/`SHALL`) and design (`Correctness`/`Property`).
- **`abandon` command** — `pipeline.sh abandon [feature]` marks an active pipeline as done without completing remaining phases. Artifacts are preserved.
- **`config.yaml.example`** — template file in `.spec/` with all 14 supported keys and descriptions.
- **PBT fallback** — `design.md` §2.8 now allows deterministic fixtures when Property-Based Testing is impractical.

### Changed
- **Internal "Phase N" → "Step N"** — renamed in-template sub-headings (`requirements.md`, `design.md`, `task-plan.md`, `review.md`) to avoid confusion with pipeline phases.
- **Config documentation** — replaced prose list in `SKILL.md` with a compact table (`Key | Type | Default | Description`).

### Fixed
- **`eval` removed from `docs-check`** — eliminated shell injection vector; word-splitting on `$patterns` with explicit SC2086 disable.
- **`docs-check` deduplication** — extracted `check_file_staleness()` helper; removed duplicated staleness logic.
- **`for $(find)` → `while read`** — replaced unsafe `for f in $(find ...)` loops in `cmd_revisions` and `cmd_docs_check` with `find | while IFS= read -r f` (or temp-file redirect) to handle paths with spaces.

### Security
- **Shell injection** — `eval` usage in `cmd_docs_check` replaced with safe word-splitting pattern.

## [1.1.1] - 2026-04-11

### Fixed
- **KV newline validation** — `kv_validate_value()` used unreliable `case` pattern with `$(printf '\n')` for newline detection; replaced with portable `wc -l` check. Fixes false-positive "KV value must not contain newlines" errors on some shells.
- **Docs-check pre-flight enforcement** — Pre-flight Checklist step 3 now marked MUST; agent must wait for user response ('generate docs' / 'update docs' / 'skip') before proceeding to `init`. Previously the agent could silently skip docs-check and start feature work without documentation.
- **Project docs placed in wrong directory** — Added explicit directory separation notes in 5 locations (`_preamble.md`, `SKILL.md` rule 5, `SKILL.md` pre-flight, `docs/README.md`, `docs-maintenance.md`, `explore.md`) to prevent agents from placing project documentation (`README.md`, `ARCHITECTURE.md`, etc.) into `.spec/features/<feature>/` instead of `<docs_dir>/` (default: `.spec/`).

## [1.1.0] - 2026-04-11

All changes since v1.0.0 — collapsed from development history into a single release.

### BREAKING
- **6-phase pipeline** — Explore → Requirements → Design → Task Plan → Implementation → Review → Done (was 3 phases). Task Plan (phase 4) produces implementation plan; Implementation (phase 5) executes it with real code; Review (phase 6) self-healing loop with max 3 fix cycles.
- **Persistent per-feature artifacts** — `.spec/features/<feature>/` replaces the old `.spec-driven-dev/state/` directory. Each feature gets its own directory with KV state, JSON mirror, phase artifacts, revisions, and approved snapshots.
- **Config moved** — `.spec-driven-dev/config.yaml` → `.spec/config.yaml`.
- **Migrated to skills.sh** — distribution via `npx skills add`. Skill files in `skills/spec-driven-dev/`. Entry point `SKILL.md` with YAML frontmatter.
- **Removed commands** — `reset`, `publish`, `rollback` removed. Use `pipeline.sh init <new-feature>`, `pipeline.sh revisions`, and re-register artifacts instead.

### Added
- **`pipeline.sh` state machine** — POSIX sh, zero dependencies. Commands: `init`, `status`, `approve`, `artifact`, `history`, `revisions`, `docs-check`, `task`, `version`, `help`. `--feature <name>` global flag for parallel pipelines.
- **6 phase templates** — `explore.md`, `requirements.md`, `design.md`, `task-plan.md`, `implementation.md`, `review.md`. Each with `## Done when` gate, `## Language` section (user language support), `### Fast-track mode` section for small bug fixes.
- **`templates/_preamble.md`** — shared Pipeline Integration and Project Context boilerplate, referenced by all 6 templates.
- **`templates/docs-maintenance.md`** — documentation workflows (pre-pipeline check, stale doc regeneration, post-pipeline maintenance) extracted from `SKILL.md`.
- **`templates/reference/`** — on-demand reference files: `correctness-properties-examples.md` (5 Correctness Property categories), `antipatterns.md` (extracted from review + task-plan), `review-reference.md` (severity table + checklist), `task-types.md` (task type definitions).
- **Self-documenting mechanic** — 14 doc templates in `templates/docs/` (bootstrap, agents-index, core, development, errors, auth, database, api, deployment, infrastructure, clients, security, feature-flags, background-jobs). Pre-pipeline soft gate, post-pipeline targeted update suggestions.
- **Content-aware docs-check** — `pipeline.sh docs-check` reads `<!-- scope: ... -->` metadata from doc templates and uses `git log --since=<generated_date> -- <patterns>` to detect scope changes. Docs with no scope changes stay fresh regardless of age. JSON output includes `scope_changed` field. Falls back to age-based staleness without scope.
- **Scope metadata in 14 doc templates** — each `templates/docs/*.md` has `<!-- scope: ... -->` first line with glob patterns for relevant source files.
- **Freshness tracking** — `<!-- generated: YYYY-MM-DD, template: name.md -->` metadata in generated docs. `doc_freshness_days` config (default: 30). Per-file `age_days`, `stale`, `template` in JSON output.
- **Auto-branch on init** — `pipeline.sh init --branch / --no-branch`. Config: `auto_branch` (default: `false`), `branch_prefix` (default: `feature/`). Branch stored in KV and JSON.
- **Resume tracking** — `pipeline.sh task <T-N>` marks tasks complete. `last_completed_task` in KV/JSON. Cleared on phase advance.
- **Fast-track mode** — minimal artifacts for small bug fixes with known reproduction. All 6 phases still apply; each produces abbreviated output.
- **`config.yaml` support** — `context`, `rules.<phase>`, `rules.docs`, `test_skill`, `test_reference`, `docs_dir`, `doc_freshness_days`, `auto_branch`, `branch_prefix`.
- **Test Style Cascade** — 3-tier priority: (1) dedicated test skill, (2) adjacent existing tests, (3) from scratch. Documented in design.md §2.8 and task-plan.md.
- **Review phase** — Change Set Discovery, Requirements Traceability, Design Conformance, Code Quality, Security Scan. Verdict: `PASS` / `NEEDS_CHANGES` / `BLOCK`. Self-healing fix cycle (max 3), then escalate. Verification Evidence requires real stdout.
- **`read_config` helper** — reusable function for reading `.spec/config.yaml` keys with defaults.
- **`SCRIPT_DIR` / `SKILL_DIR` variables** — resolve the skill's template directory at runtime.
- **Quick Reference section** in `SKILL.md` — command table, hard rules, config summary, phase flow one-liner.
- **Pre-flight Checklist** in `SKILL.md` — status → config → docs-check → init.
- **User language support** (Rule 10) — artifacts written in user's language; formal keywords (`WHEN`/`SHALL`, IDs, code) stay English.
- **`ROADMAP.md`** — future improvement backlog.

### Changed
- **KV-store hardening** — `write_field()` validates via `kv_validate_value()`, rejecting `=`, `|`, newlines. `kv_escape_sed()` escapes `&`, `\`, `/` for safe sed. `validate_kv()` checks per-line format.
- **`cmd_docs_check()`** — rewritten with scope-aware staleness and `scope_changed` JSON field.
- **`cmd_init()`** — flag parser supporting `--branch`/`--no-branch` before feature name. Feature name max 64 chars.
- **`rebuild_json()`** — outputs `branch`, `last_completed_task`, `review_base_commit`. Validates required fields before generating.
- **`review.md`** — severity table and antipatterns extracted to `reference/`. Added Verification Evidence, Documentation Consistency check (§3.6).
- **`task-plan.md`** — task type definitions extracted to `reference/`. Added Tier 2 fallback for test discovery, work type / task type terminology note.
- **`design.md`** — Correctness Property worked examples (5 categories) extracted to `reference/`. ADR versioning guidance. Test Style Source references task-plan.md cascade.
- **`templates/docs/README.md`** — scope metadata rule, single-owner rule, language-neutrality note, multi-service guidance.
- **`templates/docs-maintenance.md`** — content-aware staleness documentation.
- **Hot-path reduction** — −333 lines across SKILL.md and phase templates. Content preserved in on-demand reference files.

### Fixed
- **JSON injection** — artifact paths with quotes no longer corrupt `pipeline.json`.
- **Atomic writes** — `pipeline.json` uses tmp+mv.
- **POSIX compliance** — `case` patterns instead of `grep -qE`; `find` instead of `ls -A`.
- **Path traversal** — `artifact` command rejects `..` in paths.
- **sed injection** — `write_field()` no longer corrupts values containing `&` or `\`.

### Removed
- `install.sh`, IDE adapters (`CLAUDE.md`, `.windsurfrules`, `.github/copilot-instructions.md`, `.cursor/rules/`) — replaced by skills.sh.
- `templates/verify.md` — Verify phase merged into Review.
- `prompts/` directory — migrated to `templates/docs/`.
- `reset`, `publish`, `rollback` commands.

## [1.0.0] - 2026-03-01

### Added
- Initial release
- 3-phase pipeline: Requirements → Design → Implementation
- POSIX shell state machine (pipeline.sh)
- Phase templates: requirements.md, design.md, implementation.md
- IDE adapters: Cursor, Windsurf, Claude Code, VSCode Copilot
- Installer script with IDE auto-detection
