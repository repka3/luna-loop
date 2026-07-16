# luna-loop — Design Spec

**Goal:** A self-contained, public, portable skill pack that encodes one development
loop — interview → spec → independent review → triage → plan → independent review →
triage → dispatch → verify — for a Claude Code driver with an OpenAI Codex CLI
reviewer/executor.

**Status:** Draft, pre-review. This spec is the pack's first artifact and follows its
own template.

---

## Trust Boundary / Non-Goals

*Who uses this, what it assumes, what it deliberately does not do. Review findings
outside this boundary get cut, not folded.*

**Boundary:**
- The repo is **public on GitHub**. Nothing personal, machine-identifying, or secret
  is ever committed: no private CLAUDE.md, no API keys, no absolute paths tied to one
  machine, no verified-machine-facts files (those are generated locally, gitignored).
- The driver is Claude Code (any current Claude model); the reviewer/executor is
  Codex CLI with a high/max-capable model. The human drives phase transitions
  manually — skills fire when invoked, they do not auto-chain.
- Codex is treated as **contained by sandbox flags, never by prompt instructions**.
  Prompt-level "don't do X" lines are not relied on for anything.

**Non-goals:**
- Not a plugin; no marketplace packaging. Clone + `install.sh` is the distribution.
- No enforcement layer: no "YOU MUST"/"1% chance" preambles, no mandatory skill-check
  gate on every message. Skills are invoked deliberately by the human or when a phase
  plainly matches.
- No Claude-subagent execution skills (the executor is codex), and no codex-side
  skills (codex receives everything through self-contained prompts).
- Does not manage private standing instructions (personal CLAUDE.md) or their
  portability. Skills are self-contained precisely so the pack works without them.
- Does not automate convergence: deciding a review series is done is always a human
  call.

---

## The Loop

```
interview ──► notes (fuzzy: roadmap / research)
    │
    ▼ (concrete enough)
  spec ──► codex review (max) ──► triage ──► fold / cut / escalate
    │            ▲                                    │
    │            └──── diff-only verification round ──┘
    ▼ (converged: shrinking findings, zero reversals, human calls it)
  plan ──► codex review (max) ──► triage  (same gate machinery)
    │
    ▼ (converged)
  dispatch to codex (high, workspace-write) ──► verify (driver reruns
  tests, reads the diff — executor's summary is a claim, not evidence)
```

Effort economics, carried from measured practice: **max** for spec/plan reviews
(a flaw that survives a document review is copied into everything built on it) and
for tiebreaks; **high** for implementation, code review, exploration (code has a
safety net — tests and diff review; prose has none).

---

## Repo Layout

```
luna-loop/
├── README.md               what this is, the loop diagram, install, per-skill index
├── LICENSE                 MIT
├── install.sh              see Install section
├── .gitignore              MACHINE.md, local artifacts
├── skills/
│   ├── interview/SKILL.md
│   ├── spec/SKILL.md
│   ├── plan/SKILL.md
│   ├── review/SKILL.md
│   └── codex/SKILL.md
├── codex/
│   └── sol-high-fast.config.toml    reviewer/executor profile (no secrets)
└── docs/
    ├── specs/               the pack's own specs (this file)
    ├── plans/               the pack's own plans
    └── notes/               the pack's own notes
```

Every skill that produces artifacts repeats the same one-line convention rather than
referencing a shared doc (self-containment beats DRY at this scale):
**specs → `docs/specs/`, plans → `docs/plans/`, notes → `docs/notes/`, all prefixed
`YYYY-MM-DD-`.**

---

## The Five Skills

### 1. `interview` — pre-spec interview

Turns an idea into either a spec-ready decision set or a note. Core rules, inline:

- **One decision per message.** Every fact in the message serves that one decision.
- **An option is a claim.** Never offer an option a fact would collapse — read the
  source, count the bytes, do the arithmetic first, and bring the settled answer
  instead of the menu. The recommended option carries the *highest* verification
  bar, not the lowest, because recommendations anchor.
