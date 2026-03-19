# Spec-Driven Development

You are operating in **spec-driven development mode**.
This project uses a 3-phase pipeline with human approval gates between each phase.

## Pipeline

```
Requirements → [APPROVE] → Design → [APPROVE] → Implementation → [APPROVE] → Done
```

Each phase has a dedicated prompt template. Read the template for the **current** phase before generating any output.

## Phases

| # | Phase          | Template                                        | Produces                        |
|---|----------------|-------------------------------------------------|---------------------------------|
| 1 | Requirements   | `.spec-driven-dev/templates/requirements.md`    | Formal requirements document    |
| 2 | Design         | `.spec-driven-dev/templates/design.md`          | Architecture & design document  |
| 3 | Implementation | `.spec-driven-dev/templates/implementation.md`  | TDD implementation plan         |

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

## Rules

1. **Always check status first.** Run `pipeline.sh status` before doing anything.
2. **Never skip phases.** Follow the order: requirements → design → implementation.
3. **Never auto-approve.** Wait for the user to explicitly say "approve" or equivalent.
4. **Read the template.** Before generating output for a phase, read the corresponding template file.
5. **Save artifacts.** Save generated documents to `.spec-driven-dev/state/` and register them with `pipeline.sh artifact`.
6. **Each phase produces one artifact** that becomes input for the next phase.
7. **Artifacts are cumulative.** The design phase reads the requirements artifact. The implementation phase reads both.

## Error Recovery

- **Revising an artifact:** Overwrite the file, re-register with `pipeline.sh artifact <path>`, and present the updated version to the user.
- **Incorrect approval:** Run `pipeline.sh rollback` to return to the previous phase with the artifact restored. Revise and re-approve.
- **Starting over:** Run `pipeline.sh reset` followed by `pipeline.sh init <feature-name>` to begin a new pipeline.

## Quick Start (for the agent)

When the user says something like "I want to add feature X":

1. Run `pipeline.sh status` — if no active pipeline, run `pipeline.sh init <feature-name>`
2. Read `templates/requirements.md` — follow its interview process
3. Generate the requirements document → save to `state/<feature>-requirements.md`
4. Run `pipeline.sh artifact state/<feature>-requirements.md`
5. Present to user → wait for "approve"
6. Run `pipeline.sh approve` → phase advances to design
7. Read `templates/design.md` → read the requirements artifact from history
8. Generate the design document → save, register artifact, present, wait for approve
9. Repeat for implementation phase
10. Pipeline complete — user has requirements + design + implementation plan
