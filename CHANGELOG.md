# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.0] - 2026-04-08

### Added
- **`templates/_preamble.md`** — shared Pipeline Integration and Project Context instructions extracted from all 6 phase templates. Each template now references this file instead of repeating ~24 lines of identical boilerplate.
- **`templates/docs-maintenance.md`** — documentation workflows (pre-pipeline check, stale doc regeneration, owner template lookup table, post-pipeline maintenance) extracted from `SKILL.md`. Loaded on demand instead of cluttering the agent's entry point.
- **`templates/reference/correctness-properties-examples.md`** — worked examples for all 5 Correctness Property categories (Equivalence, Absence, Round-trip, Propagation, Exclusion) extracted from `design.md` §2.6. Read on demand.

### Changed
- **`SKILL.md`** reduced by 95 lines: Documentation Context and Documentation Maintenance sections replaced with compact references to `templates/docs-maintenance.md`.
- **All 6 phase templates** (`explore.md`, `requirements.md`, `design.md`, `task-plan.md`, `implementation.md`, `review.md`): Pipeline Integration and Project Context sections replaced with a 4-line reference to `templates/_preamble.md` plus phase-specific input/output notes.
- **`design.md` §2.8 Test Style Source** now references the canonical priority cascade in `task-plan.md` instead of duplicating it. Eliminates the inconsistency where `design.md` was missing the Tier 2 fallback strategy present in `task-plan.md`.
- **`design.md` §2.6 worked examples** replaced with a one-line reference to `templates/reference/correctness-properties-examples.md` (−105 lines from the hot path).

### Summary
Hot-path reduction: **−333 lines** across SKILL.md and the 6 phase templates (2314 → 1981 lines). All content preserved in on-demand reference files — no information lost.

## [2.4.0] - 2026-04-08

### Added
- **Quick Reference section** in `SKILL.md` — compact command table, hard rules, config summary, and phase flow one-liner inserted after the Pipeline diagram. Gives agents fast orientation without reading the full document.
- **Correctness Property worked examples for all 5 categories** in `design.md` §2.6 — added Absence, Round-trip, Propagation, and Exclusion examples alongside the existing Equivalence example. Each includes §2.6 definition + §2.8 test table entry + explanation.

### Changed
- `design.md` §2.6 "Worked example" renamed to "Worked examples" (now covers all 5 categories).

## [2.3.0] - 2026-04-08

### Added
- **Review fix cycle limit** — self-healing loop in Review phase now has a maximum of **3 fix cycles** (initial review + 3 fix→re-review iterations = up to 4 review documents). After 3 cycles without `PASS`, the agent stops and escalates to the user with a summary of resolved/remaining findings and options to proceed. Prevents infinite loops when fixes introduce new issues.
- **Implementation task rollback** — if a task fails after 3 implementation attempts, the agent stops and presents the user with options: (a) revert the failed task's files, (b) debug together, (c) full rollback to `review_base_commit`. Prevents silently leaving the project in a broken state.
- **Expanded security scan scope** — Review Phase 5 (Security Scan) now audits the full request handling chain for new public API endpoints (routing → middleware → auth → handler → response), not just changed files. Added "API chain audit" row to the security check table.
- **"When to Use This Pipeline" section** in `SKILL.md` — explicit guidance on when the 6-phase pipeline is appropriate (features, significant changes, complex bugs) vs. when it's unnecessary (typos, config tweaks, dependency updates). Clarifies that bug fixes with known reproduction use all phases but shorter.
- **Project scope statement** — `README.md` and `SKILL.md` now explicitly state the pipeline is designed for a single project or monorepo, not for cross-repository architectures.
- **Correctness Property worked example** in `design.md` — §2.6 now includes a language-neutral end-to-end example: property definition → property-based test table entry → generator description, bridging the gap between §2.6 and §2.8.
- **Freshness metadata validation** in `SKILL.md` — after generating a doc, the agent must verify the first line contains valid `<!-- generated: ... -->` metadata. Files with missing or malformed metadata are silently skipped by `docs-check`.
- **Tier 2 test discovery fallback** in `task-plan.md` — when adjacent tests are not found, the search broadens to parent directory → project-wide test directories → CI config before falling through to Tier 3.
- **Language-neutrality note** in `templates/docs/README.md` — template author rules now clarify that Go-like examples are illustrative; generated docs must use the project's actual language and idioms.
- New antipattern in `review.md`: "Infinite fix loop" — 3 fix cycles max, then escalate.
- New antipattern in `implementation.md`: "Silently leaving broken state" — stop after 3 failed attempts, document, ask user.

