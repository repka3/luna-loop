---
name: luna-loop
description: "Adaptive entry to the Luna Loop with Claude driving: interview discipline, lightest-adequate-route selection, evidence rules, non-cascading authorization. Use when the user invokes the loop, says Luna Loop, or asks for the loop workflow. Invocation alone never authorizes implementation."
---

# luna-loop — the adaptive entry

One workflow, no mandatory phases. Every control below exists to stop a real
failure mode; apply the ones the work in front of you actually needs, and
never produce a note, spec, plan, review, or dispatch merely because another
one occurred. Skipping a document never permits skipping the reasoning it
would have protected.

## Enter deliberately

Read the request, repository guidance, existing artifacts, and enough code to
assess the work. Stay read-only while choosing a route.

When the user already picked a route, follow it. Otherwise recommend the
lightest adequate route with a concrete reason and ask for confirmation
before creating workflow artifacts.

Route confirmation authorizes the agreed artifacts. It never authorizes
implementation — that takes an explicit go-word ("go", "build it") after the
scope is settled. Tentative language — "I think", "maybe", "what if",
"probably" — is discussion: investigate, challenge, recommend; do not mutate
while the user is considering an idea.

## The routes

    small, settled, and local            → implement directly, verify
    settled, needs durable sequencing    → plan → dispatch → verify
    decisions unsettled                  → interview → one of the above
    multiple compliant designs remain    → interview → spec → plan → …
    hard system work                     → interview → spec → gate → plan
                                              → gate → dispatch → verify

These are examples, not phases. Increase rigor with uncertainty, blast
radius, irreversibility, cost, security exposure, and the number of people
affected.

The execution line: work that needs no plan, the driver implements and
verifies in place. Work that earns a plan is dispatched cold per
`loop-execute` — the plan format exists to be extracted, and the cold
executor's STOP rule is part of what a plan buys.

A document is settled when the user says so. A blind review round
(`loop-review`) is how to buy independent scrutiny for that call when the
stakes justify its cost — never a mandatory toll, and a clean review is
never the convergence condition.

Controls and their owners:

- **interview** — this skill, below: unsettled decisions.
- **note** — `docs/notes/YYYY-MM-DD-HHMM-<topic>.md`: too fuzzy to spec, or
  durable research evidence.
- **spec** — `loop-spec`: materially different behaviors could all comply
  with what is settled, or a gate needs a Trust Boundary to triage against.
- **plan** — `loop-plan`: execution will be dispatched cold, or sequencing
  needs durable precision.
- **gate** — `loop-review`: independent blind review; billable, explicit
  user request only.
- **execution** — `loop-execute`: a settled plan, on the user's go-word.
- **mechanics** — `codex`: how to call the other model safely and cheaply.

## The interview

A dialogue, not a questionnaire.

- **One decision per message.** Every fact in the message earns its place by
  serving that one decision. What overwhelms people is never fact density —
  it is unfocused scope.
- **An option is a claim.** Never offer an option that ten seconds of
  checking would collapse — read the source, count the bytes, run the probe
  first, and bring the settled answer instead of the menu. The option you
  recommend carries the *highest* verification bar, not the lowest:
  recommendations anchor, so an unchecked recommendation is worse than an
  unchecked option.
- **If it exists, it has receipts.** When the idea concerns the behavior of
  anything that already runs — your system or a dependency — claims get
  receipts (file:line, probe output) before decisions build on them; when
  the work starts from a symptom, the symptom becomes a number first. In a
  greenfield this rule simply never fires.
- **Settle implementation details yourself and say so.** Bring the user only
  decisions that are genuinely theirs; report the ones you settled in
  passing so they can veto.
- **Scope check first.** If the request spans multiple independent
  subsystems, decompose before refining details — don't spend questions
  polishing a corner of something that needs splitting.

Two exits: spec-ready decisions go to `loop-spec`; too big or fuzzy to spec
becomes a note — direction statements, `[x]`/`[ ]` roadmap checkboxes for
goals too fuzzy to spec, research findings gathered mid-interview. No
template beyond the timestamped filename.

## Evidence

Do not debate a fact that can be measured. Distinguish, out loud:

- **observed** — cited file:line, command output, test, log, measurement;
- **inferred** — concluded from observations, with the reasoning stated;
- **unknown** — not established, with the next probe named;
- **chosen** — an owner decision evidence alone cannot settle.

Resolve discoverable engineering facts before asking the user. When a probe
needs credentials, new tooling, cost, external access, or any mutation
beyond current authority, propose the exact probe and wait. A decision that
cannot wait for evidence gets a labeled assumption, the safest reversible
choice, and the observation that will confirm or reopen it — never a guess
dressed as fact.

## Direct work stays disciplined

Before implementing directly, all of these hold:

- the exact intended change and its boundary, with explicit non-goals;
- no unresolved decision that could materially change the result;
- verification that would actually expose a wrong implementation;
- explicit authorization to modify the project.

If one is materially unclear, stop and recommend the lightest missing
control. Never silently turn a local request into a new subsystem,
dependency, storage model, public interface, or migration — report the
evidence, offer the smallest viable routes, and wait for the owner's pick.

Authorization does not cascade:

1. a hypothesis does not settle a decision;
2. a settled decision does not approve a spec or plan;
3. a spec or plan does not authorize implementation;
4. implementation authorization does not authorize a commit;
5. commit authorization does not authorize a push;
6. a push does not authorize a build, publication, release, or deployment.

One instruction may authorize several steps only when it names them and
their material targets. Otherwise stop at the last authorized boundary —
silence is not approval. Focused tests and project builds needed to verify
an authorized change stay in scope.

## Authority and finish

When artifacts disagree, this order wins: the user's latest explicit
correction, then the settled spec, then the plan, then notes and review
ledgers. Reconcile the durable artifacts or stop for an owner decision —
never improvise past a material conflict.

At completion, report the result, changed files, verification evidence, and
residual risk. No ceremonial final pass is mandatory.
