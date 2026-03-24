# Spec-Driven Dev

A universal skill package for AI coding assistants that enforces a 5-phase development pipeline:

```
Explore → [APPROVE] → Requirements → [APPROVE] → Design → [APPROVE] → Implementation → [APPROVE] → Verify → Done
```

No API keys. No dependencies. Works in any IDE with AI agent support.

## Why

AI coding assistants are great at writing code, but they often skip the thinking phase. They jump straight to implementation without understanding what needs to be built, why, or what the constraints are.

Spec-Driven Dev forces a structured workflow:
1. **Explore** — investigate the problem space, compare approaches
2. **Requirements** — interview the user, capture WHAT needs to be done
3. **Design** — architect HOW to do it, define correctness properties
4. **Implementation** — create a TDD plan with traceability to requirements
5. **Verify** — validate that implementation matches specs

Each phase produces a document. Each transition requires explicit human approval. No skipping.

## Quick Start

Install into your project with a single command:

```bash
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/sipki-tech/spec-driven-developer-skill/main/install.sh | sh
```

<details>
<summary>Alternative: clone and install</summary>

```bash
git clone https://github.com/sipki-tech/spec-driven-developer-skill.git /tmp/sdd
cd /path/to/your/project
sh /tmp/sdd/install.sh
```
</details>

### Installer flags

| Flag | Description |
|------|-------------|
| `--update` | Refresh core files, preserve state/ |
| `--uninstall` | Remove core files |

### IDE Setup

After installing, point your AI assistant at the skill. Add these lines to your IDE’s instruction file:

```
Read and follow `.spec-driven-dev/skill.md` for all feature development.
Before starting any feature, run: `sh .spec-driven-dev/scripts/pipeline.sh status`
```

| IDE | Where to add |
|-----|-------------|
| **Cursor** | `.cursor/rules/spec-driven-dev.mdc` (with YAML frontmatter) |
| **Windsurf** | `.windsurfrules` |
| **Claude Code** | `CLAUDE.md` |
| **VSCode Copilot** | `.github/copilot-instructions.md` |

Then tell your AI assistant:

> "I want to add user authentication with OAuth2"

The agent will automatically pick up the pipeline and start with the exploration phase.

## How It Works

### Project Configuration

Customize AI behavior for your project by editing `.spec-driven-dev/config.yaml`:

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
  verify:
    - Check that all gRPC error codes are tested
```

- **`context`** is injected into ALL phases — the agent knows your stack before asking questions.
- **`rules.<phase>`** adds phase-specific rules on top of the template defaults.
- The file is created as a commented-out starter on install. Fully opt-in.

### File Structure

```
.spec-driven-dev/                    ← shared core (IDE-agnostic)
├── config.yaml                      ← project context & rules (opt-in)
├── skill.md                         ← orchestrator
├── templates/
│   ├── explore.md                   ← phase 1 prompt
│   ├── requirements.md              ← phase 2 prompt
│   ├── design.md                    ← phase 3 prompt
│   ├── implementation.md            ← phase 4 prompt
│   └── verify.md                    ← phase 5 prompt
├── scripts/
│   └── pipeline.sh                  ← state machine (POSIX sh, zero deps)
└── state/                           ← runtime (gitignored)
    ├── pipeline.json                ← current state for agents
    ├── pipeline.kv                  ← internal KV store
    └── archive/                     ← archived pipelines
```

### Pipeline Commands

```bash
sh .spec-driven-dev/scripts/pipeline.sh help

# Start a new feature
sh .spec-driven-dev/scripts/pipeline.sh init my-feature

# Check current state
sh .spec-driven-dev/scripts/pipeline.sh status

# Register artifact for current phase
sh .spec-driven-dev/scripts/pipeline.sh artifact state/my-feature-requirements.md

# Advance to next phase (after user approval)
sh .spec-driven-dev/scripts/pipeline.sh approve