### Changed
- **SKILL.md Rule 8** — review phase fix cycle now references the 3-iteration limit instead of stating "without limit".
- **SKILL.md Quick Start step 15** — updated to mention max 3 fix cycles with escalation.
- **README.md** — Architecture Decision #8 updated to mention fix cycle limit. Review phase description mentions escalation after 3 cycles.
- Version bumped to 2.3.0.

## [2.2.0] - 2026-04-08

### Added
- **`--feature <name>` global flag** — explicitly select which feature to operate on. Required when multiple pipelines are active simultaneously. Works with all commands: `status`, `artifact`, `approve`, `revisions`.
  ```sh
  pipeline.sh --feature auth-flow status
  pipeline.sh --feature payment approve
  ```
- When multiple active pipelines are detected without `--feature`, the error message now includes a hint: `use --feature <name> to select one`.
- **KV state validation** — `rebuild_json()` now validates required fields (`feature`, `phase`, `created_at`) before generating JSON. Corrupted pipeline state files produce a clear error with recovery instructions instead of silently generating invalid JSON.
- **Feature name length limit** — `pipeline.sh init` now rejects feature names longer than 64 characters.
- **SKILL.md parallel pipeline guidance** — Rule 1 and Pre-flight Checklist Step 1 now document `--feature` usage when multiple pipelines are active.

### Changed
- **requirements.md** — Layer 3 (Constraints and Edge Cases) now asks about performance constraints: latency, throughput, memory, resource usage, rate limits.
- **design.md** — §2.4 ADR section now includes guidance for Versioning & Backward Compatibility ADR when features change public APIs, schemas, or protocols. Quality Checklist and Done When updated with conditional versioning ADR requirement.
- **task-plan.md** — added terminology note clarifying that *work type* (bug fix/feature/migration) and *task types* (RED/GREEN/CODE/VERIFY/GATE) are orthogonal concepts.
- **review.md** — added §3.6 Documentation Consistency check: Mermaid diagrams match actual code structure, component names consistent, data flows accurate. Done When references §3.1–§3.6.
- **docs/README.md** — added Multi-Service / Monorepo Projects guidance: one `.spec/` per repo, core templates cover overall architecture, domain templates may run per-service.
- **README.md** — enriched phase descriptions in the intro: each phase now includes key activities and output document type.
- Version bumped to 2.2.0.

## [2.1.0] - 2026-04-08

### BREAKING
- **6-phase pipeline** — pipeline is now 6 phases: Explore → Requirements → Design → Task Plan → Implementation → Review → Done (was 5 phases). Phase 4 "Implementation" renamed to "Task Plan" (planning only, no code). New Phase 5 "Implementation" executes the task plan (writes tests and code).
- **Removed `rollback` command** — `pipeline.sh rollback` no longer exists. Use `pipeline.sh revisions` to view past revisions and re-register corrected artifacts.

### Added
- `templates/task-plan.md` — Phase 4 template (renamed from the old `implementation.md`). Produces a TDD implementation plan document. The agent does NOT write code in this phase.
- `templates/implementation.md` — NEW Phase 5 template. The agent executes the approved task plan: writes real tests, writes real code, runs the suite, marks each completed task with `[x]` checkbox in the implementation report.
- `review_base_commit` now recorded when task plan (Phase 4) is approved, before any code is written.
- `rules.task-plan` config key for Phase 4 rules.

