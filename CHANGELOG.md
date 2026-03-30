# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

## [1.2.0] - 2026-07-26

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
