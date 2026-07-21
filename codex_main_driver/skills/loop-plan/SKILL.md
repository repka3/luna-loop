---
name: loop-plan
description: "Create a decision-complete implementation plan for nontrivial work when planning adds real value. Invoke only when the user explicitly requests $loop-plan; a ledger or behavior definition may guide it but neither is mandatory."
---

# Loop Plan

Produce an implementation recipe for work that benefits from sequencing, affected-surface analysis, or explicit verification. Do not create a plan for a small clear change merely to satisfy ceremony.

Output `docs/plans/YYYY-MM-DD-HHMM-<topic>.md` using local time, or update the existing plan.

## Establish authority

- Read the current request and repository guidance.
- Read any governing accepted behavior definition, relevant ledger, research note, and existing plan in full.
- An accepted behavior definition governs observable behavior when present. Without one, settled user instructions and recorded decisions govern.
- Inspect every path, symbol, dependency, consumer, test, and command the plan will name.
- Do not invent missing product behavior. Resolve discoverable engineering facts yourself; bring genuine owner decisions back to the user or ledger.

## Plan the actual work

Start with the goal, governing artifact paths if any, constraints, and acceptance target. For each dependency-ordered task include only what is useful:

- **Outcome** — the observable result and reason.
- **Files** — exact create, modify, remove, and test paths.
- **Interfaces and behavior** — exact signatures, schemas, invariants, or state transitions involved.
- **Implementation** — enough detail to prevent rediscovery without dictating mechanical keystrokes.
- **Verification** — exact commands and expected evidence that can expose a wrong implementation.
- **Stop condition** — evidence or disagreement that requires replanning or an owner decision.

Tasks should be the smallest units worth independently verifying, not ceremonial micro-steps.

## Check before handoff

- Cover the complete affected surface, including consumers, migrations, documentation, and pinning tests.
- Map every applicable behavior rule and acceptance observation to a task.
- Remove placeholders and phrases such as `handle appropriately`.
- Check dependency order and interface names against the repository.
- Keep verification proportionate to risk.
- Reconcile any ledger, behavior definition, and repository handoff changed by the plan.

A plan does not authorize implementation. `$loop-review` is available when independent review is worth its cost; it is not a mandatory gate. `$loop-execute` starts only on explicit implementation authorization.
