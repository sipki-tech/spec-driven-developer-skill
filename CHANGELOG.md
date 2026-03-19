# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- IDE adapters: Cursor, Windsurf, Claude Code, VSCode Copilot, Kiro, Antigravity
- Installer script with IDE auto-detection
