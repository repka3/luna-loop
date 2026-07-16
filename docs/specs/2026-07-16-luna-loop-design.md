# luna-loop — Design Spec

**Goal:** A self-contained, public, cross-platform (Linux, macOS, Windows) skill
pack that encodes one development loop — interview → spec → independent review →
triage → plan → independent review → triage → dispatch → verify — for a Claude Code
driver with an OpenAI Codex CLI reviewer/executor, and serves as the sync channel
that keeps that loop identical across every machine that runs it.

**Status:** Draft, reworked after review round 1. Ledger:
`docs/specs/2026-07-16-luna-loop-design.review.md`.
Amended 2026-07-16 (owner-approved): `loop-execute` added — see Decisions.

---

## Trust Boundary / Non-Goals

*Who uses this, what it assumes, what it deliberately does not do. Review findings
outside this boundary get cut, not folded.*

**Boundary:**
- The repo is **public on GitHub**. Nothing personal, machine-identifying, or secret
  is ever committed: no private CLAUDE.md, no API keys, no per-machine facts.
  Nothing is generated into the repo, so there is nothing to gitignore;
  promptfiles and raw reviewer output live in the driver's scratchpad, outside the
  repo, always. Review ledgers are committed by design; they carry review-process data —
  findings, dispositions, round baselines, reversal counts — and never personal or
  machine-identifying data.
- The driver is Claude Code (any current Claude model); the reviewer/executor is
  Codex CLI with a high/max-capable model. The human drives phase transitions
  manually — skills fire when invoked, they do not auto-chain.
- Codex is contained by **sandbox flags for filesystem/process, never by prompt
  instructions**. Network/web is a **separate capability** with its own switch:
  live for read-only dispatches (doc-grounded reviews), `disabled` for
  workspace-write dispatches (no untrusted web content in a process that writes).
- **Codex-side ambient context is the machine owner's domain.** Codex always loads
  its global `$CODEX_HOME/AGENTS.md` and its own skills; codex-cli 0.144 has no
  per-invocation switch to suppress the global file (measured, and confirmed against
  its docs). The pack never manages, reads, replaces, or works around the user's codex
  environment. Its duty is one line of speech: the installer prints a reminder
  that the machine's AGENTS.md still applies to loop dispatches. It detects
  nothing and reads nothing in `$CODEX_HOME`. "Blind" in this document means *our
  side sends no priming* — it is a claim about the prompt, not about codex's config.
- Supported platforms: Linux (measured), macOS (expected, unverified), Windows
  **first-measured 2026-07-16** (native codex, not WSL; installer + call shapes
  work; codex sandbox enforcement recorded in `docs/notes/`). **Git Bash is a
  hard prerequisite on Windows** — the installer and call shapes are bash-only by
  design.
- Facts that cannot be verified from the authoring machine are never asserted —
  they live in Pending Measurements, owned by the machine that can measure them.

**Non-goals:**
- Not a plugin; no marketplace packaging. Clone + `install.sh` is the distribution.
- No enforcement layer: no "YOU MUST"/"1% chance" preambles, no mandatory skill-check
  gate on every message. Skills are invoked deliberately.
- No Claude-subagent execution skills (the executor is codex), and no codex-side
  skills (executor-facing content travels in prompts).
- Does not manage private standing instructions (personal CLAUDE.md), the user's
  codex configuration, or their AGENTS.md. The pack installs only into
  `$CLAUDE_CONFIG_DIR/skills/` and never writes into `$CODEX_HOME`; model and
  pricing tier are the machine owner's base-config choices, never the pack's.
- Does not automate convergence: deciding a review series is done is a human call.

---

## The Loop

```
interview ──► notes (fuzzy: roadmap / research)
    │
    ▼ (concrete enough)
  spec ──► codex review (max) ──► triage ──► fold / cut / escalate ──► ledger
    │            ▲                                    │
    │            └──── diff-only verification round ──┘
    ▼ (converged: shrinking findings, zero reversals, human calls it)
  plan ──► codex review (max) ──► triage  (same gate machinery, same ledger form)
    │
    ▼ (converged)
  dispatch to codex (high, workspace-write, web disabled) ──► verify (driver
  reruns tests, reads the diff — executor's summary is a claim, not evidence)
```

A **gate** is the checkpoint a document must pass before anything downstream is
built on it: review → triage → rework rounds repeat until the findings dry up and
the human declares convergence. A gated document is settled foundation — reopening
one is a reversal, and reversals stop the line.

