---
name: loop-execute
description: "Execute a gated plan task-by-task as cold codex dispatches: extract each task's promptfile, verify the diff and tests yourself, commit green before the next task; a STOP amends the plan. Spends money and writes files — invoke only on the user's explicit go-word, never because a gated plan merely exists."
---

# loop-execute — the phase after the plan gate

A gated plan is a sequence of cold dispatches; this skill is the driver's loop
that runs them: **dispatch → verify → commit → next**. How to call codex
(flags, sandbox, effort, run handling) is the `codex` skill — implementation
shape. What a task must contain is `loop-plan`'s contract. This skill owns the
cadence and what happens when reality pushes back.

## Invocation is the user's go-word

"Go", "build it", "dispatch task 1", "continue the plan." Execution spends
money and writes files, so it starts on the user's word — a gated plan's
existence is never the trigger. A standing "keep going" authorizes the whole
run: from then on, plan-level snags (stops, amendments, verification fixes)
are yours to handle and report; interrupt only for decisions that change the
spec's meaning or a user-visible trade-off.

## One task in flight, ever

Task N is verified and committed green before task N+1 dispatches, so every
dispatch lands on a verified tree. When verification finds a bug, the suspect
is one task's diff, not an entangled pair. Pipelining saves minutes and costs
afternoons.

## Extraction

Promptfile = the plan's Global Constraints section verbatim + the one task,
always — nothing else is "implicitly included"; anything not in the promptfile
or on disk does not exist for the executor. Append one standing instruction:
run the task's Verify commands if the sandbox allows, and report exactly what
could not be run. Promptfiles live in the session scratchpad, never in the
project. Dispatch per the `codex` skill's implementation shape.

## Verification is the point, not a ceremony

The executor's summary is a claim, not evidence — and driver verification
regularly finds real bugs; treat it as a finding pass, not a checkbox.

- Read the actual diff, hunk by hunk, against the task's contracts.
- Run the task's Verify commands and the project's standard suite yourself.
- Verify hardest whatever the executor reported it could not run.
- A suspected flake is a diagnosis, not a shrug: rerun to 3 consecutive
  greens AND find the cause — it is usually real (a leftover process, a
  timing assumption), and "flaky" left standing poisons every later run.

## Commit per task

One commit per verified task; the message carries the why, not only the what —
it is the review trail the human reads. Non-git projects have no commit
boundary: verify manually and say so plainly (same stance as `loop-review`).

## A STOP is a plan bug found cheaply

The executor stopping on a plan/reality disagreement is the STOP rule working,
not a failure.

1. Diagnose against reality yourself — the executor's report is a lead, not a
   verdict.
2. Amend the plan; it stays the executor's single source of truth.
3. Commit the amendment.
4. Re-dispatch fresh (never resume — the `codex` skill owns that rule).

If the disagreement reaches the spec's meaning, it is not yours to absorb:
stop the line and bring the human both sides' evidence.

## Report shape

Mid-run: one line per task — task, verdict, what verification caught. At the
end: what landed, what verification caught (bug count is signal, not shame),
amendments made, and anything consciously accepted.
