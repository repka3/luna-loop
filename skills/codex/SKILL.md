---
name: codex
description: "Invoke Codex CLI as reviewer or executor: sandbox table, three call shapes, effort economics, never resume, run handling. Side-effecting and billable — invoke only on explicit user request or when another luna-loop skill directs a dispatch."
---

# codex — dispatch mechanics

Codex is an independent agent from a different model family. It starts cold — no
memory of your conversation — and that coldness is what makes its reviews worth
paying for. This skill is only the mechanics of calling it safely and cheaply.
What to send and how to triage what comes back belongs to `loop-review`.

## Containment is the sandbox flag, nothing else

| dispatch | `--sandbox` |
|---|---|
| review, second opinion, exploration | `read-only` |
| implementation of a plan the user approved | `workspace-write` |

Guard sentences in a prompt are polite requests; the flag is enforcement — codex
does whatever it decides the goal needs, and only the kernel says no. Never use
`--dangerously-bypass-approvals-and-sandbox`, and never use `workspace-write` for
work the user has not approved.

Platform note (measured 2026-07-16, codex-cli 0.144.5, native Windows): the
Windows sandbox blocks writes but **not deletes, in any mode** — codex's
command classifier, a heuristic, is the last line against a hostile-input
delete there. Every shape stays legal on Windows; the mitigation is trusted
content in any mode, not read-only. Re-measure on upgrades — being patched
upstream.

## The three call shapes

Every flag is mandatory on every call.

Document review (gates):
```bash
codex exec --sandbox read-only --strict-config --skip-git-repo-check \
  -c model_reasoning_effort=max -c 'web_search="live"' \
  -c approval_policy="never" "$(cat promptfile)" </dev/null
```

Opinion / exploration — same shape with `-c model_reasoning_effort=high`.

Implementation (web-dark, workspace-confined):
```bash
codex exec --sandbox workspace-write --strict-config --skip-git-repo-check \
  -c model_reasoning_effort=high -c 'web_search="disabled"' \
  -c approval_policy="never" "$(cat promptfile)" </dev/null
```

## Why each flag

- **Explicit effort, always** — a machine's base config may default to an
  expensive level (origin machine: max — silent money on every forgotten
  override). Pin `model_reasoning_effort=max` or `model_reasoning_effort=high`
  per the table below; never inherit.
- **`web_search` pinned per shape** — enum measured: `disabled|cached|indexed|live`.
  Reviews keep `live` (doc-grounded findings are worth it; the sandbox confines
  everything else). Write dispatches are always `disabled`: untrusted web content
  must never steer a process that writes files.
- **`approval_policy="never"` pinned** — headless `exec` runs without it
  (measured), but pinning means behavior never depends on a machine's defaults.
- **`--strict-config`** — a typo'd `-c` override fails loudly and instantly
  instead of silently running at the wrong setting.
- **`--skip-git-repo-check`** — dispatches must work outside git repos.
- **`</dev/null`** — codex waits on non-tty stdin and hangs without it.
- **Deliberately NOT pinned: model and pricing tier.** They inherit the machine's
  own base config — the owner's cost choices, never this skill's.

Prompts over ~6k characters (origin-machine measurement) truncate inline with
phantom quoting errors — always file-back them via `"$(cat promptfile)"`.
Promptfiles and raw codex output live in the session scratchpad, never as
project files.

## Effort economics

- **max** — document gates (spec and plan reviews, and their verification
  rounds) and tiebreaks between conflicting positions. A flaw that survives a
  document review is copied into everything built on it, and prose has no
  safety net.
- **high** — everything the driver re-verifies: implementation, code review,
  exploration, opinions. Never pay max for work a test suite re-reviews free.
  When in doubt: high.

## Never resume a session

Never `codex exec resume` — not for a review round, not after a stop, not "to
save re-explaining". A resumed reviewer has its own prior findings in context
and defends them instead of reading cold; an executor's real state is on disk,
and a fresh dispatch re-reads it. The replacement is always a fresh, blind,
narrowly scoped dispatch.

## Run handling

- Long dispatches run in the background — don't poll; capture the final message
  with `-o <file>`.
- Glance at the banner (`reasoning effort:`, `sandbox:`) on max dispatches.
- When raw output would be long, run the dispatch inside a subagent and report
  a distilled summary — raw codex output never enters the driver's context.
- For implementation runs, read the diff and run the tests yourself before
  reporting done. The executor's summary is a claim, not evidence.

## Machine context

Codex loads this machine's global AGENTS.md and its own skills on every call —
measured on codex-cli 0.144: there is no per-invocation off switch. The owner's
config, the owner's rules — this pack neither reads nor manages it. This skill
hardcodes no machine facts: where a number came from one machine's measurement,
it says so, and you re-measure when reality disagrees.
