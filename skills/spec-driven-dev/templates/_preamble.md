# Phase Preamble — Shared Instructions

This file contains pipeline integration and project context instructions shared by all phase templates.

Each phase template references this file instead of repeating these sections.

---

## Pipeline Integration

Before starting any phase work:

1. **Check pipeline state:**
   ```
   sh ./scripts/pipeline.sh status
   ```
2. **Read input artifacts:** read all completed phase artifacts listed in the status output (`history[N].artifact`). Later phases build on earlier ones — read them all for context.
3. **After the user approves your output:**
   a. Save the document to `.spec/features/<feature-name>/<phase-name>.md`
   b. Register: `sh ./scripts/pipeline.sh artifact` (defaults to `.spec/features/<feature-name>/<phase-name>.md`)
   c. Wait for user to confirm, then: `sh ./scripts/pipeline.sh approve`

---

## Project Context

If `.spec/config.yaml` exists, read it now and apply:
- **`context`** → treat as background knowledge about this project.
- **`rules.<phase>`** → treat as additional rules for THIS phase (appended to the rules below, not replacing them). The phase-specific rule key is specified in each template.

If the file does not exist, skip this step.
