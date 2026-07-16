# luna-loop Implementation Plan

**Goal:** Implement the luna-loop pack — five skills, one installer, README,
license, gitignore — exactly as specified by the gated spec.

Rework history: revision 2 after gate-2 round 1 (13 findings, all folded);
revision 3 after the owner-initiated profile reversal — no shipped codex
profile, five targets, semantics pinned per call shape; revision 4 after the
owner-initiated KISS purge — the installer runs no codex commands, makes no
network calls, and reads nothing outside this repo and the skills dir;
revision 5 after the owner-initiated plugin-style reversal — plain copies with
an in-dir `.luna-loop` marker, no symlinks, no `MACHINE.md`, no `.gitignore`
(see `2026-07-16-1415-luna-loop-implementation.review.md`).

---

## Global Constraints

*(Every dispatch promptfile = this entire section verbatim + the one task.)*

- **Authority:** the gated spec at `docs/specs/2026-07-16-luna-loop-design.md`
  (gated at commit `406551a`) governs; where this plan compresses it, the spec
  wins. Read the spec sections a task names before writing.
- **Dispatch settings (every task):** sandbox `workspace-write`, reasoning
  effort high, `-c 'web_search="disabled"'`, `-c approval_policy="never"`.
  Working root = the repo root: the directory containing this plan's
  `docs/plans/`.
- This repo is **public**. Nothing personal, machine-identifying, or secret in
  any committed file: no absolute home paths, no hostnames, no email addresses.
  Nothing is generated into the repo — no gitignore needed.
- All shell code is **bash** (Git Bash compatible on Windows): no root/admin,
  no GNU-only flags without a portable fallback, **no interactive prompts
  anywhere** — there is no interactive path.
- Config root: `CLAUDE_CONFIG_DIR` (default `~/.claude`), always via
  `${VAR:-default}`. The installer never reads or writes `$CODEX_HOME`.
- **Five install targets, one rule** — the five skill dirs
  `skills/loop-interview`, `skills/loop-spec`, `skills/loop-plan`,
  `skills/loop-review`, `skills/codex` → `$CLAUDE_CONFIG_DIR/skills/<name>`.
  The pack never writes into `$CODEX_HOME`.
- Codex CLI version floor: **0.144**.
- Artifact naming everywhere it is mentioned: `YYYY-MM-DD-HHMM-<topic>.md`
  (24-hour, local machine time), under `docs/specs/`, `docs/plans/`,
  `docs/notes/` relative to the driver's project root. Skills `mkdir -p` the
  target directory before writing — user projects will not have it.
- License: MIT.
- **Skill frontmatter, verbatim.** Each SKILL.md begins with exactly (values
  double-quoted; line 2 is `name:`, line 3 is `description:`):

  | name | description (the full double-quoted value) |
  |---|---|
  | loop-interview | "Pre-spec interview: turn an idea into settled decisions or a loose note. One decision per message; verify options before offering them. Use when brainstorming or shaping work that is not yet a spec." |
  | loop-spec | "Write a specification from settled decisions: goal, trust boundary and non-goals, numbered requirements with acceptance checks, decisions with their why. Use when an interview has produced spec-ready decisions." |
  | loop-plan | "Turn a gated spec into an implementation plan whose tasks are cold-executor dispatches: exact files, interfaces, contracts verbatim, verify commands, STOP rule. Use after a spec has passed its review gate." |
  | loop-review | "Run the independent review gate on a spec or plan: compose a blind codex dispatch, triage findings fold/cut/escalate, keep the review ledger, run diff-only rounds. Dispatches cost real money — invoke only on explicit user request." |
  | codex | "Invoke Codex CLI as reviewer or executor: sandbox table, three call shapes, effort economics, never resume, run handling. Side-effecting and billable — invoke only on explicit user request or when another luna-loop skill directs a dispatch." |

- **STOP rule (applies to every task):** if this plan and reality disagree in a
  way this task's scope cannot absorb, stop and report the disagreement instead
  of improvising. A stop is a plan bug found cheaply, not a failure.

---

## Task 1: `skills/codex/SKILL.md`

**Files:**
- Create: `skills/codex/SKILL.md`

**Interfaces:**
- Produces: the call shapes and effort table that `loop-review` and `loop-plan`
  reference by the phrase "dispatch per the codex skill".