### Changed
- `pipeline.sh` rewritten for 6 phases: `next_phase()` has 7 transitions, `phase_number()` returns 1–6+✓, progress bar uses `Ex→Rq→Ds→Tp→Im→Rv`, all counters show `/6`.
- `templates/review.md` updated to Phase 6: reads `history[4]` (implementation report), references "task plan" instead of "implementation plan", cross-references implementation report for task completion verification.
- `SKILL.md` updated: 6-phase pipeline diagram, phases table (Task Plan + Implementation), removed rollback from State Machine commands, added `rules.task-plan`, Quick Start shows 18-step 6-phase flow.
- `README.md` updated: 6-phase intro, fixed `config.yaml` example (removed duplicate `rules:` key), file structure shows `task-plan.md` + `implementation.md`, removed rollback from commands, typical session shows task execution step, added Architecture Decision #9 (Task Plan / Implementation split).
- Version bumped to 2.1.0

## [2.0.0] - 2026-04-08

### BREAKING
- **Persistent per-feature artifacts** — pipeline artifacts are now saved permanently in `.spec/features/<feature>/` and committed to git. The temporary `.spec-driven-dev/state/` directory is no longer used.
- **Removed `reset` command** — new feature = new directory. Use `pipeline.sh init <new-feature>` instead.
- **Removed `publish` command** — artifacts are already in `.spec/features/` and tracked by git; no separate publish step needed.
- **Config moved** — `.spec-driven-dev/config.yaml` → `.spec/config.yaml`

### Changed
- `pipeline.sh` rewritten for per-feature directories: each feature gets `.spec/features/<feature>/` with `pipeline.kv`, `pipeline.json`, phase artifacts, `revisions/`, and `approved/` subdirectories
- `artifact` command now accepts optional path (defaults to `.spec/features/<feature>/<phase>.md`)
- `history` command now scans all `.spec/features/*/pipeline.kv` and shows feature list with status
- `status` command shows completed features when no active pipeline exists
- New helpers: `set_feature_context()`, `detect_active_feature()`, `resolve_feature()` — support multi-feature scanning
- All 5 templates updated: artifact paths changed to `.spec/features/<feature>/<phase>.md`, config path to `.spec/config.yaml`
- `SKILL.md` updated: removed reset/publish references, updated Quick Start, Error Recovery, Pre-flight Checklist, all path references
- `README.md` updated: file structure diagram shows `.spec/features/`, pipeline commands simplified, architecture decisions reflect persistent artifacts
- Version bumped to 2.0.0

## [1.15.0] - 2026-04-08

### Changed
- **Review phase self-healing loop** — the agent now autonomously fixes findings using TDD fix plans (exploration test RED → fix → re-test GREEN) and re-reviews in a loop until verdict is `PASS`. The user no longer fixes code — only approves the final clean review.
- Fix Plan Structure added to `templates/review.md`: `critical`/`major` findings get full TDD fix tasks (exploration test → fix → re-test), `minor`/`nit` findings get flat fix tasks. Fix tasks reuse Commands and Test Style Source from the approved implementation plan.
- Iteration Workflow rewritten as self-healing loop with explicit steps: initial review → fix cycle → re-review → repeat → present `PASS` to user
- Review Document Structure now includes `## Fix Plan` section (present only when verdict ≠ `PASS`)
- Quality Control Checklist expanded with fix plan verification items
- Rule 8 (revision limit) now explicitly excludes the review phase's internal fix cycle — the agent iterates without limit until `PASS`
- Quick Start workflow updated: agent reviews and fixes code, then presents final review for approval

## [1.14.0] - 2026-04-08

