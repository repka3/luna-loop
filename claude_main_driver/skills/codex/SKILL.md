---
name: codex
description: "Dispatch Codex CLI as a cold reviewer, second-opinion/brainstorm search agent, or executor: sandbox flags, the two call shapes, verify-then-triage of review findings. Side-effecting and billable — invoke only on explicit user request."
---

# codex

Codex is an independent agent from a different model family. It starts cold —
no memory of this conversation — and that coldness is the value: it reviews
what is on disk, not what we believe. This skill is self-contained: how to
call it, and what to do with what it returns.

## Containment is the sandbox flag, nothing else

| dispatch | `--sandbox` |
|---|---|
| review, second opinion, brainstorm search | `read-only` |
| implementation the user approved | `workspace-write` |

Guard sentences in a prompt are polite requests; the flag is enforcement.
Never `--dangerously-bypass-approvals-and-sandbox`, and never
`workspace-write` for work the user has not approved.

## The two call shapes

Every flag is mandatory on every call.

Read-only — review, second opinion, brainstorm search (default xhigh; max
only if the user asks):
```bash
codex exec --sandbox read-only --strict-config --skip-git-repo-check \
  -c model_reasoning_effort=xhigh -c 'web_search="live"' \
  -c approval_policy="never" "$(cat promptfile)" </dev/null
```

Executor (stays at high, web search live):
```bash
codex exec --sandbox workspace-write --strict-config --skip-git-repo-check \
  -c model_reasoning_effort=high -c 'web_search="live"' \
  -c approval_policy="never" "$(cat promptfile)" </dev/null
```

Why each flag:

- **Effort pinned explicitly** — a machine's base config may default to an
  expensive level; never inherit.
- **`approval_policy="never"`** — headless behavior must not depend on a
  machine's defaults.
- **`--strict-config`** — a typo'd `-c` fails loudly instead of silently
  running at the wrong setting.
- **`--skip-git-repo-check`** — dispatches must work outside git repos.
- **`</dev/null`** — codex hangs waiting on non-tty stdin without it.
- **Deliberately NOT pinned: model and pricing tier** — they inherit the
  machine's base config, the owner's cost choice.

Prompts over ~6k characters truncate inline with phantom quoting errors —
always file-back them via `"$(cat promptfile)"`. Promptfiles and raw codex
output live in the session scratchpad, never as project files.

## Review findings: verify one by one, then triage

Codex is high-recall and low-precision. It can lie — a fabricated finding is
formatted exactly like a real one — and it flags issues that are technically
correct but fire only when Jupiter aligns with Mars, the Earth, and the Sun.
Never act on a finding as delivered.

1. **Verify every claim against the actual code, one by one.** Open the file,
   read the lines it cites. A finding that misquotes the code or describes
   behavior the code does not have is refuted — record it and move on.
2. **Triage the survivors** and recommend a disposition per finding:
   - **fold** — a real bug, reachable in practice; worth fixing.
   - **Jupiter alignment** — technically correct, but needs an edge-case
     conjunction that does not occur in practice. Name the exact
     preconditions so the user can judge for themselves.
   - **out of scope** — true, but not what this dispatch was about.
3. **The user decides; you recommend.** Present the triage with your
   suggested disposition per finding and wait for their call before fixing
   anything.

## Second opinions and brainstorm search

During a discussion — "we have this problem, what could solve it?" — codex
can run as a parallel search agent: read-only shape, live web search doing
the legwork. State the problem and its real constraints in the promptfile;
withhold our leading candidate — priming buys agreement, and independence is
what the dispatch is for. What comes back is conversation input, not
verdicts: bring the ideas to the user as options with codex's reasoning
attached, and verify any factual claim — about our code or about the outside
world — before a decision builds on it.

## Never resume a session

Never `codex exec resume`. A resumed reviewer has its own prior findings in
context and defends them instead of reading cold; an executor's real state is
on disk, and a fresh dispatch re-reads it. The replacement is always a fresh,
blind, narrowly scoped dispatch.

## Run handling

- Long dispatches run in the background — don't poll; capture the final
  message with `-o <file>`.
- Glance at the banner (`reasoning effort:`, `sandbox:`) on expensive
  dispatches.
- When raw output would be long, run the dispatch inside a subagent and
  report a distilled summary — raw codex output never enters the driver's
  context.
- For executor runs, read the diff and run the tests yourself before
  reporting done. The executor's summary is a claim, not evidence.
