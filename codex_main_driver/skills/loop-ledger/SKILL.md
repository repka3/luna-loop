---
name: loop-ledger
description: "Maintain a durable decision ledger for work whose intent, boundaries, or trade-offs are still unsettled. Invoke only when the user explicitly starts or resumes structured discovery with $loop-ledger; do not trigger for routine continuation, status, or clear implementation work."
---

# Loop Ledger

Resolve genuine owner decisions and preserve each answer immediately. This is an optional discovery tool, not the first step of a mandatory pipeline.

## Enter deliberately

- Run only when the user explicitly invokes `$loop-ledger` to start, resume, or reopen structured discovery.
- Read the repository guidance and any existing ledger before asking questions. Continue from its open edge; never restart settled discovery.
- Inspect files, documentation, probes, and measurements before asking anything the repository or evidence can answer.
- Choose the lightest route that fits the work. Clear small work may go directly to implementation. Research may need only a note. A plan or behavior definition is optional.

## Keep the live ledger current

Write `docs/ledgers/YYYY-MM-DD-HHMM-<topic>.md` using local time. If a relevant ledger already exists, update it instead of creating a parallel account.

Keep only useful sections:

- **Status and scope** — active, settled, paused, or superseded; what this ledger governs.
- **Settled decisions** — exact decisions and short reasons.
- **Reversals** — what changed, why, and which downstream artifacts need reconciliation.
- **Open owner decisions** — questions only the user can answer.
- **Pending evidence** — discoverable facts, their owner, and the next probe.
- **Resume point** — the next unresolved edge and relevant file paths.

After every settled answer, update the ledger before moving to the next question. Do not hold decisions only in conversation until the end.

## Ask narrowly

- Resolve one genuine user decision per message.
- Ask only when the answer changes intent, boundaries, behavior, or a meaningful trade-off.
- Determine engineering details from evidence when the agreed scope already decides them; report consequential choices so the user can correct them.
- Explain unfamiliar options concretely, preferably with a small example or code shape.
- Never invent a workaround to preserve momentum. Record the evidence gap or blocker.

## Leave no conversational state behind

Before saying discovery is complete, pausing, handing off, or ending the session:

1. Reconcile the whole live conversation against the ledger.
2. Persist every settled decision, correction, reversal, pending probe, and resume point.
3. Reconcile any README, repository handoff, note, behavior definition, or plan whose current text would now mislead the next session.
4. State the lightest sensible next route: direct implementation, plan, behavior definition, research note/evidence ladder, more discovery, or stop.

The ledger records decisions; it does not authorize implementation and does not force a next phase.
