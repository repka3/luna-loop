# luna-loop

A portable skill pack for a Claude Code driver that uses OpenAI Codex CLI as an
independent reviewer and executor. It encodes one development loop — interview →
spec → review gate → plan → review gate → dispatch → verify — and syncs that
loop identically across every machine that runs it: the repo is the distilled
practice, your machine's local memory is the lab bench.

```
interview ──► notes (fuzzy: roadmap / research)
    │
    ▼ (concrete enough)
  spec ──► codex review (max) ──► triage ──► fold / cut / escalate ──► ledger
    │            ▲                                    │
    │            └──── diff-only verification round ──┘
    ▼ (converged: shrinking findings, zero reversals, human calls it)
  plan ──► codex review (max) ──► triage  (same gate machinery)
    │
    ▼ (converged)
  dispatch to codex (high, workspace-write, web disabled) ──► verify
```

A **gate** is the checkpoint a document must pass before anything downstream is
built on it: review → triage → rework rounds repeat until the findings dry up
and the human declares convergence. A gated document is settled foundation —
reopening one is a reversal, and reversals stop the line.

## Prerequisites

- bash — on Windows that means **Git Bash, a hard prerequisite**
- Claude Code
- Codex CLI **≥ 0.144**, logged in

Platform status, honestly: **Linux — measured. macOS — expected, unverified.
Windows — installer and call shapes measured and working; codex's own sandbox
enforcement first-measured 2026-07-16** (native codex, not WSL). That
measurement — `docs/notes/2026-07-16-2309-windows-codex-sandbox-delete-measurement.md`
— found codex's Windows sandbox blocks writes but not deletes; it does not
change normal loop use, but it means on Windows you keep dispatches read-only,
point codex only at content you trust, and re-measure, since the behavior is
being patched upstream.

## Install

Clone this repository, `cd` into it, then:

```bash
./install.sh
```

Update: `git pull && ./install.sh` — always both; the installer is idempotent.
Uninstall: remove the links/copies from your Claude skills directory. Done.

The installer **never prompts** and **never touches files it does not own** —
a foreign skill at a target name aborts the whole install with an explanation
(exit 1) and you resolve it yourself. It installs only into
`$CLAUDE_CONFIG_DIR/skills/` (default `~/.claude/skills/`) and **never reads or
writes your codex configuration**; your codex model and pricing tier stay your
own base-config choices.

- The installer makes **no network calls and runs no codex commands** — it
  checks that `codex` resolves on your PATH (game over if not) and copies six
  folders, plugin-style. That's the whole job.
- Installed skills are plain directories that owe nothing to this repo — you
  can delete the clone afterwards and everything keeps working; you only need
  it again to update.
- Exit codes: `0` success · `1` conflict, nothing installed ·
  `2` codex missing or copy failure · `64` bad arg

## The six skills

- **loop-interview** — pre-spec interview: one decision per message, options
  verified before they're offered; exits to a spec or a loose note.
- **loop-spec** — write the specification: trust boundary mandatory, numbered
  requirements with acceptance checks, decisions with their why.
- **loop-plan** — turn a gated spec into a plan whose tasks are cold-executor
  dispatches: exact files, contracts verbatim, verify commands, STOP rule.
- **loop-review** — the independent gate: blind codex dispatch, fold/cut/escalate
  triage, committed review ledger, diff-only rounds. Invoked explicitly — it
  costs real dispatches.
- **loop-execute** — run a gated plan task-by-task: one task in flight, the
  driver verifies diff and tests itself, commits green before the next; a STOP
  amends the plan. Fires only on the user's explicit go-word.
- **codex** — dispatch mechanics: sandbox table, three call shapes, effort
  economics, never resume. Invoked explicitly or by the other skills.

## Disclosure

Codex loads your machine's global `AGENTS.md` and its own skills on every call;
there is no per-invocation off switch (measured on 0.144). This pack does not
read, manage, or work around your codex configuration — it just reminds you at
install time. Your machine, your rules.

## Artifact conventions

Specs, plans, and notes live in the project you're working on, not in this
repo: `docs/specs/`, `docs/plans/`, `docs/notes/`, named
`YYYY-MM-DD-HHMM-<topic>.md` (the timestamp makes a directory listing read as
history). Review ledgers sit beside the document they gate:
`<doc-basename>.review.md`.
