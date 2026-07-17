---
name: loop-interview
description: "Shape an idea into evidence-backed decisions before specification. Use for brainstorming, scoping, requirements discovery, roadmap discussion, or any request that is still too ambiguous to specify or build."
---

# Loop Interview

Turn an idea into either a spec-ready decision set or a deliberately loose note. Keep the conversation useful to the human, not exhaustive for its own sake.

## Start with scope

- Identify independent subsystems before refining details. Split work that cannot share one authority document and one implementation plan.
- Separate facts that can be discovered from preferences only the user can decide.
- Inspect the real system before asking questions answerable from files, documentation, probes, or measurements.

## Work evidence first

- Treat every option as a claim. Verify an option before offering it, especially the recommended one.
- When an existing system or dependency is involved, attach receipts such as file locations, command output, documentation, or measurements.
- Turn a reported symptom into an observable fact before designing around it.
- Never invent a workaround to preserve momentum. When a needed fact or capability is unavailable, stop, state the gap, and discuss it.

## Keep the dialogue focused

- Resolve one genuine user decision per message.
- Settle implementation details independently when the evidence and agreed scope determine them; report those choices so the user can veto them.
- Ask only questions whose answers materially change intent, boundaries, or trade-offs.
- State the emerging goal, success criteria, audience, in-scope work, non-goals, and constraints as they stabilize.

## Exit deliberately

Choose one exit:

1. When decisions are concrete and open questions are empty, hand the result to `$loop-spec`.
2. When the idea remains exploratory, write a loose note under `docs/notes/YYYY-MM-DD-HHMM-<topic>.md` using local time. Notes may contain direction statements, roadmap checkboxes, research, and unresolved alternatives; they are not specifications.

Do not begin implementation merely because the interview became interesting.
