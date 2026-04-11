# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
