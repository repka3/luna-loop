---
name: loop-execute
description: "Implement a gated plan directly in the main Codex session, verify each task, preserve the spec authority, and run the required final Opus implementation gate. Invoke only after an explicit user go-word because it writes files and may create commits."
---

# Loop Execute

Implement directly with the main session's full context. Do not dispatch a cold Codex executor and do not perform a ceremonial self-handoff.

## Authorization

Begin only on an explicit go-word such as “go,” “build it,” or “implement the plan.” A standing instruction to continue authorizes the settled plan, not changes to its meaning or user-visible trade-offs.

## Implement one verified task at a time

For each task:

1. Re-read the governing spec section, plan task, and current repository state.
2. Implement the smallest maintainable change that satisfies the task; use the main session's context to resolve in-scope implementation details.
3. Inspect the actual diff hunk by hunk against the contracts and trust boundary.
4. Run the task verification and the proportionate project suite. Treat tool output as evidence, not the model summary.
5. Diagnose suspected flakes; require three consecutive greens and a cause before accepting one as resolved.
6. Commit the verified task when the project workflow authorizes commits. Otherwise preserve a clean, reviewable task boundary and state that no commit was made.

Do not start the next task while the current task is red or unexplained.

## Handle disagreement without improvising

When plan and reality disagree, diagnose the evidence. Amend the plan when the discrepancy stays inside the gated spec. If it changes behavior, scope, or a user-visible trade-off, stop and bring the conflict to the user. When reality proves the spec wrong, correct the spec in place with dated evidence before continuing.

Missing capabilities, permissions, dependencies, or external coordination are blockers to discuss, not invitations to find a hidden workaround.

## Final implementation gate

After every plan task is green:

1. Prepare the gated spec, plan, implementation baseline/diff, and verified test results.
2. Use `$loop-review` for one full Opus implementation review at `xhigh`.
3. Triage every finding. Fix folded findings and rerun focused plus standard verification.
4. Run a fresh diff-only Opus verification for material fixes.
5. Record the result in `<plan-basename>.implementation.review.md` and let the user call convergence.

Report what landed, what verification caught, accepted findings, plan/spec amendments, test evidence, and any conscious residual risk.