- Consumes: frontmatter row `codex` (Global Constraints).

**Contracts:** distill spec §"5. `codex`" (read it in full) into a skill of
mechanics only. Required content, all of it:
- Sandbox table (review/opinion/explore → `read-only`; implementation of an
  agreed plan → `workspace-write`); the sandbox flag is the only
  filesystem/process containment; never
  `--dangerously-bypass-approvals-and-sandbox`.
- The three call shapes verbatim from the spec, including
  `-c 'web_search="disabled"'` on the implementation shape and the note that
  the config enum is `disabled|cached|indexed|live`.
- Why each flag exists (explicit effort vs silent expensive base-config
  defaults, strict-config fails loudly, skip-git-repo-check, `</dev/null`
  hang, file-backed prompts over ~6k chars — labeled as an origin-machine
  measurement). Every shape pins `-c approval_policy="never"`; the skill says
  plainly that model and pricing tier deliberately inherit the machine's own
  base config — the owner's cost choices, never the pack's.
- Effort table: max = document gates and tiebreaks; high = everything the
  driver re-verifies; never max for work a test suite re-reviews free.
- Never resume a session — and why (anchored reviewer; executor state is on
  disk); replacement is a fresh, blind, narrowly scoped dispatch.
- Run handling: background for long runs, `-o <file>` capture, banner glance
  (`reasoning effort`, `sandbox`) on max dispatches, subagent isolation for
  long output, distilled reporting; for implementation runs the driver reads
  the diff and runs the tests itself. Promptfiles and raw reviewer output live
  in the driver's scratchpad, outside the repo — never as project files.
- Ambient disclosure: codex loads the machine's global AGENTS.md and its own
  skills on every call; no per-invocation off switch (measured on 0.144);
  the owner's config, the owner's rules — the pack neither reads nor manages it.
- Zero hardcoded machine facts; origin-machine measurements labeled as such.

**Verify (all must pass):**
```bash
sed -n '2p' skills/codex/SKILL.md | grep -qxF 'name: codex'
sed -n '3p' skills/codex/SKILL.md | grep -qxF 'description: "Invoke Codex CLI as reviewer or executor: sandbox table, three call shapes, effort economics, never resume, run handling. Side-effecting and billable — invoke only on explicit user request or when another luna-loop skill directs a dispatch."'
grep -q 'web_search="disabled"' skills/codex/SKILL.md
grep -q 'web_search="live"' skills/codex/SKILL.md
grep -q 'model_reasoning_effort=max' skills/codex/SKILL.md
grep -q 'model_reasoning_effort=high' skills/codex/SKILL.md
grep -q 'approval_policy="never"' skills/codex/SKILL.md
grep -qi 'never resume' skills/codex/SKILL.md
! grep -rn '/home/' skills/codex/SKILL.md
```

**STOP rule:** as in Global Constraints.

---

## Task 2: `skills/loop-review/SKILL.md`

**Files:**
- Create: `skills/loop-review/SKILL.md`

**Interfaces:**
- Consumes: "dispatch per the codex skill" (call mechanics live there, not
  here).
- Produces: the ledger schema that future reviews of any document follow.

**Contracts:** distill spec §"4. `loop-review`" (read it in full). Required
content, all of it:
- Blind = no out-of-band advocacy, not no context: withhold conversation and
  advocacy; always send the whole document (its Decisions section included)
  plus every artifact it cites/depends on/inherits from, in reading order; the
  invented-system failure mode stated as the reason.
- Promptfiles and raw reviewer output live in the driver's scratchpad, outside
  the reviewed project — never committed, never left as project files.
