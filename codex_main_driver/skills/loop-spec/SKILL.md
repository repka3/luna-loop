---
name: loop-spec
description: "Write an authoritative, gate-ready specification from settled decisions. Use after discovery is complete and before implementation planning for work that needs explicit behavior, boundaries, failure handling, and acceptance checks."
---

# Loop Spec

Write the single behavior authority that a plan, reviewer, and implementation can follow without recovering the prior conversation.

Output `docs/specs/YYYY-MM-DD-HHMM-<topic>.md` using local time. If the session cannot write, present the complete specification for approval and persist it only when writes are authorized.

## Required structure

1. **Goal** — one sentence.
2. **Trust Boundary / Non-Goals** — callers, trusted inputs, threat classes, and excluded features. Use this as the review triage yardstick.
3. **Architecture / Approach** — enough structure to make the behavior and ownership clear.
4. **Requirements** — numbered, testable, and exact. For every tunable constant, record what fails when it is too low and too high.
5. **Failure Walkthroughs** — narrate each in-scope failure as the boundary human experiences it: what they see, what they lose, and when they know. Reference only inputs, commands, and states that exist or that the spec defines.
6. **Acceptance** — map every requirement to an observation, command, or review check that can fail when the implementation is wrong.
7. **Decisions** — record each decision with its reason so later reviews do not reopen it accidentally.
8. **Open Questions** — empty before review. Put later machine-owned facts in **Pending Measurements** with a named owner instead.

## Self-review before the gate

- Scan for placeholders, ranges standing in for decisions, vague requirements, and contradictory sections.
- Verify every existing-system claim and every walkthrough input has a receipt.
- Confirm the work fits one implementation plan; split it otherwise.
- Resolve every sentence that two competent readers could implement differently.
- Check that each requirement has an acceptance check and each failure has a boundary-human walkthrough.

## Authority

Once gated, the spec wins over the plan. If reality contradicts both, stop rather than improvise. When evidence proves the spec wrong, correct it in place with the evidence and date, then propagate the correction downstream.

Hand the self-reviewed document to `$loop-review`; do not plan or build on an ungated spec.
