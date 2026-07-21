---
name: loop-review
description: "Run an optional independent Opus review of a ledger, behavior definition, plan, or implementation and triage its findings against primary evidence. Invoke only when the user explicitly requests $loop-review or deliberately selects an independent review."
---

# Loop Review

Use Opus as a read-only second set of eyes when the cost or uncertainty justifies it. Review is optional; it is not a universal gate and the reviewer does not decide convergence.

`$opus` owns dispatch mechanics. This skill owns the brief, evidence, triage, and durable review record.

## Review the right failure mode

- **Ledger** — missed decisions, contradictions, stale resume state, or conversation decisions not persisted.
- **Behavior definition** — ambiguity, undefined normative language, conflicting rules, missing failure results, or acceptance gaps.
- **Plan** — invented policy, incomplete affected surface, dependency errors, divergence from governing behavior, or verification that cannot catch failure.
- **Implementation** — divergence from governing behavior or plan, regressions, unsupported assumptions, unsafe side effects, or missing verification.

## Compose a neutral brief

- Provide the complete subject and every artifact it depends on in reading order.
- State the scope, authority hierarchy, trust boundary when relevant, reviewed baseline or diff, and verified test results.
- Withhold conversational advocacy and the driver's preferred conclusion.
- Ask for numbered findings with severity, evidence, precise references, user-visible cost, and the smallest supported correction.
- Ask the reviewer to identify uncertainty rather than fill missing context with guesses.

## Triage against evidence

For each finding choose:

- **fold** — supported, in scope, and worth correcting;
- **cut** — unsupported or outside the settled boundary, with the exact reason;
- **escalate** — a real owner decision or meaning change.

Verify material reviewer claims against primary evidence. Neither model wins by identity.

## Record the result

Write a review record beside the subject as `<subject-basename>.review.md`; an implementation review may use `<plan-basename>.implementation.review.md`. Record the reviewer/model/effort, inputs and baseline, findings, evidence checks, dispositions, changes made, and residual uncertainty. Do not call this record a ledger.

Further rounds are optional and proportionate. Re-run focused tests before reviewing material implementation fixes. Invoke `$opus` at `xhigh`; use `max` only when the user explicitly asks.