- External dependencies are always staged (never assume outside-worktree reads
  work — where they don't, a review silently invents the missing context):
  copy them into `.luna-loop-staging/` inside the worktree, point the reading
  order there, delete after the round, and check `git status` afterward (the
  directory is deliberately NOT gitignored, so a leftover is visible).
  In-worktree dependencies are cited by path.
- Ledger: `<doc-basename>.review.md` beside the document, committed; header =
  document path + reviewer identity; per round = git baseline ref, finding
  rows (`id | severity | one-line | disposition | reason/fold location`),
  reversal count stated explicitly, escalation outcomes.
- Non-git projects: no baselines and no diff-only rounds — run full-document
  rounds, verify cleanup manually, and state both in the round report.
- Triage: fold / cut / escalate, one cost line per finding; cuts argued
  against the document's Trust Boundary section.
- Rounds: verification rounds are diff-only (reworked doc + ledger + baseline;
  "do not re-litigate settled decisions or cut findings"); report each round
  to the user and wait for approval before the next dispatch; track reversals,
  a reversal stops the loop; convergence is the human's call.
- Effort: max, per the codex skill's document-gate row.

**Verify (all must pass):**
```bash
sed -n '2p' skills/loop-review/SKILL.md | grep -qxF 'name: loop-review'
sed -n '3p' skills/loop-review/SKILL.md | grep -qxF 'description: "Run the independent review gate on a spec or plan: compose a blind codex dispatch, triage findings fold/cut/escalate, keep the review ledger, run diff-only rounds. Dispatches cost real money — invoke only on explicit user request."'
grep -q 'fold' skills/loop-review/SKILL.md
grep -qi 'reversal' skills/loop-review/SKILL.md
grep -q '.luna-loop-staging' skills/loop-review/SKILL.md
grep -q 'scratchpad' skills/loop-review/SKILL.md
! grep -rn '/home/' skills/loop-review/SKILL.md
```

**STOP rule:** as in Global Constraints.

---

## Task 3: `skills/loop-interview/SKILL.md` and `skills/loop-spec/SKILL.md`

**Files:**
- Create: `skills/loop-interview/SKILL.md`
- Create: `skills/loop-spec/SKILL.md`

**Interfaces:**
- Consumes: frontmatter rows and artifact naming (Global Constraints).
- Produces: the spec template that `loop-plan` (Task 4) assumes: sections
  Goal / Trust Boundary & Non-Goals / Architecture-approach / Requirements /
  Acceptance / Decisions / Open questions — plus a Pending Measurements list
  for facts only another machine can verify.

**Contracts:** distill spec §"1. `loop-interview`" and §"2. `loop-spec`" (read
both in full). Required content:
- interview: one decision per message; an option is a claim (verify before
  offering; the recommended option carries the highest verification bar);
  settle implementation details yourself and say so; scope-check/decompose
  first; two exits — spec-ready decisions → loop-spec, or a loose note at
  `docs/notes/YYYY-MM-DD-HHMM-<topic>.md` (`mkdir -p docs/notes` first;
  roadmap checkboxes, research findings; deliberately loose).
- spec: output `docs/specs/YYYY-MM-DD-HHMM-<topic>.md` (`mkdir -p docs/specs`
  first); the template sections listed under Interfaces, with Trust Boundary
  mandatory and named as the triage yardstick that also goes in the reviewer's
  reading order; Requirements numbered/testable/exact; Open questions empty
  before the gate, machine-ownable facts to Pending Measurements instead; the
  four-point self-review (placeholders, consistency, scope, ambiguity) run and
  fixed inline.

**Verify (all must pass):**
```bash
sed -n '2p' skills/loop-interview/SKILL.md | grep -qxF 'name: loop-interview'
sed -n '3p' skills/loop-interview/SKILL.md | grep -qxF 'description: "Pre-spec interview: turn an idea into settled decisions or a loose note. One decision per message; verify options before offering them. Use when brainstorming or shaping work that is not yet a spec."'
sed -n '2p' skills/loop-spec/SKILL.md | grep -qxF 'name: loop-spec'
sed -n '3p' skills/loop-spec/SKILL.md | grep -qxF 'description: "Write a specification from settled decisions: goal, trust boundary and non-goals, numbered requirements with acceptance checks, decisions with their why. Use when an interview has produced spec-ready decisions."'
grep -q 'HHMM' skills/loop-interview/SKILL.md
grep -q 'HHMM' skills/loop-spec/SKILL.md
grep -q 'mkdir -p' skills/loop-interview/SKILL.md
grep -q 'mkdir -p' skills/loop-spec/SKILL.md
grep -qi 'trust boundary' skills/loop-spec/SKILL.md
! grep -rn '/home/' skills/loop-interview skills/loop-spec
```

**STOP rule:** as in Global Constraints.

---

## Task 4: `skills/loop-plan/SKILL.md`

**Files:**
- Create: `skills/loop-plan/SKILL.md`

**Interfaces:**
- Consumes: the spec template section names (Task 3's Produces), "dispatch per
  the codex skill".
- Produces: the plan format every future implementation plan follows.

**Contracts:** distill spec §"3. `loop-plan`" (read it in full). Required
content:
- A plan is a sequence of cold-executor dispatches; extraction contract: every
  dispatch promptfile = the plan's Global Constraints section verbatim + the
  one task, always — nothing "implicitly included".
- Output `docs/plans/YYYY-MM-DD-HHMM-<topic>.md` (`mkdir -p docs/plans`
  first); header = goal + Global Constraints copied verbatim from the spec.
- Per task: Files (exact paths), Interfaces (Consumes/Produces, exact
  signatures), contracts verbatim (schemas/types copied in, not referenced —
  except documents already on disk and gated, which are cited by path and
  section), Verify (exact commands + expected outcome), STOP rule.
- Pre-dispatch reality scan (`rg`/`ls` every named path and symbol so the
  file whitelist and preconditions are complete before gating).
- Hard rules: no placeholders ("TBD", "add appropriate error handling",
  "similar to task N", `...`-elided content, steps that describe without
  showing); executor-facing text carries zero skill/conversation references
  (the `REQUIRED SUB-SKILL:` anti-pattern, named); task granularity = smallest
  unit worth a reviewer's gate, not micro-steps; task order must respect the
  dependency graph — a task may only consume what earlier tasks or the repo
  already provide.
- Self-review: spec coverage, placeholder scan, interface consistency,
  dependency-order check.

**Verify (all must pass):**
```bash
sed -n '2p' skills/loop-plan/SKILL.md | grep -qxF 'name: loop-plan'
sed -n '3p' skills/loop-plan/SKILL.md | grep -qxF 'description: "Turn a gated spec into an implementation plan whose tasks are cold-executor dispatches: exact files, interfaces, contracts verbatim, verify commands, STOP rule. Use after a spec has passed its review gate."'
grep -q 'STOP' skills/loop-plan/SKILL.md
grep -qi 'placeholder' skills/loop-plan/SKILL.md
grep -qi 'reality scan' skills/loop-plan/SKILL.md
grep -q 'mkdir -p' skills/loop-plan/SKILL.md
! grep -rn '/home/' skills/loop-plan
```

**STOP rule:** as in Global Constraints.

---

## Task 5: `README.md`

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: the installer contract from Task 6 (status lines, exit codes,
  never-prompts, fail-clean, no-codex-commands) — the *contract as written there*,
  not the file, which does not exist yet; the five frontmatter names (Global
  Constraints); the loop diagram and gate definition from spec §"The Loop".

**Contracts:** a README for a stranger with no context. Required sections:
- What this is (three sentences max) and the loop diagram with the gate
  definition, taken from the spec.
- Prerequisites: bash (Git Bash on Windows — hard prerequisite), Claude Code,
  Codex CLI ≥0.144 logged in; platform matrix stated honestly — Linux
  measured, macOS expected, Windows provisional.
- Install: clone this repository, `cd` into it, run `./install.sh` (do not
  print a repository URL — the reader is already reading the repository).
  Update: `git pull && ./install.sh`. Uninstall: remove the links/copies.
  Document exit codes 0 (success or all-no-op), 1 (conflict — nothing
  installed), 2 (codex missing or install failure), 64 (bad arg); that the
  installer never prompts, never touches files it does not own, makes no
  network calls, and runs no codex commands.
- The five skills, one line each, from the frontmatter descriptions.
- The disclosure note: your machine's global AGENTS.md and codex skills still
  apply to every dispatch; the pack does not read or manage them — it just
  reminds you at install.
- Artifact conventions: `docs/{specs,plans,notes}/YYYY-MM-DD-HHMM-<topic>.md`,
  ledgers `<doc-basename>.review.md`.
- No badges, no marketing, no roadmap section.

**Verify (all must pass):**
```bash
test -f README.md
grep -q 'AGENTS.md' README.md
grep -qi 'provisional' README.md
grep -q 'git pull && ./install.sh' README.md
! grep -Ern '/home/|@gmail|github.com/' README.md
```

**STOP rule:** as in Global Constraints.

---

## Task 6: `install.sh`, `LICENSE`

**Files:**
- Create: `install.sh` (mode 755)
- Create: `LICENSE`

**Interfaces:**
- Consumes: all five skill directories (Tasks 1–4) — verify all five sources
  exist before starting; if any is missing, STOP.
- Produces: the status-line format, exit codes, and flags that Task 5's README
  documents — implement exactly what the README contract states.

**Contracts:**
- `LICENSE`: the MIT license text below, verbatim:

  ```text
  MIT License

  Copyright (c) 2026 luna-loop contributors

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  ```

- `install.sh` behavior, in order:
  1. **Resolve** the skills dir from `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` and
     the repo root from the script's own location, never the caller's cwd. No
     flags; any argument → usage line, exit 64.
  2. **Environment gates (fail loud, create nothing):** `command -v codex`
     empty → message, exit **2**; the Claude config dir must already exist
     and be an absolute path → otherwise message, exit **2** (Claude Code
     creates that dir; its absence means wrong machine or wrong path — never
     `mkdir -p` a missing parent). No other codex interaction of any kind —
     no network calls, no codex commands, no reads of `$CODEX_HOME`, ever.
  3. **Pre-flight all five targets.** Pack-owned = plain directory containing
     the `.luna-loop` marker. Anything else present (foreign dir, file, any
     symlink) → `conflict <target> -> <dest> (existing: <kind>)` per conflict,
     install **nothing**, exit **1**.
  4. **Install per target:** delete the owned copy if present; `cp -R` from
     the clone; validate `SKILL.md` readable at the destination; drop the
     marker **last** (a receipt — a half-finished copy reads as foreign and
     conflicts loudly on the next run). Failed copy: remove remnants, print
     `failed <target> -> <dest>`, final exit **2**.
  5. **Report:** one `installed` line per target, then the plain-speech line:
     `Of course, codex dispatches follow your machine's own AGENTS.md and
     codex config — your rules, not this pack's.`
  - Exit codes: **0** success; **1** preflight conflict (nothing installed);
    **2** codex missing or copy failure; **64** bad arg.

**Verify (all must pass; expectations are for this Linux machine):**
```bash
bash -n install.sh
test -x install.sh
test -f LICENSE && grep -q 'MIT License' LICENSE

CD=$(mktemp -d)
CLAUDE_CONFIG_DIR=$CD ./install.sh
# expect: exit 0; five 'installed' lines; marker present
#         (test -f "$CD/skills/codex/.luna-loop"); plain-speech line printed
CLAUDE_CONFIG_DIR=$CD ./install.sh
# expect: exit 0; five 'installed' lines again (re-copy; idempotent by outcome)

CD2=$(mktemp -d); mkdir -p "$CD2/skills/codex"
CLAUDE_CONFIG_DIR=$CD2 ./install.sh
# expect: exit 1; one 'conflict' line naming skills/codex; nothing installed
#         (test ! -e "$CD2/skills/loop-spec")

PATH=/usr/bin:/bin ./install.sh
# expect: exit 2; 'codex CLI not found' message; nothing installed

./install.sh --bogus-flag; # expect: exit 64, usage line
! grep -rn '/home/' install.sh LICENSE
```

**STOP rule:** as in Global Constraints.

---

## Driver verification (after all tasks; not a dispatch)

The driver — not the executor — runs the gated spec's acceptance table on this
machine:
- R1 fresh install against real roots (the five targets land, session lists the
  skills), R2 idempotent rerun, R3 seeded conflict, R6 output lines — largely
  re-runs of Task 6's verify against the real `$HOME` roots.
- R4 self-containment: move the clone aside; installed skills keep working.
- R5: run with a PATH that lacks codex — clear message, exit 2, nothing
  installed.
- R8 canary: one implementation-shaped dispatch reports no web tool (measured
  on this machine 2026-07-16: WEB-OFF).
- R10 repo scan for personal data.
- **R7 is deferred, loudly:** the ledger round-trip through the *implemented*
  `loop-review` skill is verified by the first real document gate run after
  installation — a synthetic test would re-test this plan's own review
  process, which already round-tripped three times. Recorded here so the
  deferral is a decision, not an omission.
- R9 (Windows) waits for the peer-round machine, per the spec.
