---
name: loop-interview
description: "Pre-spec interview: turn an idea into settled decisions or a loose note. One decision per message; verify options before offering them. Use when brainstorming or shaping work that is not yet a spec."
---

# loop-interview — before anything is written down

Turn an idea into either a spec-ready set of decisions or a deliberately loose
note. The interview is a dialogue, not a questionnaire.

## Rules

- **One decision per message.** Every fact in the message earns its place by
  serving that one decision. What overwhelms people is never fact density — it
  is unfocused scope.
- **An option is a claim.** Never offer an option that ten seconds of checking
  would collapse — read the source, count the bytes, run the probe first, and
  bring the settled answer instead of the menu. The option you recommend
  carries the *highest* verification bar, not the lowest: recommendations
  anchor, so an unchecked recommendation is worse than an unchecked option.
- **Settle implementation details yourself and say so.** Bring the user only
  decisions that are genuinely theirs; report the ones you settled in passing
  so they can veto.
- **Scope check first.** If the request spans multiple independent subsystems,
  decompose before refining details — don't spend questions polishing a corner
  of something that needs splitting.

## Two exits

1. **Concrete enough to specify** → hand the settled decisions to `loop-spec`.
2. **Too big or fuzzy to spec yet** → write a **note**:
   `mkdir -p docs/notes` (relative to the project root), then
   `docs/notes/YYYY-MM-DD-HHMM-<topic>.md` (24-hour, local time — the
   timestamp makes a directory listing read as history). Notes are the
   undisciplined layer, deliberately: direction statements, `[x]`/`[ ]`
   roadmap checkboxes for goals too fuzzy to spec, research findings gathered
   mid-interview (alternatives, benchmarks). No template beyond the filename.