### Added
- **Review phase (Phase 5)** — new mandatory phase after Implementation. The agent reviews written code against all four prior artifacts (exploration, requirements, design, implementation plan) before the pipeline completes
- `templates/review.md` — phase 5 prompt template with Change Set Discovery, Requirements Traceability Audit, Design Conformance check, Code Quality review, and Security Scan (scoped to changed files)
- **Review base commit tracking** — `pipeline.sh approve` records `review_base_commit` (git HEAD) when approving the implementation phase, enabling `git diff` against the pre-implementation baseline
- `review_base_commit` field in `pipeline.json` — agents can read the base commit for code review diffs
- `rules.review` support in `config.yaml` — phase-specific rules for the review phase
- Verdict system: `PASS` / `NEEDS_CHANGES` / `BLOCK` with severity levels (`critical`, `major`, `minor`, `nit`)
- Iteration workflow: if verdict is not `PASS`, user fixes findings → agent re-reviews → repeat until clean

### Changed
- Pipeline is now 5 phases: Explore → Requirements → Design → Implementation → Review → Done (was 4 phases)
- `pipeline.sh` progress bar updated to show 5 phases: `Expl → Req → Des → Impl → Rev` (shortened labels to fit)
- Phase counter changed from `[N/4]` to `[N/5]` throughout `pipeline.sh`
- `pipeline.sh revisions` now accepts `review` as a valid phase filter
- `pipeline.sh help` workflow updated with review steps (14–16)
- `SKILL.md` description, pipeline diagram, phases table, rules, and quick start updated for 5-phase pipeline
- `README.md` updated: intro, pipeline diagram, phase descriptions, file structure, typical session, architecture decisions
- Version bumped to 1.14.0

## [1.13.0] - 2026-04-05

### Added
- **User language support** — pipeline artifacts (Explore, Requirements, Design, Implementation Plan) are now written in the user's language, auto-detected from their first message
- Rule 10 in `SKILL.md` — defines what stays in English (formal grammar keywords `WHEN`/`SHALL`, requirement IDs `REQ-X.Y`, task IDs `T-N`, instruction keywords `CRITICAL`/`IMPORTANT`/`NOTE`/`DO NOT`/`GOAL`, Correctness Property format, code identifiers, file paths, `.spec/` documentation) and what is written in the user's language (prose, section headers, descriptions, interview questions)
- `## Language` section in `templates/explore.md` — specifies which parts of the exploration document are translated (section headers, prose, scope labels, assumption text) and which are not (code refs, file paths, commands)
- `## Language` section in `templates/requirements.md` — clarifies that `WHEN`/`SHALL`/`the system` remain English while the conditions and outcomes inside requirements sentences are in the user's language; includes a bilingual example
- `## Language` section in `templates/design.md` — prose, ADR narratives, error scenario descriptions translate; code signatures, Mermaid node labels, Correctness Property quantifiers (`For all`, `Validates`) stay English
- `## Language` section in `templates/implementation.md` — task titles and descriptions translate; instruction keywords and all IDs stay English

### Changed
- Project documentation in `<docs_dir>/` (`.spec/`) remains English-only — no change to `templates/docs/` rules

## [1.12.0] - 2026-04-05

### Added
- **Revision Tracking** — `pipeline.sh artifact` now automatically snapshots the previous artifact file before overwriting, preserving full revision history within each phase in `.spec-driven-dev/state/revisions/`
- `pipeline.sh revisions [phase]` command — lists revision snapshots for the current phase, a specific phase, or all phases (`revisions all`)
- **Content-Safe Rollback** — `pipeline.sh approve` snapshots artifact file contents to `.spec-driven-dev/state/approved/`; `pipeline.sh rollback` restores file contents from the snapshot, not just the file path
- **Artifact file existence check at approval** — `pipeline.sh approve` now verifies the registered artifact file still exists before accepting the approval
- **Full archive on reset** — `pipeline.sh reset` now archives artifact file contents, revisions, and approved snapshots alongside the pipeline metadata

### Changed
- `pipeline.sh rollback` now restores artifact file contents automatically — the previous caveat about "rollback restores path, not file contents" no longer applies
- `pipeline.sh help` workflow example now includes `publish` step and `revisions` tip
- Error Recovery section in `SKILL.md` updated to reflect content-safe rollback and revision tracking
- Version bumped to 1.12.0

