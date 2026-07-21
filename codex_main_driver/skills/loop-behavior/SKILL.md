---
name: loop-behavior
description: "Write or update an exact behavior definition when observable rules need durable authority across planning, implementation, or future sessions. Invoke only when the user explicitly requests $loop-behavior; it is optional and does not require a prior ledger."
---

# Loop Behavior

Write the smallest durable authority needed to prevent two competent implementers from producing different observable behavior. This is optional: do not create one for work that a clear request, code change, and tests already define adequately.

Output `docs/behaviors/YYYY-MM-DD-HHMM-<topic>.md` using local time, or update the existing governing file. A behavior definition may come directly from settled user instructions; a ledger is not a prerequisite.

## Required properties

- Mark the document **draft**, **accepted**, or **superseded**.
- State the goal, scope, and non-goals.
- Define observable inputs, outputs, state changes, ordering, limits, and failure results that matter to this behavior.
- Record exact invariants and decision tables when combinations of fields or states matter.
- Define acceptance observations or tests that would fail for an incorrect implementation.
- Preserve decision reasons when they prevent likely future reopening or misinterpretation.
- Separate unmeasured engineering facts into **Pending evidence** with an owner and probe. Do not disguise guesses as rules.

Use only sections that help the subject. Architecture, threat boundaries, migration, compatibility, performance, and failure walkthroughs are included only when they materially constrain observable behavior.

## Precision gate

Replace words such as `safe`, `sanitized`, `appropriate`, `reasonable`, `supported`, `robust`, `caller data`, and `handle correctly` with the exact operation, field set, condition, or result they mean. If the term is intentionally broad, define its boundary in the document.

Before marking the definition accepted:

- remove placeholders and unresolved owner decisions;
- verify claims about the existing system against files or evidence;
- check every rule for conflicting interpretations;
- map each material rule to an acceptance observation;
- reconcile the ledger and repository handoff, when they exist.

An accepted behavior definition governs downstream plans and implementation until the user changes it. When evidence disproves it, update or supersede it explicitly and propagate the correction. Review and planning are optional next actions, not mandatory gates.
