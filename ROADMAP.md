# Roadmap

Future improvements for spec-driven-developer-skill, roughly ordered by impact.

## Planned

### Escape hatch for pre-written artifacts

New command `pipeline.sh inject <phase> <path>` — register an externally written artifact and jump straight to approval. Validates presence of required sections (WHEN/SHALL for requirements, Correctness Properties for design) but does not regenerate the document. Useful when the user already has a spec or design doc in hand.

### Plain-language Correctness Property explanations

In `design.md`, after each formal Correctness Property (`For all ...`), add a mandatory plain-language summary in one sentence. Example: `Property 2: No duplicate charges... → In plain terms: no matter how many times the user clicks "Pay", money is charged exactly once.` Lowers the bar for users unfamiliar with formal specifications.

### Config validation

Add `pipeline.sh config-check` (or integrate into `status`) — validates `.spec/config.yaml` against a known schema. Flags unknown keys (e.g., `ruls.explore` typo), validates types, reports missing optional fields. Simple grep-based validation is sufficient.