## [1.11.0] - 2026-04-05

### Added
- **Build Tooling discovery** in `templates/explore.md` — agents must identify the project's command orchestrator and capture concrete test/build/lint/generate commands in the exploration output
- **Verification Commands** section in `templates/requirements.md` — requirements artifacts now record exact runnable verification commands and their source
- **Project Commands** section in `templates/design.md` — design artifacts now carry forward the resolved verification commands for implementation planning
- **Command Discovery** workflow in `templates/implementation.md` — implementation plans now include a Commands block with concrete project commands and source evidence

### Changed
- Implementation planning now uses a command-resolution cascade: design → requirements → exploration → project docs → direct file discovery → ask user
- Implementation tasks must use resolved project commands instead of generic placeholders, and must schedule code generation before build/test when generated-source inputs change
- Explore and requirements quality gates now explicitly require documenting the project's verification commands

### Fixed
- `pipeline.sh version` now reports the current package release version (`1.11.0`) instead of the stale internal value (`1.4.0`)

## [1.10.0] - 2026-04-03

### Added
- **Pre-flight Checklist** — new section in `SKILL.md` with explicit numbered steps agents must follow before starting any pipeline work (status → config → docs-check → init)
- **Stale Doc Regeneration Workflow** — step-by-step instructions in `SKILL.md` for updating stale docs, with file → template owner mapping table (14 rows)
- **File-pattern → Doc mapping table** — `SKILL.md` Documentation Maintenance now uses a structured pattern table (16 rows) for agents to match changed files to affected docs
- `templates/docs/feature-flags.md` — template for generating `FEATURE_FLAGS.md` (flag inventory, lifecycle, rollout strategy, cleanup policy)
- `templates/docs/background-jobs.md` — template for generating `BACKGROUND_JOBS.md` (job inventory, retry/DLQ, concurrency, monitoring, scaling)

### Changed
- **Phase numbering consistency** — `requirements.md` header: `Phase 2: Requirements` (was unnumbered); `design.md` header: `Phase 3: Design` (was Phase 2); `implementation.md` header: `Phase 4: TDD Implementation Plan` (was Phase 3)
- **Documentation Maintenance** rewritten from flat 14-bullet list to two-part approach: pattern table + decision algorithm
- **Quick Start** now references Pre-flight Checklist instead of duplicating inline logic

## [1.9.0] - 2026-04-03

### Changed
- **Template Data Ownership** — single-owner principle: each piece of data lives in exactly one `.spec/` file; duplicates replaced with one-line pointers
- `core.md`: DOMAIN.md §3 Business Errors replaced with pointer to `ERRORS.md`
- `auth.md`: removed §11 API Reference (owned by `api.md` → `API.md`) and §12 Database Schema (owned by `database.md` → `DATABASE.md`); renumbered 14 → 12 sections
- `security.md`: §7 Secrets Management narrowed to audit-only (operational details owned by `deployment.md` → `DEPLOYMENT.md §8`)
- `templates/docs/README.md`: added "Single owner" rule for template authors

## [1.8.0] - 2026-04-03

### Added
- **Freshness Tracking** — `pipeline.sh docs-check` now parses `<!-- generated: YYYY-MM-DD, template: name.md -->` comments in `.spec/` files, computing per-file age and staleness
- `doc_freshness_days` optional field in `config.yaml` — configurable staleness threshold, default: 30 days
- Extended `docs-check` JSON output: files now include `generated`, `template`, `age_days`, `stale` fields; top-level `stale` array lists outdated files
- Freshness metadata rule in `SKILL.md` — agents MUST add `<!-- generated: ... -->` as first line when generating/updating any doc file
- Pre-pipeline stale detection in `SKILL.md` Documentation Context — if stale docs found, agent suggests regeneration before starting
- Freshness metadata rule in `templates/docs/README.md` — added to "Rules for template authors"
- `templates/docs/security.md` — template for generating `SECURITY.md` (security overview, input validation, auth audit, transport security, CORS/CSP, rate limiting, secrets management, data protection, security headers, dependency audit, OWASP Top 10 mapping, incident response)
- Documentation Maintenance mapping in `SKILL.md` for: security changes → `SECURITY.md`