**Effort rule:** **max** for the document gates (spec and plan reviews, and their
verification rounds) and for tiebreaks between conflicting positions — a flaw that
survives a document review is copied into everything built on it, and prose has no
safety net. **high** for everything else: implementation, code review, exploration,
opinions — anything whose output the driver re-verifies with diff review and tests.
When in doubt, high.

---

## Multi-Machine Model

The problem this repo actually solves: several machines each running the same loop
drift apart, because each machine's agent accumulates local memory and local fixes
that never propagate — until one machine simply "works better" than another and
nobody can say why.

- **The repo is the sync channel.** Machine-local memory is where lessons are
  *discovered*; this repo is where they are *distilled*. When practice on one
  machine beats the pack, the delta becomes a skill edit, committed, pulled
  everywhere. Skills are the shared memory; local memory is the lab bench.
- **The update path is always `git pull && ./install.sh`.** The installer is
  idempotent, non-interactive, and quiet — one status line per target; the rerun
  re-copies every skill from the clone, plugin-style. Installed skills are plain
  directories that owe nothing to the clone: delete it and they keep working —
  you only lose the update channel. Installed copies are **never hand-edited** —
  the repo is the single source of truth; edit the repo and reinstall (a stray
  hand-edit is simply overwritten by the next update, converging back to repo
  truth).
- **When two machines' verdicts diverge** for no visible reason, remember that
  each machine's own AGENTS.md and codex config color its reviews — compare those
  with their owners before blaming the model.
- **Peer review (warm), distinct from the codex gate (cold):** an agent instance on
  another machine, with different lived experience, reviews the spec and skills
  against its own memory — "what did your long autonomous sessions teach you that
  this pack is missing?" Opposite protocol from the codex gate: there, experience is
  withheld to buy independence; here, experience is the value, so priming with it is
  the point. Findings go through the same fold / cut / escalate triage.
- Peer review is a **protocol, not a skill (yet)**: run it manually on the next
  machine; distill it into a skill only if it recurs. YAGNI.

---

## Repo Layout

```
luna-loop/
├── README.md               what this is, the loop diagram, prerequisites, install,
│                           per-skill index, the AGENTS.md disclosure note
├── LICENSE                 MIT
├── install.sh              see Install section
├── skills/
│   ├── loop-interview/SKILL.md
│   ├── loop-spec/SKILL.md
│   ├── loop-plan/SKILL.md
│   ├── loop-review/SKILL.md
│   ├── loop-execute/SKILL.md
│   └── codex/SKILL.md
└── docs/
    ├── specs/               the pack's own specs (this file) + review ledgers
    ├── plans/               the pack's own plans
    └── notes/               the pack's own notes
```

Skill naming: the four phase skills carry the `loop-` prefix to avoid colliding with
Claude Code built-ins and other generic names (`review`, `plan`); `codex` keeps its
established name — where a foreign skill already occupies a target name, the
installer fails clean (see Install).

Artifact conventions, repeated inline in every skill that produces artifacts
(self-containment beats DRY at this scale): **specs → `docs/specs/`, plans →
`docs/plans/`, notes → `docs/notes/`, all prefixed `YYYY-MM-DD-HHMM-` (24-hour,
local machine time), resolved relative to the driver's project root (the session's
working directory).** The time is load-bearing: several artifacts land per day, and
the timestamp makes lexicographic order chronological — a directory listing reads
as history, even within one day. Review ledgers sit next to the document they
review and inherit its name: `<doc-basename>.review.md`. Loop verification
steps (`git diff` baselines, round diffs) require the project to be a git
repository; in a non-git directory the driver verifies manually and says so.

---

## The Six Skills

Frontmatter and invocation policy (Claude Code selects skills by `description`, so
the description *is* the trigger contract):

| skill | invocation | description says |
|---|---|---|
| `loop-interview` | may auto-match phase language | pre-spec interview; brainstorm → decisions or notes |
| `loop-spec` | may auto-match | write a spec from settled decisions |
| `loop-plan` | may auto-match | turn an approved spec into a dispatchable plan |
| `loop-review` | **explicit user request only** (dispatches cost real money) | run the independent review gate on a spec or plan |
| `loop-execute` | **explicit user go-word only** (spends money, writes files) | execute a gated plan task-by-task |
| `codex` | **explicit user request only** (side-effecting dispatch) | invoke Codex CLI: call shapes, sandbox, effort |