- **Settle implementation details yourself and say so**; bring the user only
  decisions that are genuinely theirs.
- Scope check first: if the request spans multiple independent subsystems, decompose
  before refining details.
- **Two exits:** concrete enough → hand to `spec`. Too big or fuzzy to spec → write a
  **note**: `docs/notes/YYYY-MM-DD-<topic>.md`, deliberately loose — direction
  statements, `[x]`/`[ ]` roadmap checkboxes, mid-interview research findings
  (alternatives, benchmarks). Notes are the undisciplined layer; no template beyond
  the filename.

### 2. `spec` — write the specification

Output: `docs/specs/YYYY-MM-DD-<topic>.md`. Template sections:

1. **Goal** — one sentence.
2. **Trust Boundary / Non-Goals** — *mandatory.* Who calls this, what input is
   trusted, which threat classes and features are explicitly out of scope. This is
   the triage yardstick and it goes in the reviewer's reading order, so findings
   arrive calibrated instead of maximal.
3. **Architecture / approach** — scaled to complexity.
4. **Requirements** — exact values, no ranges-standing-in-for-decisions.
5. **Decisions** — each with its *why*, so review rounds don't re-litigate them.
6. **Open questions** — must be empty before the review gate; if it isn't, go back
   to `interview`.

Self-review before the gate (run inline, fix inline): placeholder scan ("TBD",
vague requirements), internal consistency, scope (one plan's worth?), ambiguity
(any requirement readable two ways → pick one, write it down).

### 3. `plan` — write the implementation plan

**A plan is a sequence of codex dispatches.** Each task is written so it can be
extracted nearly verbatim into a cold executor's promptfile. No translation step.

Header: goal (one sentence), **Global Constraints** copied verbatim from the spec
(version floors, naming rules, platform requirements — every task implicitly
includes them).

Per task:
- **Files:** exact paths — `Create:` / `Modify: path:lines` / `Test:`.
- **Interfaces:** `Consumes:` / `Produces:` with exact signatures — a cold executor
  sees only its own task; this block is how it learns what neighbors expect.
- **Contracts verbatim** — schemas, types, API shapes copied in, not referenced.
- **Verify:** exact commands with expected output.
- **STOP rule**, every task: "if this plan and reality disagree in a way this scope
  cannot absorb, stop and report instead of improvising." A stop is a plan bug
  found cheaply, not a failure.

Hard rules:
- **No placeholders.** "TBD", "add appropriate error handling", "similar to task N"
  (repeat the content instead), steps that describe without showing — all plan
  failures.
- **Self-contained for a cold executor.** Zero skill references, zero conversation
  references, nothing that isn't on disk. `REQUIRED SUB-SKILL: <anything>` is the
  canonical anti-pattern: an instruction the executor can't follow pointing at a
  system it can't see.
- Task granularity: the smallest unit worth a reviewer's gate — *not* 2–5-minute
  micro-steps; the executor is a capable model, not a typist.

Self-review: spec coverage (every requirement → a task), placeholder scan, interface
consistency (names/types in task N match what task M defined).

### 4. `review` — the independent gate (used after `spec` and after `plan`)

Composing the dispatch — **blind means no priming, not no context**:
- **Withhold, always:** the conversation, the reasoning, "we decided X because Y",
  which parts we think are solid. Priming buys agreement; independence is the value.
- **Provide, always:** the document, plus **every artifact it cites, depends on, or
  claims to inherit from**, listed in reading order. A cold reviewer that can't read
  the system a document depends on will *invent that system and review its
  invention* — confidently, at max effort, formatted like a real finding. (Measured:
  a max review missing one sibling repo returned its only blocker at the wrong
  severity and a security finding the withheld context ruled out.)
- Effort **max** for spec/plan reviews. Ask for numbered findings with references.

**Triage** — the reviewer is high-recall / low-precision by design; classification
converts noise into signal. Per finding, one line — what it costs if real — then:
- **fold** — real, inside the trust boundary → into the document.
- **cut** — technically correct, outside the stated boundary → recorded with a
  one-line reason in a cut list.
- **escalate** — genuinely the human's call → a short interview round, then fold or
  cut with the answer recorded.

Rounds:
- **Verification rounds are diff-only**: reworked document + the specific findings +
  the cut list + "review these fixes; do not re-litigate settled decisions or cut
  findings."
- **Track reversals, not counts.** Healthy series: shrinking findings, zero reopened
  decisions. State it each round.
- **A reversal stops the loop** — bring both sides' evidence to the human.
- **Convergence is a decision, not a discovery.** The reviewer never says "done";
  the human calls it, and triage lines make that call easy.

### 5. `codex` — executor/reviewer mechanics (pure)

Shrunk from the current working version to only what is load-bearing:
- **Sandbox table:** review/explore → `read-only`; implementation of an agreed plan
  → `workspace-write`. The sandbox flag is the *only* containment. Never
  `--dangerously-bypass-approvals-and-sandbox`.
- **The three call shapes** (review-max, opinion-high, implement-high) with exact
  flags: `--profile` mandatory on every call (the base config's silent-max default
  is a cost bug), `--strict-config` (typo'd overrides fail loudly),
  `--skip-git-repo-check`, `</dev/null` (hangs on non-tty stdin without it),
  promptfile via `"$(cat file)"` above ~6k chars.
- **Effort table** (max: document reviews, tiebreaks; high: everything with a test
  suite under it).
- **Never resume a session.** Cold start is a property of how we call it, not of the
  tool; a resumed reviewer defends its prior findings. Replacement: fresh, blind,
  narrowly scoped dispatch.
- Long runs in background; the driver reads the diff and runs the tests itself
  before reporting done.
- **No hardcoded machine facts.** A "verify on a new machine" checklist replaces
  them; results land in `MACHINE.md` (gitignored), written by `install.sh`.

Everything else in the current codex skill (blind-dispatch composition, triage,
round discipline) moves to `review`, where it fires when it's needed.

---

## Install

`install.sh`, idempotent, no root:
1. Symlink each `skills/<name>` into `~/.claude/skills/<name>` (skill updates ride
   `git pull`). Refuse to clobber a non-symlink existing dir; say so and skip.
2. Copy `codex/sol-high-fast.config.toml` to `~/.codex/` if absent; if present and
   different, show a diff and ask.
3. Verify: codex binary on PATH, version, login state, profile resolves
   (`codex exec --profile sol-high-fast` dry probe). Write results to `MACHINE.md`
   at the repo root (gitignored).
4. Print what was linked, copied, verified, skipped.

No uninstall script needed: remove the symlinks, done.

---

## Decisions (and why)

- **Public repo, skills self-contained, private CLAUDE.md excluded** — publishing
  forces the discipline inline into each skill, which is also what makes the pack
  usable by others. Cost accepted: the pack does not port always-on personal
  standing rules; that is a dotfiles problem, out of scope.
- **Executor is codex, not Claude subagents** — an independent second model family
  is a stronger adversary than a same-model subagent; independence is the value.
- **Plan format = dispatch anatomy** — eliminates the translation step between
  planning and execution, and makes "self-contained for a cold executor" structural
  instead of aspirational.
- **Triage as a named step** — the reviewer at max is deliberately over-sensitive;
  without fold/cut/escalate against a written trust boundary, technically-correct
  noise gets folded into specs (observed: injection-hardening findings against a
  private single-caller service).
- **Trust boundary section is mandatory in every spec** — it is both the triage
  yardstick and reviewer calibration, generalizing a measured failure (withheld
  context → invented system → wrong-severity blocker).
- **MIT license** — public utility pack, no reason for anything heavier.

## Open Questions

None. (Gate rule: this section must be empty before dispatching review.)