### Changed
- `pipeline.sh docs-check` — complete rewrite of `cmd_docs_check()` with freshness parsing, stale detection, and `doc_freshness_days` config support
- `templates/docs/README.md` manifest: 11 → 12 templates (added `security.md`)
- README: updated file structure tree, templates table (12 rows), config.yaml example (`doc_freshness_days`), config field docs

## [1.7.0] - 2026-04-02

### Added
- `templates/docs/database.md` — template for generating `DATABASE.md` (schema overview, migrations, connection management, query patterns, seed/fixtures)
- `templates/docs/api.md` — template for generating `API.md` (endpoint reference, middleware stack, request/response conventions, error format, versioning)
- `templates/docs/deployment.md` — template for generating `DEPLOYMENT.md` (environments, CI/CD pipeline, rollout strategy, health checks, rollback, secrets)
- `templates/docs/errors.md` — template for generating `ERRORS.md` (error architecture, business error catalog, wrapping conventions, error response format, retry policy)
- Stage column in `templates/docs/README.md` manifest: Bootstrap → Core → Domain-Specific execution order
- Documentation Maintenance mappings in `SKILL.md` for: database changes → `DATABASE.md`, API changes → `API.md`, deployment changes → `DEPLOYMENT.md`, error handling changes → `ERRORS.md`

### Changed
- `templates/docs/core.md`: added Data Flow section (§5) to ARCHITECTURE.md structure; added Error Propagation, Logging Conventions, Concurrency Patterns sections (§9-11) to CODE_STYLE.md structure
- `templates/docs/auth.md`: added Authorization (§5, RBAC/ABAC/scopes), Session Management (§6), Token Lifecycle (§7), Account Operations (§8) sections; renumbered existing §5-10 → §9-14
- `templates/docs/development.md`: added Dev Environment Setup section (§0) to TOOLS.md structure (prerequisites, first-run steps, env file setup)
- `templates/docs/clients.md`: added API Version Management and Shared Code Generation subsections to Shared Code (§2)
- `templates/docs/README.md` manifest: 7 → 11 templates, added Stage column with execution order note
- README: updated file structure tree (4 new template files, 4 new .spec/ output files), updated templates table (11 rows with Stage column)

## [1.6.0] - 2026-04-02

### Added
- **Self-Documenting Mechanic** — pre-pipeline soft gate checks for `.spec/` project documentation; post-pipeline targeted update suggestions based on design §2.3 file changes
- `docs_dir` optional field in `config.yaml` — configurable documentation directory, default: `.spec`
- `rules.docs` optional field in `config.yaml` — rules for documentation generation phase
- `pipeline.sh docs-check` command — returns JSON with documentation directory status and file list
- `templates/docs/` directory — extensible template architecture for documentation generation
- `templates/docs/README.md` — manifest listing all doc templates with conventions for adding new ones
- `templates/docs/bootstrap.md` — template for generating `.spec/README.md` (index) and `.spec/agent-rules.md`
- `templates/docs/agents-index.md` — template for generating `AGENTS.md` (agent entry point)
- `templates/docs/core.md` — template for generating `ARCHITECTURE.md`, `PACKAGES.md`, `DOMAIN.md`, `CODE_STYLE.md`
- `templates/docs/development.md` — template for generating `TOOLS.md`, `TESTING.md`, `FILES.md`
- `templates/docs/auth.md` — template for generating `AUTH.md` / `OAUTH.md` (authentication & authorization)
- `templates/docs/infrastructure.md` — template for generating per-component infra docs (`OBSERVABILITY.md`, `REDIS.md`, `TRAEFIK.md`, etc.)
- `templates/docs/clients.md` — template for generating `CLIENTS.md` and per-client docs (`FRONTEND.md`, `TELEGRAM.md`, etc.)
- Documentation Context section in `SKILL.md` — pre-pipeline check reads `.spec/` as supplementary context
- Documentation Maintenance section in `SKILL.md` — post-pipeline targeted doc update suggestions (auth, infra, clients included)
- explore.md: `.spec/` reading hint in Step 2 — reduces file-read budget when docs exist

