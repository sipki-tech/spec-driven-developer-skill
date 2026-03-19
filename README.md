# Spec-Driven Dev

A universal skill package for AI coding assistants that enforces a 3-phase development pipeline:

```
Requirements → [APPROVE] → Design → [APPROVE] → Implementation
```

No API keys. No dependencies. Works in any IDE with AI agent support.

## Why

AI coding assistants are great at writing code, but they often skip the thinking phase. They jump straight to implementation without understanding what needs to be built, why, or what the constraints are.

Spec-Driven Dev forces a structured workflow:
1. **Requirements** — interview the user, capture WHAT needs to be done
2. **Design** — architect HOW to do it, define correctness properties
3. **Implementation** — create a TDD plan with traceability to requirements

Each phase produces a document. Each transition requires explicit human approval. No skipping.

## Quick Start

```bash
# One-liner (downloads from GitHub, no clone needed)
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/sipki-tech/spec-driven-developer-skill/main/install.sh | sh
```

Or if you prefer to inspect the script first:

```bash
# Clone and install
git clone https://github.com/sipki-tech/spec-driven-developer-skill.git /tmp/sdd
cd /path/to/your/project
sh /tmp/sdd/install.sh
```

The installer:
1. Copies `.spec-driven-dev/` (core) into your project (downloads from GitHub if no local source)
2. Detects which IDEs you use and creates adapters (only for IDEs with existing config)
3. Adds `state/` to `.gitignore`

Flags:
- `--update` — refresh core files, preserve state/ and existing adapters
- `--uninstall` — remove core files and adapters
- `--all-ides` — install adapters for all supported IDEs regardless of detection

Then tell your AI assistant:

> "I want to add user authentication with OAuth2"

The agent will automatically pick up the pipeline and start with the requirements interview.

## Supported IDEs

| IDE | Adapter File | Shell | Status |
|-----|-------------|-------|--------|
| **Cursor** | `.cursor/rules/spec-driven-dev.mdc` | ✅ | Full support |
| **Windsurf** | `.windsurfrules` | ✅ | Full support |
| **Claude Code** | `CLAUDE.md` | ✅ | Full support |
| **Kiro** | `.kiro/specs/spec-driven-dev.md` | ✅ | Native specs support |
| **Antigravity** | `.antigravity/agents.yaml` | ✅ | Native agents |
| **VSCode Copilot** | `.github/copilot-instructions.md` | ⚠️ | Limited (no shell) |

> VSCode Copilot can read the instructions but may not execute shell commands. The agent can read `state/pipeline.json` directly as a fallback.

## How It Works

### File Structure

```
.spec-driven-dev/                    ← shared core (IDE-agnostic)
├── skill.md                         ← orchestrator (~60 lines)
├── templates/
│   ├── requirements.md              ← phase 1 prompt
│   ├── design.md                    ← phase 2 prompt
│   └── implementation.md            ← phase 3 prompt
├── scripts/
│   └── pipeline.sh                  ← state machine (POSIX sh, zero deps)
└── state/                           ← runtime (gitignored)
    ├── pipeline.json                ← current state for agents
    ├── pipeline.kv                  ← internal KV store
    └── archive/                     ← archived pipelines

# IDE adapters (thin pointers to the core)
.cursor/rules/spec-driven-dev.mdc
.windsurfrules
CLAUDE.md
.github/copilot-instructions.md
.kiro/specs/spec-driven-dev.md
.antigravity/agents.yaml
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
Agent: [reads templates/requirements.md → starts interview]
Agent: "Let me understand the requirements. First, some questions:
        1. Which service is this for?
        2. What's the current communication pattern?
        3. Who are the consumers of this API?"

You: [answers questions]

Agent: [generates requirements document with WHEN/SHALL grammar]
Agent: "Requirements document is ready. Approve?"

You: "Approve"

Agent: [runs pipeline.sh approve → advances to design]
Agent: [reads templates/design.md + requirements artifact]
Agent: [generates design document with architecture, correctness properties]
Agent: "Design document is ready. Approve?"

You: "Approve"

Agent: [runs pipeline.sh approve → advances to implementation]
Agent: [reads templates/implementation.md + both artifacts]
Agent: [generates TDD implementation plan]
Agent: "Implementation plan is ready. Approve?"

You: "Approve"

Agent: [runs pipeline.sh approve → done]
       "Pipeline complete! Artifacts:
        1. state/grpc-streaming-requirements.md
        2. state/grpc-streaming-design.md
        3. state/grpc-streaming-implementation.md"
```

## Phase Details

### Phase 1: Requirements

The agent conducts a structured interview through 4 layers:
1. **Context & Motivation** — what, why, who's affected
2. **Scope Boundaries** — what changes, what must NOT change
3. **Constraints & Edge Cases** — errors, defaults, conflicts
4. **Verification** — how to prove it works

Output: formal requirements document using **WHEN/SHALL grammar** — each requirement is atomic and verifiable.

### Phase 2: Design

Takes the requirements document and produces:
- **Architecture** with Mermaid diagrams (color-coded: new/modified/existing)
- **Components & Interfaces** — affected files + files NOT requiring changes
- **Key Decisions (ADR)** — choices between alternatives with rationale
- **Correctness Properties** — formal "For all X, Y must hold" statements
- **Testing Strategy** — unit tests + property-based tests

### Phase 3: Implementation

Takes both documents and produces a **TDD implementation plan**:
- Exploration tests (RED) — prove the problem exists
- Preservation tests (GREEN) — lock in correct behavior
- Implementation tasks — atomic, one file per subtask
- Re-tests — confirm fix, no regressions
- Checkpoints — integration verification

Every task is traceable: `Requirements X.Y → Task N → Correctness Property K`.

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