# Return to previous phase (undo an approval)
sh .spec-driven-dev/scripts/pipeline.sh rollback

# View completed phases and archives
sh .spec-driven-dev/scripts/pipeline.sh history

# Archive and reset
sh .spec-driven-dev/scripts/pipeline.sh reset

# Show version
sh .spec-driven-dev/scripts/pipeline.sh version
```

### Typical Session

```
You: "I want to add gRPC streaming to my service"

Agent: [reads skill.md → runs pipeline.sh init grpc-streaming]
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

Agent: [runs pipeline.sh approve → advances to design]
Agent: [reads templates/design.md + prior artifacts]
Agent: [generates design document with architecture, correctness properties]
Agent: "Design document is ready. Approve?"

You: "Approve"

Agent: [runs pipeline.sh approve → advances to implementation]
Agent: [reads templates/implementation.md + all prior artifacts]
Agent: [generates TDD implementation plan]
Agent: "Implementation plan is ready. Approve?"

You: "Approve"

Agent: [runs pipeline.sh approve → advances to verify]
Agent: [reads templates/verify.md + all 4 artifacts + actual code]
Agent: "Verification Report:
        ✓ REQ-1: streaming endpoint — implemented in service.go
        ✓ REQ-2: backpressure handling — implemented in stream.go
        ⚠ REQ-3: reconnection — partially implemented, missing retry logic
        Coverage: 2/3 fully implemented. Recommendation: fix REQ-3 before approval."

You: "Approve" (or rollback to fix issues)

Agent: [runs pipeline.sh approve → done]
       "Pipeline complete!"
```

## Phase Details

### Phase 2: Explore

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

### Phase 5: Verify

Reads all prior artifacts and the actual codebase, then validates three dimensions:
- **Completeness** — every requirement has corresponding code and tests
- **Correctness** — implementation matches design intent, edge cases handled
- **Coherence** — code structure reflects design decisions, naming is consistent

Output: verification report presented in chat (no saved file). Issues are marked ✓/⚠/✗.

## Updating

```bash
# From local clone
sh install.sh --update

# Or remote (re-downloads latest from GitHub)
curl -fsSL https://raw.githubusercontent.com/sipki-tech/spec-driven-developer-skill/main/install.sh | sh -s -- --update
```

This refreshes core files (skill.md, templates, pipeline.sh) while preserving:
- `state/` — your active pipeline and archives
- Existing IDE adapters — won't overwrite customized adapters

## Uninstalling

```bash
sh install.sh --uninstall
```

Removes `.spec-driven-dev/` directory and IDE adapter files. Archives can optionally be preserved.

## Customization

### Modify Templates

Edit files in `.spec-driven-dev/templates/` to adapt prompts for your team's conventions. The core structure (interview → document → quality control → antipatterns) is designed to be extended.

### Add IDE Support

Create a new adapter file that points to `.spec-driven-dev/skill.md`. The adapter is typically 2-5 lines. See existing adapters for the pattern.

### Language/Framework Specific

The templates are language-agnostic by default. To add language-specific guidance:
1. Add context to the requirements interview (Layer 3: Constraints)
2. Add framework-specific patterns to the design template
3. Add test framework conventions to the implementation template

## Architecture Decisions

1. **POSIX sh over Python** — guaranteed to be available everywhere, even in minimal containers
2. **KV file + JSON mirror** — KV for simple shell manipulation, JSON for agents to parse
3. **One core + thin adapters** — update prompts once, works in all IDEs
4. **No auto-approve** — human in the loop is the whole point
5. **Artifacts in state/** — gitignored, not polluting the repo
6. **Archive on reset** — never lose completed pipeline data

## Requirements

- POSIX-compatible shell (`sh`, `bash`, `zsh`, `dash`)
- `date`, `grep`, `sed`, `mkdir` — standard Unix utilities
- No Python, Node.js, or other runtime required

## License

MIT