### Changed
- Quick Start flow in `SKILL.md` updated with `docs-check` step and post-pipeline doc maintenance
- README: expanded with Self-Documenting Mechanic section, updated File Structure, config.yaml example, Pipeline Commands

### Removed
- `prompts/` directory — content migrated to `templates/docs/` (translated to English)

## [1.5.0] - 2026-03-30

### Added
- **Test Style Cascade** — 3-tier priority system for test style discovery: (1) dedicated test skill, (2) adjacent existing tests, (3) from scratch
- `test_skill` and `test_reference` optional fields in `config.yaml` for explicit test style overrides
- design.md §2.8: `Test Style Source` subsection — agent must document tier selection and evidence before specifying tests
- implementation.md Phase 1: `Test Infrastructure Discovery` step — scans adjacent tests or delegates to test skill before generating test tasks
- implementation.md: `*_Test_Style:_*` optional field for test tasks (Type 1, Type 2)
- explore.md Step 2: testing pattern discovery (framework, file locations, naming conventions)

### Changed
- design.md: Quality Control Checklist and Done When require Test Style Source documentation
- implementation.md: Type 1 (Exploration Test) and Type 2 (Preservation Test) templates require following discovered test style
- implementation.md: Quality Control Checklist and Done When require Test Infrastructure Discovery completion

## [1.4.0] - 2026-03-30

### Added
- `## Done when` gate sections in all 4 phase templates — AI must verify every condition before suggesting approval
- `pipeline.sh publish` command — copies approved artifacts to `.spec-driven-dev/specs/<feature>/` for version control

### Changed
- Rule 1 strengthened: "Always check status first" → "MUST check status first. Never generate phase output without checking status."

### Fixed
- Documented rollback file-content limitation in Error Recovery — rollback restores artifact path, not file contents

## [1.3.0] - 2026-03-29

