---
name: loop-plan
description: "Turn a gated specification into a decision-complete plan for direct implementation by the context-rich Codex driver. Use after the spec gate and before any code changes."
---

# Loop Plan

Produce a plan the current Codex driver can implement directly without dispatching a cold executor. Preserve useful context; do not duplicate every task into a standalone prompt.

Output `docs/plans/YYYY-MM-DD-HHMM-<topic>.md` using local time. In a planning-only session, present the complete plan first and persist it only after writes are authorized.

## Ground the plan in reality

- Read the gated spec in full; it remains the behavior authority.
- Inspect every path, symbol, dependency, command, and precondition the plan will name.
- Search every changed surface for consumers and pinning tests so the file scope includes what can break, not only what will be edited.
- Resolve discoverable facts before asking the user. Bring forward only product decisions or trade-offs that remain genuinely open.

## Plan structure

Start with the goal, governing spec path, global constraints, and acceptance target. For each dependency-ordered task include:

- **Outcome** — the observable result and why the task exists.
- **Files** — exact create, modify, remove, and test paths.
- **Interfaces** — contracts consumed and produced, including exact signatures or schemas when relevant.
- **Implementation** — behavior-level changes and decisions; no placeholders or conversational references.
- **Verification** — exact commands and expected outcomes that fail on a wrong implementation.
- **STOP condition** — stop and report when plan, spec, and reality disagree beyond the task's settled scope.

Tasks should be the smallest units worth independently verifying, not mechanical micro-steps. A task may consume only repository state or outputs from earlier tasks.

## Self-review

- Map every spec requirement and acceptance check to at least one task.
- Remove `TBD`, ellipses standing in for contracts, and instructions such as “handle appropriately” or “similar to the previous task.”
- Check interface names and types across task boundaries.
- Check dependency order and the complete affected-file surface.
- Ensure verification includes the project standard suite where proportionate.

Hand the plan to `$loop-review`. A plan is not execution authorization; `$loop-execute` begins only on the user's explicit go-word.
