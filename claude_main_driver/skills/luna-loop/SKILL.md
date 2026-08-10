---
name: luna-loop
description: "The Luna Loop with Claude driving: scale the process to the request — direct work, plan-only, or the whole circus (decision ledger → falsifiable plan with grilling → gated dog execution). Use when the user invokes the loop, says Luna Loop, or asks for the loop workflow. Invocation alone never authorizes implementation."
---

# luna-loop — one process, weighted by the situation

No fixed phases. Read the request, the repo guidance, and enough code to judge
the work — stay read-only while judging — then match the weight:

    trivial and settled ("swap those two buttons")     → just do it, verify
    settled, but execution needs durable precision     → plan → execute
    hard system work, unsettled decisions, or the
    user calls "the whole circus"                      → ledger → plan (grill) → execute

When the user picked the route, follow it. Otherwise recommend the lightest
adequate one, with the reason, and confirm before creating artifacts. Rigor
rises with uncertainty, blast radius, irreversibility, cost, and security
exposure — never with ceremony. No artifact exists merely because another
one does.

Documents are datetime-prefixed, minute precision:
`docs/ledgers/YYYY-MM-DD-HHMM-<topic>.md`, `docs/plans/YYYY-MM-DD-HHMM-<topic>.md`.

## The ledger

The only pre-plan artifact: the running log of decisions for a problem, one
entry per decision with its why. It is updated step by step as we decide —
it starts sparse and grows; early fuzzy thinking is just an early ledger.
It cannot predict the future and does not have to: the grill below exists
to catch what it missed.

## The plan

Falsifiable, or it is not a plan. The bar: two different executors, given
this plan, produce roughly the same implementation. That means what, where,
how, and what-not — exact files, exact interfaces, verify commands
that would actually fail on a wrong implementation. Never
spec-generalities: "we do not log caller data" admits a hundred compliant
implementations and forbids none of the wrong ones.

Shape — each task is a future cold dispatch:

- **Header:** the goal in one sentence, then **Global Constraints** — every
  rule, schema, and exact string more than one task consumes. Extraction
  rule: a dispatch promptfile is the Global Constraints verbatim plus
  the one task, nothing else. Anything not in the promptfile or on disk
  does not exist for the executor.
- **Per task:** Files (exact paths — Create / Modify / Test) · Interfaces
  (Consumes / Produces with exact signatures — how a task learns what its
  neighbors expect) · Verify
  (exact commands with expected outcomes) · and the STOP rule: "if this
  plan and reality disagree in a way this scope cannot absorb, stop and
  report instead of improvising."
- **No placeholders** — "TBD", "appropriate error handling", "similar to
  task N", elided schemas. Executor-facing text is self-contained: zero
  skill references, zero conversation references.
- **Reality scan before execution:** `rg` / `ls` every path, symbol, and
  precondition the plan names — and every surface it changes, for consumers
  the file list missed — against the actual repo.

## The grill — how ledger and plan stay one thing

The failure this section exists to kill: while writing the plan, hitting
something the ledger does not settle and silently deciding "not clear —
I'm going with this." From that moment the plan is no longer based on the
ledger, and nobody knows until it hurts.

- Every point the ledger under-determines is a question to the user. No
  exception for "small," no exception for "obvious to me."
- Every question carries a recommendation, and a bit of back-and-forth is
  the normal cost of a real decision.
- The bar is question quality, not question count. The goal is not few
  questions — it is no dumb ones ("do you agree we should not wipe the
  database?"). Genuinely unclear or genuinely in doubt: ask. Pure
  implementation detail: settle it yourself and say so, so it can be vetoed.
- Every answer is folded back into the ledger before the plan builds on it.
  Ledger and plan never diverge; if they ever do, that is a stop, not a
  judgment call.

## Execution — the dog on a leash

The dog is codex: it does the actual coding, dispatched cold per the `codex`
skill's executor shape, one task per dispatch. Execution starts on the
user's go-word — a finished plan is never the trigger — and the go-word
authorizes the run: dispatch → verify → commit → next.

- **One task in flight, ever.** Task N is verified and committed green
  before N+1 dispatches, so every dispatch lands on a verified tree and a
  bug's suspect is one task's diff.
- **Review every task yourself.** Read the diff hunk by hunk against the
  task; run its Verify commands and the project suite. The dog's summary is
  a claim, not evidence — verify hardest whatever it says it could not run.
  A suspected flake gets a cause and 3 consecutive greens, not a shrug.
- **The smell rule.** Out of scope, a change beyond the task's boundary,
  the dog went wild — stop and bring the user the problem with the
  evidence; they decide. This is rare: absent a smell, run through to the
  end, or until something genuinely needs their attention.
- **An executor STOP is a plan bug found cheaply.** Diagnose against
  reality yourself, amend the plan — it stays the single source of truth —
  fold the amendment into the ledger if it touches a decision, commit the
  amendment, dispatch fresh (never resume).
- **Commit per green task**, message carrying the why. Non-git projects
  have no commit boundary: verify manually and say so plainly.

## Review on request

On the user's explicit ask — never as a standing toll — a ledger or plan
can go to codex for a cold review: read-only shape per the `codex` skill,
findings verified one by one, then triaged fold / Jupiter alignment / out
of scope. Folds land directly in the document. There are no review-ledger
files.

## Evidence and authority

- Distinguish out loud: **observed** (file:line, command output) /
  **inferred** (with the reasoning) / **unknown** (with the next probe) /
  **chosen** (the user's call). Never debate what can be measured; never
  present a guess as a fact.
- Authorization does not cascade: a ledger does not approve a plan; a plan
  does not authorize execution; the run's go-word covers per-task commits
  and nothing further — push, release, and deploy are each their own ask.
- When artifacts disagree: the user's latest explicit correction wins, then
  the ledger, then the plan. Reconcile the documents or stop for the user's
  decision — never improvise past a conflict.

At the end: what landed, changed files, verification evidence (what review
caught — the count is signal, not shame), and residual risk.