### Changed
- README: expanded Installation section (install options, manual install, agent targeting, verification)
- **BREAKING**: Migrated to [skills.sh](https://skills.sh) distribution format
- **BREAKING**: Pipeline reduced from 5 to 4 phases — Verify phase removed (implementation is the final phase)
- Skill files moved from `.spec-driven-dev/` to `skills/spec-driven-dev/`
- Entry point changed from `skill.md` to `SKILL.md` with YAML frontmatter
- `pipeline.sh` STATE_DIR now resolved via `git rev-parse --show-toplevel` (project-root-based)
- Template pipeline references use relative paths (`./scripts/pipeline.sh`)
- Version bumped to 1.3.0

### Added
- `skills/spec-driven-dev/SKILL.md` — skills.sh-compatible orchestrator with YAML frontmatter
- Rule 8: revision limit — after 3 rejected revisions, stop and ask for clarification
- Rule 9: surface uncertainty — never silently assume; state assumptions and ask user to confirm
- Exploration budget guidance (~20 file reads) in explore.md
- Assumption surfacing in explore.md: Step 5 requires listing assumptions behind recommendation; output format includes "Assumptions & Open Questions"; quality checklist verifies assumptions are explicit
- `[ASSUMPTION: ...]` tagging in design.md: if skipping clarification questions, mark every design assumption inline
- "Silent assumption" antipattern in design.md
- implementation.md: ambiguous requirements must be escalated to user before task generation
- `.shellcheckrc` — suppresses SC3043 for `local` keyword in POSIX sh
- Nonexistent artifact file rejection test in CI

### Fixed
- `json_escape()` now escapes `\r` (carriage return)
- `cmd_artifact()` validates file existence before registering
- CHANGELOG date typo (2025 → 2026)
- README phase numbering (Phase 2 → Phase 1 for Explore)
- CI integration tests now create artifact files before registering (required after file existence check)

### Removed
- `install.sh` — replaced by `npx skills add sipki-tech/spec-driven-developer-skill`
- `.spec-driven-dev/` root layout — replaced by `skills/spec-driven-dev/`
- `CLAUDE.md`, `.windsurfrules`, `.github/copilot-instructions.md` — IDE adapters no longer needed
- `templates/verify.md` — Verify phase removed from pipeline
- `--update` / `--uninstall` installer flags

## [1.2.0] - 2026-03-26

### Added
- **Explore phase** (phase 1) — investigate the problem space, compare approaches, recommend direction before writing requirements
- **Verify phase** (phase 5) — validate implementation against specs across three dimensions: completeness, correctness, coherence
- `templates/explore.md` — exploration prompt template (Research Partner role)
- `templates/verify.md` — verification prompt template (Quality Auditor role)
- `config.yaml` support — project-level context and per-phase rules via `.spec-driven-dev/config.yaml`

### Changed
- Pipeline expanded from 3 phases to 5: Explore → Requirements → Design → Implementation → Verify
- Phase numbering updated: explore=1, requirements=2, design=3, implementation=4, verify=5
- History indices shifted in templates to accommodate explore phase at position 0
- Version bumped to 1.2.0

### Fixed
- `history[-1].artifact` in design.md → `history[1].artifact` (correct index for requirements)

### Removed
- Kiro and Antigravity IDE adapter support (low adoption)
- IDE auto-detection and adapter generation from install.sh — users now configure their IDE manually (see README)
- `--ide`, `--all-ides` flags from install.sh
- `.cursor/rules/spec-driven-dev.mdc` from repository

## [1.1.0] - 2026-03-19

### Added
- `rollback` command — undo the last phase approval and return to the previous phase
- `version` command — display the current version
- Error recovery section in skill.md — guidance on revising artifacts and undoing approvals
- Coverage matrix format and example in implementation.md template
- Work type classification decision tree in implementation.md template
- Preservation test guidance for pure new features (Type 2 clarification)
- JSON fallback note added to all IDE adapter templates
- `--uninstall` flag in install.sh — removes core files and adapters
- `--all-ides` flag in install.sh — install adapters for all IDEs regardless of detection
- GitHub Actions CI workflow — ShellCheck + integration tests on bash/dash/zsh
- GitHub Actions Release workflow — automatic releases on version tags
- CHANGELOG.md

### Fixed
- **JSON injection**: artifact paths containing quotes no longer corrupt pipeline.json
- **Atomic writes**: pipeline.json uses tmp+mv to prevent corruption on interruption
- **POSIX compliance**: replaced `grep -qE` with `case` patterns for kebab-case validation
- **POSIX compliance**: replaced `ls -A` with `find` for archive directory checks
- **Path traversal**: `artifact` command now rejects paths containing `..`
- **Archive collision**: reset archives now use full ISO timestamp, with counter suffix on collision
- **install.sh fatal errors**: missing core files now cause fatal error instead of warning
- **install.sh double-append**: fixed `grep -q` → `grep -qF` for fixed-string matching
- **install.sh .gitignore**: ensures trailing newline before appending
- **install.sh IDE detection**: adapters only created for IDEs with existing config (use `--all-ides` to override)

### Changed
- Version bumped to 1.1.0
- `install.sh` now uses `die()` for core file copy failures (was `warn()`)
- `REPO_URL` placeholder replaced with actual GitHub URL

## [1.0.0] - 2026-03-01

### Added
- Initial release
- 3-phase pipeline: Requirements → Design → Implementation
- POSIX shell state machine (pipeline.sh)
- Phase templates: requirements.md, design.md, implementation.md
- IDE adapters: Cursor, Windsurf, Claude Code, VSCode Copilot
- Installer script with IDE auto-detection
