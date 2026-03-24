# Spec-Driven Development

You are operating in **spec-driven development mode**.
This project uses a 5-phase pipeline with human approval gates between each phase.

## Pipeline

```
Explore → [APPROVE] → Requirements → [APPROVE] → Design → [APPROVE] → Implementation → [APPROVE] → Verify → Done
```

Each phase has a dedicated prompt template. Read the template for the **current** phase before generating any output.

## Phases

| # | Phase          | Template                                        | Produces                        |
|---|----------------|-------------------------------------------------|---------------------------------|
| 1 | Explore        | `.spec-driven-dev/templates/explore.md`         | Exploration & research document |
| 2 | Requirements   | `.spec-driven-dev/templates/requirements.md`    | Formal requirements document    |
| 3 | Design         | `.spec-driven-dev/templates/design.md`          | Architecture & design document  |
| 4 | Implementation | `.spec-driven-dev/templates/implementation.md`  | TDD implementation plan         |
| 5 | Verify         | `.spec-driven-dev/templates/verify.md`          | Verification report (chat only) |

## State Machine

The pipeline state is managed via a shell script. Use these commands:

```sh
# Check current phase and progress
sh .spec-driven-dev/scripts/pipeline.sh status

# Start a new feature pipeline
sh .spec-driven-dev/scripts/pipeline.sh init <feature-name>

# Register the artifact you generated for the current phase
sh .spec-driven-dev/scripts/pipeline.sh artifact <path-to-artifact>

# Advance to the next phase (only after user says "approve")
sh .spec-driven-dev/scripts/pipeline.sh approve

# Return to the previous phase (undo an approval)
sh .spec-driven-dev/scripts/pipeline.sh rollback

# View history of completed phases and archived pipelines
sh .spec-driven-dev/scripts/pipeline.sh history

# Archive and reset the pipeline
sh .spec-driven-dev/scripts/pipeline.sh reset
```

## Project Configuration

If the file `.spec-driven-dev/config.yaml` exists, read it before starting any phase.

- **`context`** — project-wide background (tech stack, conventions, repo structure). Treat as extra context for ALL phases.
- **`rules.<phase>`** — phase-specific rules that supplement (not replace) the template instructions.

Injection order: **context → phase rules → template instructions.**

If the file does not exist, skip this step.

## Rules

1. **Always check status first.** Run `pipeline.sh status` before doing anything.
2. **Never skip phases.** Follow the order: explore → requirements → design → implementation → verify.
3. **Never auto-approve.** Wait for the user to explicitly say "approve" or equivalent.
4. **Read the template.** Before generating output for a phase, read the corresponding template file.
5. **Save artifacts.** Save generated documents to `.spec-driven-dev/state/` and register them with `pipeline.sh artifact`. Exception: verify phase outputs to chat only (no saved artifact).
6. **Each phase produces one artifact** that becomes input for the next phase (except verify).
7. **Artifacts are cumulative.** Each phase reads all prior artifacts.

## Error Recovery

- **Revising an artifact:** Overwrite the file, re-register with `pipeline.sh artifact <path>`, and present the updated version to the user.
- **Incorrect approval:** Run `pipeline.sh rollback` to return to the previous phase with the artifact restored. Revise and re-approve.
- **Starting over:** Run `pipeline.sh reset` followed by `pipeline.sh init <feature-name>` to begin a new pipeline.

## Quick Start (for the agent)

When the user says something like "I want to add feature X":

1. Run `pipeline.sh status` — if no active pipeline, run `pipeline.sh init <feature-name>`
2. Read `templates/explore.md` — investigate the problem space
3. Generate the exploration document → save to `state/<feature>-explore.md`
4. Run `pipeline.sh artifact state/<feature>-explore.md`
5. Present to user → wait for "approve"
6. Run `pipeline.sh approve` → phase advances to requirements
7. Read `templates/requirements.md` → follow its interview process
8. Generate the requirements document → save, register artifact, present, wait for approve
9. Repeat for design and implementation phases
10. After implementation is approved → phase advances to verify
11. Read `templates/verify.md` → validate implementation against all prior artifacts
12. Present verification report in chat → wait for "approve"
13. Run `pipeline.sh approve` → pipeline complete
