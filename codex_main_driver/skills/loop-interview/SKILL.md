---
name: loop-interview
description: "Explicit phase-entry workflow for shaping a new or deliberately reopened idea into evidence-backed decisions before specification. Use only when the user explicitly invokes $loop-interview to start, resume, or reopen structured discovery. Do not trigger implicitly for routine follow-up questions, clarifications, decisions, status checks, objections, or continued work when an active discovery artifact already carries the phase."
---

# Loop Interview

Turn an idea into either a spec-ready decision set or a deliberately loose note. Keep the conversation useful to the human, not exhaustive for its own sake.

## Entry gate

- Run only on explicit `$loop-interview` invocation.
- Treat an existing discovery note or settled boundary as active state. Read it
  and continue from its open edge instead of restarting the interview.
- A new independent scope may receive its own discovery artifact. Routine
  continuation of the current scope may not.
- After entry, persist durable decisions in repository artifacts. Ordinary
  follow-up turns rely on those artifacts and the repository working agreement,
  not repeated skill injection.

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
