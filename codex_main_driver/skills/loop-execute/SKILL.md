---
name: loop-execute
description: "Implement authorized work directly in the context-rich Codex session and verify it proportionately. Invoke only after an explicit user go-word because $loop-execute writes files and may create commits; a plan is useful but not required."
---

# Loop Execute

Implement directly in the main session. Use the repository's real state and the full conversation; do not perform a ceremonial handoff to a cold executor.

## Require authorization

Begin only on an explicit go-word such as `go`, `build it`, or `implement`. Authorization covers the settled work, not new behavior, expanded scope, external writes, pushes, deployments, or user-visible trade-offs that were not agreed.

## Follow the available authority

Read the current request, repository guidance, and relevant artifacts. When present, use this order:

1. the user's latest explicit correction;
2. an accepted behavior definition;
3. the implementation plan;
4. the decision ledger and evidence notes.

If these disagree materially, reconcile the durable artifacts or stop for the owner decision. Do not silently choose the convenient interpretation.

## Implement and verify

For each meaningful change:

1. Inspect the affected code and consumers.
2. Make the smallest maintainable change that satisfies the settled behavior.
3. Inspect the actual diff for unintended edits.
4. Run focused checks and the proportionate project suite.
5. Diagnose failures and suspected flakes from evidence. Do not require an arbitrary number of green runs when one supported run is adequate.
6. Update documentation, ledgers, behavior definitions, plans, and the repository handoff when the implementation changes what the next session must know.

Do not create commits, push, deploy, or mutate external systems unless the user's authorization and repository workflow cover that action.

## Stop instead of improvising

Missing permissions, dependencies, capabilities, or external coordination are blockers to report. When reality contradicts settled behavior or exposes a new product trade-off, bring the evidence to the user rather than inventing a workaround.

At completion, report the result, changed files, verification evidence, artifact reconciliations, and residual risk. `$loop-review` may be used when an independent pass is valuable; no final Opus gate is mandatory.
