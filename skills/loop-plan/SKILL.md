---
name: loop-plan
description: "Turn a gated spec into an implementation plan whose tasks are cold-executor dispatches: exact files, interfaces, contracts verbatim, verify commands, STOP rule. Use after a spec has passed its review gate."
---

# loop-plan — a plan is a sequence of dispatches

Each task is written so it can be extracted into a cold executor's promptfile
with zero translation. **Extraction contract: every dispatch promptfile = the
plan's Global Constraints section verbatim + the one task, always.** Nothing is
"implicitly included" — the executor sees exactly what is prepended, and
anything not in the promptfile or on disk does not exist for it.

Output: `mkdir -p docs/plans` (relative to the project root), then
`docs/plans/YYYY-MM-DD-HHMM-<topic>.md`.

## Structure

**Header:** the goal in one sentence, then **Global Constraints** copied
verbatim from the gated spec — version floors, naming rules, platform
requirements, shared schemas and exact strings that multiple tasks consume.
Anything a lone task will need must live here or in the task itself.

**Per task:**
- **Files:** exact paths — `Create:` / `Modify: path:lines` / `Test:`.
- **Interfaces:** `Consumes:` / `Produces:` with exact signatures. A cold
  executor sees only its own task; this block is how it learns what its
  neighbors expect.
- **Contracts verbatim** — schemas, types, exact strings copied in, not
  referenced. Exception: documents already on disk and gated may be cited by
  path and section ("read spec §X in full") — the authority is better than a
  paraphrase of it.
- **Verify:** exact commands with expected outcomes — commands that would
  actually fail on a wrong implementation, not keyword greps that pass
  vacuously.
- **STOP rule, every task:** "if this plan and reality disagree in a way this
  scope cannot absorb, stop and report instead of improvising." A stop is a
  plan bug found cheaply, not a failure.

## Before the gate: the reality scan

`rg` / `ls` every path, symbol, and precondition the plan names, against the
actual repo. A plan that assumes a file no task creates fails at dispatch one;
the scan costs a minute and catches it now. Also `rg` every surface the plan
*changes* for consumers and pinning tests the file list missed — the whitelist
must include the files that will break, not only the files that will change,
or the executor meets them mid-task and stops.

## Hard rules

- **No placeholders.** "TBD", "add appropriate error handling", "similar to
  task N" (repeat the content instead), `...`-elided schemas, steps that
  describe without showing — all of them are plan failures.
- **Executor-facing text is self-contained.** Zero skill references, zero
  conversation references, nothing that is not on disk. `REQUIRED SUB-SKILL:
  <anything>` is the canonical anti-pattern: an instruction the executor
  cannot follow, pointing at a system it cannot see.
- **Task granularity:** the smallest unit worth a reviewer's gate — not
  2–5-minute micro-steps. The executor is a capable model, not a typist.
- **Dependency order:** a task may only consume what earlier tasks or the
  repo already provide.

## Self-review

Spec coverage (every requirement maps to a task), placeholder scan, interface
consistency (names and types in task N match what task M defined), dependency
order. Fix inline and move on.
