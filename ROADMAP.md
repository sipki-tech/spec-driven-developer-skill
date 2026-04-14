# Roadmap

Future improvements for spec-driven-developer-skill, roughly ordered by impact.

## Planned

### Plain-language Correctness Property explanations

In `design.md`, after each formal Correctness Property (`For all ...`), add a mandatory plain-language summary in one sentence. Example: `Property 2: No duplicate charges... → In plain terms: no matter how many times the user clicks "Pay", money is charged exactly once.` Lowers the bar for users unfamiliar with formal specifications.

## Done

### Escape hatch for pre-written artifacts

Implemented in v1.2.0 as `pipeline.sh inject <phase> <path>`.

### Config validation

Implemented in v1.2.0 as `pipeline.sh config-check`.


