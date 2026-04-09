# Spec-Driven Dev

A universal skill package for AI coding assistants that enforces a 6-phase development pipeline:

```
Explore → [APPROVE] → Requirements → [APPROVE] → Design → [APPROVE] → Task Plan → [APPROVE] → Implementation → [APPROVE] → Review → [APPROVE] → Done
```

No API keys. No dependencies. Works in any IDE with AI agent support.

Designed for a **single project or monorepo**. Not intended for features spanning multiple independent repositories.

## Why

AI coding assistants are great at writing code, but they often skip the thinking phase. They jump straight to implementation without understanding what needs to be built, why, or what the constraints are.

Spec-Driven Dev forces a structured workflow:
1. **Explore** — investigate the problem space, compare 2–4 approaches, recommend direction. Output: exploration document with options, risks, and scope boundaries.
2. **Requirements** — structured 4-layer interview (context → scope → constraints → verification), then generate formal requirements. Output: requirements document with WHEN/SHALL grammar.
3. **Design** — architect the solution with Mermaid diagrams, ADRs, correctness properties, and testing strategy. Output: design document with traceability to requirements.
4. **Task Plan** — decompose design into TDD tasks (RED/GREEN/CODE/VERIFY/GATE) with coverage matrix. Output: implementation plan with full requirements traceability (no code yet).
5. **Implementation** — execute the task plan: write tests, write code, run suite after each task. Output: implementation report with task completion checklist.
6. **Review** — review written code: change set, requirements traceability, design conformance, code quality, security scan. Output: review document with PASS/NEEDS_CHANGES/BLOCK verdict.

Each phase produces a document. Each transition requires explicit human approval. No skipping.

## Installation