The three dispatch skills state their explicit-invocation policy inside their own
`description` so the driver model does not fire them speculatively.

### 1. `loop-interview` — pre-spec interview

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
- **Two exits:** concrete enough → hand to `loop-spec`. Too big or fuzzy to spec →
  write a **note**: `docs/notes/YYYY-MM-DD-HHMM-<topic>.md`, deliberately loose —
  direction statements, `[x]`/`[ ]` roadmap checkboxes, mid-interview research
  findings (alternatives, benchmarks). Notes are the undisciplined layer; no
  template beyond the filename.

### 2. `loop-spec` — write the specification

Output: `docs/specs/YYYY-MM-DD-HHMM-<topic>.md`. Template sections:

1. **Goal** — one sentence.
2. **Trust Boundary / Non-Goals** — *mandatory.* Who calls this, what input is
   trusted, which threat classes and features are explicitly out of scope. This is
   the triage yardstick and it goes in the reviewer's reading order, so findings
   arrive calibrated instead of maximal.
3. **Architecture / approach** — scaled to complexity.
4. **Requirements** — numbered, testable, exact values. No ranges standing in for
   decisions.
5. **Acceptance** — how each requirement is checked (command, observation, or
   review), so "done" is an observation, not an opinion.
6. **Decisions** — each with its *why*, so review rounds don't re-litigate them.
7. **Open questions** — must be empty before the review gate; if it isn't, go back
   to `loop-interview`. Facts that only another machine can verify go in a
   **Pending Measurements** list with a named owner instead.

