# Spec-Driven Dev

A universal skill package for AI coding assistants that enforces a 4-phase development pipeline:

```
Explore → [APPROVE] → Requirements → [APPROVE] → Design → [APPROVE] → Implementation → [APPROVE] → Done
```

No API keys. No dependencies. Works in any IDE with AI agent support.

## Why

AI coding assistants are great at writing code, but they often skip the thinking phase. They jump straight to implementation without understanding what needs to be built, why, or what the constraints are.

Spec-Driven Dev forces a structured workflow:
1. **Explore** — investigate the problem space, compare approaches
2. **Requirements** — interview the user, capture WHAT needs to be done
3. **Design** — architect HOW to do it, define correctness properties
4. **Implementation** — create a TDD plan with traceability to requirements

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

Customize AI behavior for your project by creating `.spec-driven-dev/config.yaml`:

```yaml
# .spec-driven-dev/config.yaml

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
  implementation:
    - Test command: go test ./...
    - Build command: make build

# Optional: test style cascade overrides
test_skill: my-test-skill        # Tier 1: delegate test generation to this skill
test_reference: "**/*_test.go"   # Tier 2: use these files as test style reference
```

- **`context`** is injected into ALL phases — the agent knows your stack before asking questions.
- **`rules.<phase>`** adds phase-specific rules on top of the template defaults.
- **`test_skill`** (optional) — name of an installed skill for test generation. When set, Design and Implementation phases delegate test specification to this skill instead of writing test tasks directly.
- **`test_reference`** (optional) — glob or file paths pointing to representative test files. When set, the agent uses these as the style reference for all generated tests. When omitted, the agent auto-discovers adjacent tests.

### File Structure

```
skills/spec-driven-dev/              ← skill package (installed by skills.sh)
├── SKILL.md                         ← orchestrator (skills.sh entry point)
├── templates/
│   ├── explore.md                   ← phase 1 prompt
│   ├── requirements.md              ← phase 2 prompt
│   ├── design.md                    ← phase 3 prompt
│   ├── implementation.md            ← phase 4 prompt

└── scripts/
    └── pipeline.sh                  ← state machine (POSIX sh, zero deps)

.spec-driven-dev/                    ← project-local runtime (gitignored)
├── config.yaml                      ← project context & rules (opt-in)
└── state/
    ├── pipeline.json                ← current state for agents
    ├── pipeline.kv                  ← internal KV store
    └── archive/                     ← archived pipelines
```

### Pipeline Commands

```bash
P="skills/spec-driven-dev/scripts/pipeline.sh"

sh $P help            # Show usage
sh $P init my-feature # Start a new pipeline
sh $P status          # Show current phase, artifacts, progress
sh $P artifact <path> # Register output artifact for current phase
sh $P approve         # Advance to next phase (after user approval)
sh $P rollback        # Return to previous phase
sh $P history         # Show completed phases and archives
sh $P reset           # Archive current pipeline and reset
sh $P version         # Show version
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

Agent: [→ design → implementation, same pattern]
Agent: "Pipeline complete!"
```

## Phase Details

### Phase 1: Explore

The agent investigates the problem space before committing to requirements:
- Reads existing codebase to understand current state
- Identifies constraints, risks, and dependencies
- Compares 2–4 realistic approaches with trade-offs
- Recommends a direction with suggested scope boundaries

Output: exploration document with Intent, Investigation, Options, Constraints, and Recommended Direction.

### Phase 2: Requirements

The agent conducts a structured interview through 4 layers:
1. **Context & Motivation** — what, why, who's affected
2. **Scope Boundaries** — what changes, what must NOT change
3. **Constraints & Edge Cases** — errors, defaults, conflicts
4. **Verification** — how to prove it works

Output: formal requirements document using **WHEN/SHALL grammar** — each requirement is atomic and verifiable.

### Phase 3: Design

Takes the requirements document and produces:
- **Architecture** with Mermaid diagrams (color-coded: new/modified/existing)
- **Components & Interfaces** — affected files + files NOT requiring changes
- **Key Decisions (ADR)** — choices between alternatives with rationale
- **Correctness Properties** — formal "For all X, Y must hold" statements
- **Testing Strategy** — unit tests + property-based tests

### Phase 4: Implementation

Takes both documents and produces a **TDD implementation plan**:
- Exploration tests (RED) — prove the problem exists
- Preservation tests (GREEN) — lock in correct behavior
- Implementation tasks — atomic, one file per subtask
- Re-tests — confirm fix, no regressions
- Checkpoints — integration verification

Every task is traceable: `Requirements X.Y → Task N → Correctness Property K`.

## Architecture Decisions

1. **POSIX sh over Python** — guaranteed to be available everywhere, even in minimal containers
2. **KV file + JSON mirror** — KV for simple shell manipulation, JSON for agents to parse
3. **skills.sh distribution** — standard skill packaging, no custom installer needed
4. **No auto-approve** — human in the loop is the whole point
5. **Artifacts in .spec-driven-dev/state/** — gitignored, not polluting the repo
6. **Archive on reset** — never lose completed pipeline data

## Requirements

- POSIX-compatible shell (`sh`, `bash`, `zsh`, `dash`)
- `git`, `date`, `grep`, `sed`, `mkdir` — standard Unix utilities
- No Python, Node.js, or other runtime required

## License

MIT