Install via [skills.sh](https://skills.sh):

```bash
npx skills add sipki-tech/spec-driven-developer-skill
```

The CLI auto-detects your installed agents (GitHub Copilot, Claude Code, Cursor, Codex, Windsurf, Cline, and [40+ others](https://skills.sh)) and symlinks the skill into their config directories.

### Install Options

```bash
# Install globally (available across all projects)
npx skills add sipki-tech/spec-driven-developer-skill -g

# Install to a specific agent
npx skills add sipki-tech/spec-driven-developer-skill -a github-copilot
npx skills add sipki-tech/spec-driven-developer-skill -a claude-code
npx skills add sipki-tech/spec-driven-developer-skill -a cursor

# CI-friendly (no prompts)
npx skills add sipki-tech/spec-driven-developer-skill --all -y

# Full GitHub URL also works
npx skills add https://github.com/sipki-tech/spec-driven-developer-skill
```

### Manual Installation

If you prefer not to use `npx`, clone the repo directly into your project:

```bash
git clone https://github.com/sipki-tech/spec-driven-developer-skill.git /tmp/sdd
cp -r /tmp/sdd/skills/spec-driven-dev skills/spec-driven-dev
rm -rf /tmp/sdd
```

### Verify

```bash
npx skills list
```

## Quick Start

Tell your AI assistant:

> "I want to add user authentication with OAuth2"

The agent will automatically pick up the pipeline and start with the exploration phase.

## How It Works

### Project Configuration

Customize AI behavior for your project by creating `.spec/config.yaml`:

```yaml
# .spec/config.yaml

context: |
  Tech stack: Go 1.23, PostgreSQL, gRPC
  Testing: go test, testify
  Build: make build
  Lint: golangci-lint run
  Repo structure: cmd/, internal/, pkg/, api/

rules:
  explore:
    - Focus on existing API surface before proposing new endpoints
  requirements:
    - All REQ should use gRPC error codes, not HTTP statuses
  design:
    - ADR must consider protobuf backward compatibility
  task-plan:
    - Test command: go test ./...
    - Build command: make build
  implementation:
    - Run tests after each task before marking it done
  review:
    - Always check protobuf backward compatibility
  docs:
    - Always include Mermaid diagrams in ARCHITECTURE.md
    - Skip FILES.md — no file storage in this project

# Optional: test style cascade overrides
test_skill: my-test-skill        # Tier 1: delegate test generation to this skill
test_reference: "**/*_test.go"   # Tier 2: use these files as test style reference

# Optional: project documentation directory
docs_dir: .spec                  # Default. Change to customize (e.g., .docs, docs/)
doc_freshness_days: 30           # Days before a generated doc is considered stale (default: 30)
```

- **`context`** is injected into ALL phases — the agent knows your stack before asking questions.
- **`rules.<phase>`** adds phase-specific rules on top of the template defaults.
- **`test_skill`** (optional) — name of an installed skill for test generation. When set, Design and Implementation phases delegate test specification to this skill instead of writing test tasks directly.
- **`test_reference`** (optional) — glob or file paths pointing to representative test files. When set, the agent uses these as the style reference for all generated tests. When omitted, the agent auto-discovers adjacent tests.
- **`docs_dir`** (optional) — directory for project documentation, default: `.spec`. The agent reads and writes project docs here.
- **`doc_freshness_days`** (optional) — number of days after which a generated doc is considered stale, default: `30`. Used by `docs-check` to flag outdated files.
- **`rules.docs`** (optional) — rules for documentation generation (e.g., skip irrelevant docs, require diagrams).

Phase-specific rule keys: `rules.explore`, `rules.requirements`, `rules.design`, `rules.task-plan`, `rules.implementation`, `rules.review`, `rules.docs`.

### File Structure

```
skills/spec-driven-dev/              ← skill package (installed by skills.sh)
├── SKILL.md                         ← orchestrator (skills.sh entry point)
├── templates/
│   ├── explore.md                   ← phase 1 prompt
│   ├── requirements.md              ← phase 2 prompt
│   ├── design.md                    ← phase 3 prompt
│   ├── task-plan.md                 ← phase 4 prompt
│   ├── implementation.md            ← phase 5 prompt
│   ├── review.md                    ← phase 6 prompt
│   └── docs/                        ← documentation generation templates
│       ├── README.md                ← manifest (lists all doc templates)
│       ├── bootstrap.md             ← generates README.md, agent-rules.md
│       ├── agents-index.md          ← generates AGENTS.md
│       ├── core.md                  ← generates ARCHITECTURE, PACKAGES, DOMAIN, CODE_STYLE
│       ├── development.md           ← generates TOOLS, TESTING, FILES
│       ├── errors.md                ← generates ERRORS.md
│       ├── auth.md                  ← generates AUTH.md / OAUTH.md
│       ├── database.md              ← generates DATABASE.md
│       ├── api.md                   ← generates API.md
│       ├── deployment.md            ← generates DEPLOYMENT.md
│       ├── infrastructure.md        ← generates per-component infra docs
│       ├── clients.md               ← generates CLIENTS.md + per-client docs
│       ├── security.md              ← generates SECURITY.md
│       ├── feature-flags.md         ← generates FEATURE_FLAGS.md
│       └── background-jobs.md       ← generates BACKGROUND_JOBS.md
└── scripts/
    └── pipeline.sh                  ← state machine (POSIX sh, zero deps)

.spec/                               ← project-local (committed to git)
├── config.yaml                      ← project context & rules (opt-in)
├── features/                        ← per-feature pipeline artifacts
│   ├── grpc-streaming/              ← example completed feature
│   │   ├── pipeline.json            ← pipeline state (for agents)
│   │   ├── pipeline.kv              ← internal KV store
│   │   ├── explore.md               ← phase 1 artifact
│   │   ├── requirements.md          ← phase 2 artifact
│   │   ├── design.md                ← phase 3 artifact
│   │   ├── task-plan.md             ← phase 4 artifact
│   │   ├── implementation.md        ← phase 5 artifact
│   │   ├── review.md                ← phase 6 artifact
│   │   ├── revisions/               ← artifact revision history
│   │   └── approved/                ← approved snapshots
│   └── oauth-login/                 ← another feature (in progress or done)
│       └── ...
├── README.md                        ← documentation index
├── ARCHITECTURE.md                  ← architecture overview
├── PACKAGES.md                      ← package reference
├── DOMAIN.md                        ← domain model
├── CODE_STYLE.md                    ← code conventions
├── ERRORS.md                        ← error handling & error catalog
├── TOOLS.md                         ← commands & tooling
├── TESTING.md                       ← testing conventions
├── DATABASE.md                      ← database schema & migrations
├── API.md                           ← API endpoints & conventions
├── DEPLOYMENT.md                    ← deployment pipeline & environments
├── SECURITY.md                      ← security audit & OWASP mapping
└── ...                              ← domain-specific docs (AUTH, CLIENTS, etc.)
```

### Pipeline Commands

```bash
P="skills/spec-driven-dev/scripts/pipeline.sh"

sh $P help                        # Show usage
sh $P init my-feature             # Start a new pipeline
sh $P status                      # Show current phase, artifacts, progress
sh $P artifact [path]             # Register output artifact for current phase
sh $P approve                     # Advance to next phase (after user approval)
sh $P history                     # Show all features and their status
sh $P revisions [ph]              # Show revision history (current or specified phase)
sh $P docs-check                  # Check project documentation status (JSON)
sh $P version                     # Show version

# When multiple pipelines are active simultaneously:
sh $P --feature auth-flow status  # Operate on a specific feature
sh $P --feature payment approve
```

### Typical Session

```
You: "I want to add gRPC streaming to my service"

Agent: [reads SKILL.md → runs pipeline.sh init grpc-streaming]
Agent: [reads templates/explore.md → investigates codebase]
Agent: "Let me explore the problem space first. I see you currently use
        unary gRPC calls in service X. Here are 3 approaches:
        1. Server streaming  2. Bidirectional  3. SSE fallback
        I recommend #1 because..."
Agent: "Exploration document ready. Approve?"

You: "Approve"

Agent: [runs pipeline.sh approve → advances to requirements]
Agent: [reads templates/requirements.md → starts interview]
Agent: "Now let me capture the formal requirements.
        1. Which service is this for?
        2. What's the current communication pattern?
        3. Who are the consumers of this API?"

You: [answers questions]

Agent: [generates requirements document with WHEN/SHALL grammar]
Agent: "Requirements document is ready. Approve?"

You: "Approve"

Agent: [→ design → task plan, same pattern]
Agent: "Task plan approved. Now I'll implement the code."

Agent: [reads templates/implementation.md → executes the TDD plan]
Agent: [writes tests, writes code, marks tasks done with [x]]

Agent: "All tasks completed. Implementation report ready. Approve?"

You: "Approve"

Agent: [→ review phase]
Agent: "Let me review the code against requirements and design.
        I found 2 issues: missing test for REQ-1.2, naming inconsistency.
        Fixing..."

Agent: [self-healing loop: fix → re-review → fix → ... until PASS]
Agent: "All findings resolved. Verdict: PASS. Approve?"

You: "Approve"

Agent: "Pipeline complete!"
Agent: "This feature added new packages. Update .spec/PACKAGES.md?"

You: "Update docs"

Agent: [regenerates affected documentation]
```

## Phase Details

### Phase 1: Explore

The agent investigates the problem space before committing to requirements:
- Reads existing codebase to understand current state
- Identifies constraints, risks, and dependencies
- Compares 2–4 realistic approaches with trade-offs
- Recommends a direction with suggested scope boundaries

Output: exploration document with Intent, Investigation, Build Tooling, Options Considered, Constraints & Risks, Recommended Direction, Scope Boundaries, and Assumptions & Open Questions.

### Phase 2: Requirements

The agent conducts a structured interview through 4 layers:
1. **Context & Motivation** — what, why, who's affected
2. **Scope Boundaries** — what changes, what must NOT change
3. **Constraints & Edge Cases** — errors, defaults, conflicts
4. **Verification** — how to prove it works

Output: formal requirements document with overview, glossary, requirements using **WHEN/SHALL grammar**, verification commands, and open design questions.

### Phase 3: Design

Takes the requirements document and produces:
- **Architecture** with Mermaid diagrams (color-coded: new/modified/existing)
- **Components & Interfaces** — affected files + files NOT requiring changes
- **Key Decisions (ADR)** — choices between alternatives with rationale
- **Correctness Properties** — formal "For all X, Y must hold" statements
- **Testing Strategy** — test style source, project commands, unit and property-based test specifications

### Phase 4: Task Plan

Takes both documents and produces a **TDD implementation plan**:
- Exploration tests (RED) — prove the problem exists
- Preservation tests (GREEN) — lock in correct behavior
- Implementation tasks — atomic, one file per subtask
- Re-tests — confirm fix, no regressions
- Checkpoints — integration verification

Every task is traceable: `Requirements X.Y → Task N → Correctness Property K`.

### Phase 5: Implementation

The agent executes the approved task plan:
- Writes real tests and real production code for **every** task
- Runs the test suite after each task; iterates until green
- Marks each completed task with `[x]` in the implementation report
- Does NOT create new tasks or modify the plan — only executes
- Final verification: all tests pass, build succeeds, lint is clean

Output: implementation report with task checklist showing what was done.

### Phase 6: Review

After the agent implements the TDD plan, it reviews the **written code**:
- **Change Set Discovery** — git diff from the base commit, cross-reference with the plan
- **Requirements Traceability** — every requirement mapped to test and code
- **Design Conformance** — architectural boundaries, data models, API contracts, correctness properties
- **Code Quality** — naming, dead code, scope creep, test quality
- **Security Scan** — input validation, auth, injection, secrets (scoped to changed files)

Verdict: `PASS` (no critical/major findings), `NEEDS_CHANGES` (major findings), or `BLOCK` (critical findings).
If not `PASS`, the agent enters a self-healing loop: creates a TDD fix plan, fixes the code, and re-reviews until clean (up to 3 fix cycles; escalates to user if unresolved).

## Self-Documenting Mechanic

The skill includes a self-documenting mechanic that keeps project documentation (`.spec/`) in sync with code changes.

### How it works

**Before the pipeline** (soft gate):
- When starting a new feature, the agent checks if `.spec/` exists
- If missing, it suggests generating documentation first: *"Project docs not found. Say 'generate docs' or 'skip'."*
- If present, it reads the docs as context for all phases, reducing codebase scan time
- This is a suggestion, not a blocker — the pipeline works without `.spec/`

**After the pipeline** (targeted update):
- When the feature pipeline completes, the agent analyzes which files were changed
- It suggests updating only the affected documentation (e.g., new package → update `PACKAGES.md`)
- You can accept or skip the update

### Documentation templates

Templates for generating docs live in `skills/spec-driven-dev/templates/docs/`. Each template generates specific doc files:

| Template | Stage | Generates |
|----------|-------|----------|
| `bootstrap.md` | Bootstrap | `README.md`, `agent-rules.md` — project index and agent rules |
| `agents-index.md` | Bootstrap | `AGENTS.md` — entry point for agents |
| `core.md` | Core | `ARCHITECTURE.md`, `PACKAGES.md`, `DOMAIN.md`, `CODE_STYLE.md` |
| `development.md` | Core | `TOOLS.md`, `TESTING.md`, `FILES.md` |
| `errors.md` | Core | `ERRORS.md` — error architecture & business error catalog |
| `auth.md` | Domain | `AUTH.md` / `OAUTH.md` — authentication & authorization |
| `database.md` | Domain | `DATABASE.md` — schema, migrations, query patterns |
| `api.md` | Domain | `API.md` — endpoint reference, middleware, error format |
| `deployment.md` | Domain | `DEPLOYMENT.md` — environments, CI/CD, rollout, health checks |
| `infrastructure.md` | Domain | Per-component infra docs (`OBSERVABILITY.md`, `REDIS.md`, etc.) |
| `clients.md` | Domain | `CLIENTS.md` + per-client docs (`FRONTEND.md`, `TELEGRAM.md`, etc.) |
| `security.md` | Domain | `SECURITY.md` — security audit, OWASP mapping, secrets management |
| `feature-flags.md` | Domain | `FEATURE_FLAGS.md` — flag inventory, lifecycle, rollout, cleanup |
| `background-jobs.md` | Domain | `BACKGROUND_JOBS.md` — job inventory, retry/DLQ, concurrency, scaling |

To add a new documentation type, create a template file in `templates/docs/` and add it to the manifest (`templates/docs/README.md`).

## Architecture Decisions

1. **POSIX sh over Python** — guaranteed to be available everywhere, even in minimal containers
2. **KV file + JSON mirror** — KV for simple shell manipulation, JSON for agents to parse
3. **skills.sh distribution** — standard skill packaging, no custom installer needed
4. **No auto-approve** — human in the loop is the whole point
5. **Persistent artifacts in `.spec/features/`** — committed to git, creating a permanent record of decisions
6. **Per-feature directories** — each feature gets its own directory with all artifacts, revisions, and state
7. **Code review as a phase** — code is verified against specs before the pipeline completes
8. **Self-healing review loop** — agent fixes code issues automatically using TDD fix plans (max 3 fix cycles, then escalates to user)
9. **Task Plan / Implementation split** — planning (Phase 4) and execution (Phase 5) are separate phases with separate approval gates, ensuring the plan is reviewed before any code is written

## Requirements

- POSIX-compatible shell (`sh`, `bash`, `zsh`, `dash`)
- `git`, `date`, `grep`, `sed`, `mkdir` — standard Unix utilities
- No Python, Node.js, or other runtime required

## License

MIT