Self-review before the gate (run inline, fix inline): placeholder scan ("TBD",
vague requirements), internal consistency, scope (one plan's worth?), ambiguity
(any requirement readable two ways → pick one, write it down).

### 3. `loop-plan` — write the implementation plan

**A plan is a sequence of codex dispatches.** Each task is written so it can be
extracted into a cold executor's promptfile. **Extraction contract: every dispatch
promptfile = the plan's Global Constraints header verbatim + the one task, always.**
Nothing is "implicitly included" — the executor sees exactly what is prepended.

Header: goal (one sentence), **Global Constraints** copied verbatim from the spec
(version floors, naming rules, platform requirements).

Per task:
- **Files:** exact paths — `Create:` / `Modify: path:lines` / `Test:`.
- **Interfaces:** `Consumes:` / `Produces:` with exact signatures — a cold executor
  sees only its own task; this block is how it learns what neighbors expect.
- **Contracts verbatim** — schemas, types, API shapes copied in, not referenced.
- **Verify:** exact commands with expected output.
- **STOP rule**, every task: "if this plan and reality disagree in a way this scope
  cannot absorb, stop and report instead of improvising." A stop is a plan bug
  found cheaply, not a failure.

Before the plan is gated: **pre-dispatch reality scan** — `rg` every symbol, path,
and contract the plan names against the actual codebase, so the file whitelist is
complete and stops don't happen for mapping reasons.

Hard rules:
- **No placeholders.** "TBD", "add appropriate error handling", "similar to task N"
  (repeat the content instead), steps that describe without showing — all plan
  failures.
- **Self-contained for a cold executor.** Executor-facing text (plans, promptfiles)
  carries zero skill references, zero conversation references, nothing that isn't on
  disk. `REQUIRED SUB-SKILL: <anything>` is the canonical anti-pattern. (Driver-side
  skills may reference each other — the pack installs as one unit; this rule binds
  what the *executor* sees.)
- Task granularity: the smallest unit worth a reviewer's gate — *not* 2–5-minute
  micro-steps; the executor is a capable model, not a typist.

Self-review: spec coverage (every requirement → a task), placeholder scan, interface
consistency (names/types in task N match what task M defined).

### 4. `loop-review` — the independent gate (after `loop-spec` and after `loop-plan`)

Owns **what to send and what to do with what comes back**. The mechanics of calling
codex (flags, sandbox, effort, run handling) belong to the `codex` skill — this
skill composes and triages, then dispatches *per the codex skill*.

Composing the dispatch — **blind means no out-of-band advocacy, not no context**:
- **Withhold, always:** the conversation, and any advocacy beyond the document —
  "we're confident about X", "please go easy on Y". The document itself, including
  its Decisions-with-why section, *is* the artifact under review and is always sent
  whole.
- **Provide, always:** the document, plus **every artifact it cites, depends on, or
  claims to inherit from**, listed in reading order. A cold reviewer that cannot
  read the system a document depends on will *invent that system and review its
  invention* — confidently, at max effort, formatted like a real finding. (Measured:
  a max review missing one sibling repo returned its only blocker at the wrong
  severity and a security finding the withheld context ruled out.)
- **External dependencies are always staged.** Never assume the read-only sandbox
  can read outside the worktree — where it cannot, a review does not fail, it
  silently invents the missing context. Copy external dependencies into a
  temporary `.luna-loop-staging/` directory inside the worktree, point the
  reading order there, and delete it when the round completes — then check
  `git status` so nothing staged can ever be committed. In-worktree dependencies
  are cited by path; no staging needed.
- Effort **max**. Ask for numbered findings with references and severities.

**The ledger** — every gated document gets `<doc-basename>.review.md` beside it,
committed, updated each round:
- Header: document path, reviewer identity (model/effort/sandbox), and per round a
  **git baseline ref** (the commit the round reviewed against).
- One row per finding: `id | severity | one-line | disposition (fold/cut/escalate)
  | reason or fold location`.
- Per round: counts, reversals (settled items reopened — list them or state zero),
  and the escalation outcomes.
The ledger is what makes rounds reproducible across cold sessions: finding identity,
cut reasons, and the diff baseline survive outside anyone's context window.

**Triage** — the reviewer is high-recall / low-precision by design; classification
converts noise into signal. Per finding, one line — what it costs if real — then:
- **fold** — real, inside the trust boundary → into the document.
- **cut** — technically correct, outside the stated boundary → cut list, one-line
  reason.
- **escalate** — genuinely the human's call → a short interview round, then fold or
  cut with the answer recorded.

Rounds:
- **Verification rounds are diff-only**: the reworked document, the ledger (with cut
  list), and the git baseline so the reviewer can diff the rework itself. Instruct:
  "review these fixes; do not re-litigate settled decisions or cut findings."
- **Report each round to the user and wait for their approval** before dispatching
  the next one.
- **Track reversals, not counts.** Healthy series: shrinking findings, zero reopened
  decisions. State it each round.
- **A reversal stops the loop** — bring both sides' evidence to the human.
- **Convergence is a decision, not a discovery.** The reviewer never says "done";
  the human calls it, and triage lines make that call easy.

### 5. `loop-execute` — execute the gated plan (after the plan gate)

The driver's loop over a gated plan: **dispatch → verify → commit → next.**
Fires only on the user's explicit go-word ("go", "build task 1") — execution
spends money and writes files, so a gated plan's existence is never the
trigger. A standing "keep going" authorizes the run; interrupts are reserved
for decisions that change the spec's meaning or a user-visible trade-off.

- **One task in flight, ever:** task N verified and committed green before
  task N+1 dispatches — every dispatch lands on a verified tree, and a bug
  found in verification has one task's diff as suspect, not an entangled pair.
- **Extraction:** promptfile = Global Constraints verbatim + the one task
  (consuming `loop-plan`'s contract), plus one standing instruction: run the
  task's Verify commands if the sandbox allows and report exactly what could
  not be run. Dispatch per the `codex` skill's implementation shape.
- **Driver verification is the point, not a ceremony:** read the diff hunk by
  hunk against the task's contracts, run the Verify commands and the standard
  suite yourself, verify hardest what the executor could not run. Suspected
  flakes rerun to 3 consecutive greens AND get a cause. The executor's summary
  is a claim, not evidence.
- **Commit per verified task**, message carrying the why. Non-git projects:
  no commit boundary — verify manually and say so (same stance as
  `loop-review`).
- **A STOP is a plan bug found cheaply:** diagnose against reality, amend the
  plan (it stays the executor's single source), commit the amendment,
  re-dispatch fresh. A disagreement reaching the spec's meaning goes to the
  human with both sides' evidence.

### 6. `codex` — reviewer/executor mechanics (pure)

Only what is load-bearing for *calling* codex:

- **Sandbox table:** review / opinion / exploration → `--sandbox read-only`;
  implementation of an agreed plan → `--sandbox workspace-write`. The sandbox flag
  is the only filesystem/process containment. Never
  `--dangerously-bypass-approvals-and-sandbox`.
- **Web capability:** read-only dispatches pin `-c 'web_search="live"'`;
  **implementation dispatches pin `-c 'web_search="disabled"'`** (verified: the
  config enum is `disabled|cached|indexed|live`; a disabled session reports no web
  tool). No untrusted web content in a process that writes files.
- **No profile — everything semantic rides the command line.** The loop pins what
  defines its behavior (sandbox, effort, web, approvals) explicitly on every call;
  what it deliberately does **not** pin — model, pricing tier — inherits the
  machine's own base config, because those are the owner's cost choices, not the
  pack's. Measured: `-c` overrides beat base-config defaults (a base defaulting to
  max ran at the pinned effort), and headless `exec` runs without any approval
  knob — the shapes pin `approval_policy="never"` anyway so behavior never depends
  on a machine's defaults.
- **The three call shapes** (all flags mandatory, every call):
  1. *Document review:* `codex exec --sandbox read-only --strict-config
     --skip-git-repo-check -c model_reasoning_effort=max -c 'web_search="live"'
     -c approval_policy="never" "$(cat promptfile)" </dev/null`
  2. *Opinion / exploration:* same shape with `-c model_reasoning_effort=high`.
  3. *Implementation:* `codex exec --sandbox workspace-write --strict-config
     --skip-git-repo-check -c model_reasoning_effort=high
     -c 'web_search="disabled"' -c approval_policy="never"
     "$(cat promptfile)" </dev/null`
- **Why each flag:** explicit effort because a base config may carry an expensive
  default (the origin machine's defaulted to max — silent money);
  `--strict-config` so a typo'd override fails loudly instead of silently running
  wrong; `--skip-git-repo-check` to run outside git repos; `</dev/null` because
  codex waits on non-tty stdin and hangs without it. Long prompts (measured
  threshold ≈6k chars on the origin machine) must be file-backed via `"$(cat
  promptfile)"` — inline they truncate with phantom quoting errors.
- **Effort table:** max = document gates and tiebreaks; high =
  everything the driver re-verifies. Never pay max for work a test suite re-reviews
  for free.
- **Never resume a session** (`codex exec resume` is never used). Cold start is a
  property of how we call it; a resumed reviewer defends its prior findings, and an
  executor's real state is on disk. Replacement: fresh, blind, narrowly scoped
  dispatch.
- **Run handling:** long dispatches run in background — no polling; capture the
  final message with `-o <file>`; glance at the banner (`reasoning effort`,
  `sandbox`) on max dispatches; when raw output would be long, run the dispatch
  inside a subagent so it never enters the driver's context. Report a distilled
  summary. For implementation runs the driver **reads the diff and runs the tests
  itself** before reporting done — the executor's summary is a claim, not evidence.
- **Ambient context disclosure:** codex loads the machine's global AGENTS.md and its
  own skills on every call; there is no per-invocation off switch (measured on
  0.144). The skill states this plainly: the owner's config, the owner's rules.
- **No hardcoded machine facts.** Origin-machine measurements are labeled as
  such; when reality disagrees with one, re-measure it.

---

## Install

`install.sh` — bash, idempotent, no root/admin, one script for all platforms (on
Windows: Git Bash, a declared prerequisite). Honors `CLAUDE_CONFIG_DIR` (default
`~/.claude`). It makes **no network calls and runs no codex commands**: it checks
that `codex` resolves on PATH (missing → clear message, exit 2, game over), then
copies six folders.

**Ownership and conflicts.** The installer manages **six targets** under one
rule: the six skill directories are **copied, plugin-style**, into
`$CLAUDE_CONFIG_DIR/skills/<name>`. It never reads or writes `$CODEX_HOME` —
codex configuration is entirely the machine owner's. Ownership travels with the
artifact: a successful install drops a `.luna-loop` marker file inside the
copied directory, **last, as a receipt** — so a half-finished copy from a failed
run reads as foreign and conflicts loudly instead of being silently trusted.
A target is pack-owned iff it is a plain directory carrying the marker; owned
targets are deleted and re-copied on every rerun (idempotent by outcome).
Anything else at a target path — foreign dir, file, any symlink — is a
**conflict, and conflicts fail clean**: the installer pre-flights every target
before touching anything; on any conflict it installs **nothing**, prints
exactly which paths conflict and what they are, and exits non-zero. The user
resolves it manually (their files, their call) and reruns. The installer never
moves, renames, backs up, or deletes files it does not own, and it **never
prompts — there is no interactive path**. Installed copies are never
hand-edited; the repo is the source of truth.

Steps:
1. **Environment gates — fail loud and early, create nothing.** `codex` must
   resolve on PATH; the Claude config directory must already exist (Claude
   Code creates it — its absence means this machine isn't ready or the path is
   wrong) and must be absolute. Any gate failure → one clear message, exit 2.
   No other codex interaction of any kind.
2. **Pre-flight.** Check all six targets; on any conflict, report and exit 1
   before touching anything.
3. **Install.** Per target: remove the owned copy — **never recursively**:
   delete exactly the two files the pack writes (`SKILL.md`, the marker), then
   `rmdir`, which refuses a non-empty directory, so anything the user put
   inside survives and the target reports `failed` instead. Then `cp -R` fresh
   from the clone, validate `SKILL.md` is readable at the destination, then
   drop the marker. A failed copy is cleaned the same non-recursive way and
   reported (`failed` line, final exit 2).
4. **Report.** One status line per target, then the plain-speech line:
   *"Of course, codex dispatches follow your machine's own AGENTS.md and codex
   config — your rules, not this pack's."*

No uninstall script: delete the six folders, done. No state files: the repo
generates nothing, tracks nothing, and can itself be deleted after installing —
it is only needed again to update.

---

## Requirements & Acceptance

| # | Requirement | Acceptance check |
|---|---|---|
| R1 | Fresh Linux install: six skills resolve | run `install.sh` on a clean `$CLAUDE_CONFIG_DIR`; new Claude session lists all six skills |
| R2 | Idempotent rerun: converges to repo state, prompts nothing | run twice; second run re-copies, prints one line per target, exits 0 |
| R3 | Conflicts fail clean: foreign target → nothing installed, conflict named, exit non-zero | seed a fake `$CLAUDE_CONFIG_DIR/skills/codex`; install touches nothing, names the path, exits 1; remove it → rerun installs |
| R4 | Installed skills are self-contained plain directories | delete the clone; installed skills keep working; re-clone restores the update channel |
| R5 | codex missing → game over: clear message, exit 2, nothing installed | run with a PATH that lacks codex; message printed, exit 2, no targets created |
| R6 | Post-install output includes AGENTS.md reminder and copy-mode warning when applicable | inspect output in both modes |
| R7 | Review ledger round-trips across cold sessions | a verification round dispatched from a fresh session using the ledger, the git baseline, and the standard reading-order inputs — no conversational context |
| R8 | Implementation shape is web-dark and workspace-confined | dispatch echoes `web_search="disabled"`, banner shows `workspace-write`; canary run reports no web tool |
| R9 | OS matrix honest: Linux measured, macOS expected, Windows provisional | README states it; Windows flips only after peer-round measurements |
| R10 | Public hygiene: no personal/machine data committed, nothing generated into the repo | repo scan finds no personal data; install leaves the clone untouched |

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
- **Ambient codex context: disclose, never manage** — no supported per-invocation
  switch exists (measured), and forking the user's codex environment (parallel
  `CODEX_HOME`, override files) is a system hack that silently diverges under
  updates. The user's machine is the user's domain; the pack detects, records, and
  reminds. Ruled by the owner.
- **Web disabled on write dispatches, live on read-only** — untrusted web content
  must not steer a process with write access; reviews keep live web because
  doc-grounded findings are worth it and the sandbox confines reads. Key and effect
  measured. Ruled by the owner.
- **Update path = `git pull && ./install.sh`, always** — one habit covers link
  refresh and copy refresh; the installer being idempotent makes the habit free.
- **Conflicts fail clean; the installer never touches files it does not own** — a
  foreign same-name target aborts the whole install with an explanation, and
  migration is the user's manual act. Moving or backing up a user's in-use skill to
  take its name is a behavior change they never asked for. (Ruled by the owner;
  supersedes an interim backup-and-adopt design.)
- **No shipped codex profile — semantics on the command line, preferences in the
  user's base config** (owner-initiated reversal of the earlier six-target
  decision, same day, recorded in the ledger). The profile pinned two different
  kinds of settings: loop semantics (effort, web, approvals) — now explicit on
  every call shape — and personal cost preferences (model, pricing tier), which a
  public pack must not impose and which now correctly inherit each machine's own
  base config. Dropping it means the pack never writes into `$CODEX_HOME` at all,
  the installer shrinks to five targets of one kind, and the entire
  profile-divergence problem class (three review findings and one design debate)
  ceases to exist. Measured before ruling: `-c` overrides beat base-config
  defaults; headless `exec` needs no approval knob (shapes pin it anyway).
- **Plugin-style copies, no links, no state** (owner-initiated reversal of the
  symlink design): under the unconditional `git pull && ./install.sh` habit,
  symlinks' one advantage (pull-only updates) is redundant, while their costs
  were real — a junction fallback with Windows-only code, a Developer Mode
  question, an ownership registry (`MACHINE.md`), and a Claude version floor
  for symlinked skills that plain directories don't have. Copies are what every
  plugin manager ships; ownership travels as a marker file inside the copy; the
  clone becomes a pure delivery medium the user may even delete. Hand-edits to
  installed copies are overwritten by the next update — repo truth wins
  structurally.
- **Repo as sync channel, local memory as lab bench** — distilled lessons travel as
  skill edits via git. This is the fix for "one machine works better than another."
- **Peer review stays a protocol, not a skill, until it recurs** — YAGNI.
- **`loop-` prefix on phase skills** — avoids collisions with built-ins and generic
  names; `codex` keeps its established name.
- **KISS purge of the installer** (owner-initiated reversal): no probes, no
  login checks, no ambient detection — the installer runs no codex commands and
  reads nothing outside this repo and the skills dir. Rationale: broken tools
  fail loudly at first use and need no advance scouts; and a public installer
  that touches another tool's credentials file — even a bare existence check —
  reads as a scam in a screenshot, because trust is about what is touched, not
  what is done with it. The one silent-failure risk (confined sandbox reads →
  invented review context) is closed structurally instead of by measurement:
  `loop-review` always stages external dependencies. Ruled by the owner.
- **MIT license** — public utility pack, no reason for anything heavier.
- **`loop-execute` added — the execution phase gets an owner (2026-07-16,
  owner-approved after the pack's first field week).** The pack described how
  to write specs and plans, gate them, and make one codex call — but not the
  driver's loop that runs a gated plan, which is where the origin project's
  field week put every real executor bug. The content is small and partly
  restates neighbors (extraction from `loop-plan`, diff-reading from `codex`);
  the skill exists for its **trigger**: the user's go-word ("go", "build it")
  matches no other skill's description, and a driver with no matching skill
  improvises exactly this phase. Fires only on that go-word — execution spends
  money and writes files, so a gated plan's existence is never sufficient.
  New rules it owns: one task in flight (commit green before the next
  dispatch), the STOP procedure (diagnose → amend plan → commit → re-dispatch
  fresh), flake discipline (3 consecutive greens AND a cause), and
  verify-hardest-what-the-executor-could-not-run.

## Open Questions

None. (Gate rule: this section must be empty before dispatching review.)

## Pending Measurements (not open decisions)

Decisions above are made; these facts must be measured on the machine that can
measure them, and folded back here only if they invalidate a decision.

Windows machine (peer-review round) — **MEASURED 2026-07-16**; full method and
results in `docs/notes/2026-07-16-2309-windows-codex-sandbox-delete-measurement.md`:
- codex runs **native** on Windows (not WSL); `$CODEX_HOME`→`~/.codex` and
  `$CLAUDE_CONFIG_DIR`→`~/.claude` both resolve under `%USERPROFILE%`.
- Sandbox enforcement: blocks writes, does **not** block deletes (the Windows
  restricted-token gates write access, not the DELETE right). Under `read-only`,
  destructive commands are stopped by codex's command classifier — deterministic
  but shape-based, so an obfuscated command bypasses it and deletes via the OS
  gap. This is delete-only, Windows-only, and reachable only by a deliberately
  evasive command from hostile input; it does **not** affect normal loop use.
  Re-measure — actively patched upstream (PR openai/codex#31138 merged
  2026-07-08). Windows dispatches stay `read-only` + trusted-content-only.

Measured on the origin machine (2026-07-15/16), recorded for transparency: codex-cli
0.144.4; `web_search` enum `disabled|cached|indexed|live` and `disabled` verified
web-dark; `project_doc_max_bytes=0` does not suppress the global AGENTS.md; no
per-invocation global-AGENTS.md switch exists; read-only sandbox reads outside the
worktree on this platform; profile-less calls with explicit `-c` overrides beat
base-config defaults (a base defaulting to effort max ran at the pinned level);
headless `exec` completes without any approval setting.
