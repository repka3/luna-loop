---
name: loop-spec
description: "Write a specification from settled decisions: goal, trust boundary and non-goals, numbered requirements with acceptance checks, decisions with their why. Use when an interview has produced spec-ready decisions."
---

# loop-spec — write it down so it can be gated

A spec freezes what the interview settled. It is written to be reviewed by a
cold adversary and built on by a cold executor — every section exists for one
of those two readers.

Output: `mkdir -p docs/specs` (relative to the project root), then
`docs/specs/YYYY-MM-DD-HHMM-<topic>.md` (24-hour, local time — the timestamp
makes lexicographic order chronological).

## Template

1. **Goal** — one sentence.
2. **Trust Boundary / Non-Goals** — *mandatory, never skipped.* Who calls
   this, what input is trusted, which threat classes and features are
   explicitly out of scope. This section is the **triage yardstick**: review
   findings outside it get cut, not folded. It also goes into the reviewer's
   reading order, so findings arrive calibrated instead of maximal.
3. **Architecture / approach** — scaled to complexity; a few sentences for
   simple things.
4. **Requirements** — numbered, testable, exact values. No ranges standing in
   for decisions you didn't make.
5. **Acceptance** — how each requirement is checked (command, observation, or
   review), so "done" is an observation, not an opinion.
6. **Decisions** — each with its *why*, so review rounds don't re-litigate
   them and future readers don't reopen them by accident.
7. **Open Questions** — must be **empty** before the review gate; if it
   isn't, go back to `loop-interview`. Facts that only another machine or a
   later phase can verify are not open questions — they go in a **Pending
   Measurements** list with a named owner.

## Self-review before the gate

Run inline, fix inline, no re-review:

1. **Placeholder scan** — "TBD", vague requirements, sections that describe
   without deciding.
2. **Internal consistency** — do any sections contradict each other?
3. **Scope** — is this one plan's worth, or does it need decomposition?
4. **Ambiguity** — could any requirement be read two ways? Pick one, write it
   down.
