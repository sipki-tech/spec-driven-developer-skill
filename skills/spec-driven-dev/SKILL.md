---
name: spec-driven-dev
description: >
  Spec-driven development pipeline with 4 phases: Explore, Requirements,
  Design, Implementation Plan. Enforces human approval gates between
  phases. Use when user wants structured feature development, spec-first
  approach, or says "I want to add feature X", "new feature", "implement",
  "build". Keywords: spec, requirements, design document, TDD plan, pipeline,
  approval gates, WHEN/SHALL, implementation plan.
---

# Spec-Driven Development

You are operating in **spec-driven development mode**.
This project uses a 4-phase pipeline with human approval gates between each phase.

## Pipeline

```
Explore → [APPROVE] → Requirements → [APPROVE] → Design → [APPROVE] → Implementation → [APPROVE] → Done
```

Each phase has a dedicated prompt template. Read the template for the **current** phase before generating any output.

## Phases

| # | Phase          | Template                      | Produces                        |
|---|----------------|-------------------------------|---------------------------------|
| 1 | Explore        | `./templates/explore.md`      | Exploration & research document |
| 2 | Requirements   | `./templates/requirements.md` | Formal requirements document    |
| 3 | Design         | `./templates/design.md`       | Architecture & design document  |
| 4 | Implementation | `./templates/implementation.md` | TDD implementation plan       |

## State Machine

The pipeline state is managed via a shell script. Use these commands:

```sh
# Check current phase and progress
sh ./scripts/pipeline.sh status

# Start a new feature pipeline
sh ./scripts/pipeline.sh init <feature-name>

# Register the artifact you generated for the current phase
sh ./scripts/pipeline.sh artifact <path-to-artifact>

# Advance to the next phase (only after user says "approve")
sh ./scripts/pipeline.sh approve

# Return to the previous phase (undo an approval)
sh ./scripts/pipeline.sh rollback

# View history of completed phases and archived pipelines
sh ./scripts/pipeline.sh history

# Archive and reset the pipeline
sh ./scripts/pipeline.sh reset

# Publish approved artifacts to committable directory
sh ./scripts/pipeline.sh publish
```

## Project Configuration

If the file `.spec-driven-dev/config.yaml` exists in the project root, read it before starting any phase.

- **`context`** — project-wide background (tech stack, conventions, repo structure). Treat as extra context for ALL phases.
- **`rules.<phase>`** — phase-specific rules that supplement (not replace) the template instructions.

Injection order: **context → phase rules → template instructions.**

If the file does not exist, skip this step.

## Rules

1. **MUST check status first.** Run `pipeline.sh status` before doing anything. Never generate phase output without checking status.
2. **Never skip phases.** Follow the order: explore → requirements → design → implementation.
3. **Never auto-approve.** Wait for the user to explicitly say "approve" or equivalent.
4. **Read the template.** Before generating output for a phase, read the corresponding template file.
5. **Save artifacts.** Save generated documents to `.spec-driven-dev/state/` and register them with `pipeline.sh artifact`.
6. **Each phase produces one artifact** that becomes input for the next phase.
7. **Artifacts are cumulative.** Each phase reads all prior artifacts.
8. **Revision limit.** If the user rejects the same artifact 3 times in a row, stop generating and ask: "We've gone through 3 revisions — could you clarify what's missing or what direction you'd prefer?" Do not continue revising without explicit guidance.
9. **Surface uncertainty.** If you are unsure about intent, scope, or technical approach — say so explicitly. State the assumption you would make and ask the user to confirm or correct it. Never silently assume.

## Error Recovery

- **Revising an artifact:** Overwrite the file, re-register with `pipeline.sh artifact <path>`, and present the updated version to the user.
- **Incorrect approval:** Run `pipeline.sh rollback` to return to the previous phase with the artifact restored. Revise and re-approve. Note: rollback restores the artifact *path*, not the file contents. If you overwrote the artifact file at that path, retrieve the previous version from git history.
- **Starting over:** Run `pipeline.sh reset` followed by `pipeline.sh init <feature-name>` to begin a new pipeline.

## Publishing Artifacts

After the pipeline is complete (`phase=done`), run `pipeline.sh publish` to copy all approved artifacts to `.spec-driven-dev/specs/<feature>/`. These files live outside the gitignored `state/` directory and can be committed to version control, creating a persistent record of decisions for future reference.

## Quick Start (for the agent)

When the user says something like "I want to add feature X":

1. Run `pipeline.sh status` — if no active pipeline, run `pipeline.sh init <feature-name>`
2. Read `./templates/explore.md` — investigate the problem space
3. Generate the exploration document → save to `.spec-driven-dev/state/<feature>-explore.md`
4. Run `pipeline.sh artifact .spec-driven-dev/state/<feature>-explore.md`
5. Present to user → wait for "approve"
6. Run `pipeline.sh approve` → phase advances to requirements
7. Read `./templates/requirements.md` → follow its interview process
8. Generate the requirements document → save, register artifact, present, wait for approve
9. Repeat for design and implementation phases
10. After implementation is approved → `pipeline.sh approve` → pipeline complete
