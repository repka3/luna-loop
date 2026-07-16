# Review Ledger — docs/plans/2026-07-16-1415-luna-loop-implementation.md

Reviewer (cold gate): codex gpt-5.6-sol · profile sol-high-fast · effort max ·
sandbox read-only · web live.

## Round 1 — baseline `3d81a70` (2026-07-16)

13 findings: 1 blocker / 10 major / 2 minor.
Dispositions: **13 fold, 0 cut, 0 escalate.** Reversals: n/a (first round).
Nothing was taste; every finding was a contract defect.

| id | sev | finding (one line) | disposition | reason / fold location |
|----|-----|--------------------|-------------|------------------------|
| P1 | blocker | Installer task ran first but consumes five skill dirs created by later tasks — first dispatch STOPs | fold | Tasks reordered: skills (1–4) → README (5) → installer (6, Consumes all six sources) |
| P2 | major | Executor contract (spec authority, dispatch settings, working root) sat outside Global Constraints — extraction loses it | fold | Moved into Global Constraints |
| P3 | major | Profile source assigned to no task and untracked; `docs/notes/` layout entry unassigned | fold | Profile = declared precondition in GC (file now in repo, to commit); skills `mkdir -p` artifact dirs on demand — user projects lack them anyway |
| P4 | major | MACHINE.md schema missed binary paths (spec requires) and a `missing` state for codex | fold | `codex_path` field added; `codex_version: <output\|missing>` |
| P5 | major | Conflict-line formats disagreed between preflight and report; no behavior for exhausted install mechanisms | fold | One conflict format; `failed` status + `mode: failed` + continue-then-exit-2; preflight exit leaves MACHINE.md untouched |
| P6 | major | Read-scope probe had no sentinel, prompt, or classifier — transient errors could be recorded as sandbox facts | fold | Exact probe block specified; ambiguous output → `unprobed`, never guessed |
| P7 | major | Placeholders in the no-placeholder plan: "...all six rows...", `<tmp ...>`, `git clone …`, "stock MIT text" | fold | Six rows written out; verify uses shell vars; README prints no URL ("clone this repository"); full MIT text pasted |
| P8 | major | Task-6 verify was self-defeating: double `mktemp` can never no-op; "six linked" rejects correct fallback; negated greps pass on missing files | fold | Vars captured once and reused; expectations labeled Linux; positive existence checks added; force-copy seam for fallback testing |
| P9 | major | Skill-task verifies were vacuous (`head` is not an assertion; multi-file grep passes if one file matches) | fold | Exact per-line frontmatter assertions (`sed -n '2p' \| grep -qxF`), per-file content greps |
| P10 | major | Driver verification skipped forceable checks: R4 forceable on Linux, R5 loud-failure path untested, R7 silently dropped | fold | R4 via `LUNA_LOOP_FORCE_COPY=1`; R5 tested both ways (empty CODEX_HOME → loud fail); R7 deferred loudly with recorded reason |
| P11 | major | Two spec rules assigned to no skill: scratchpad-for-promptfiles, non-git fallback | fold | Both added to loop-review contract (scratchpad rule also in codex skill) |
| P12 | minor | Task-3 template list omitted Architecture and miscounted the spec's sections | fold | List corrected to match spec template |
| P13 | minor | `.luna-loop-staging/` in `.gitignore` blinded the spec's own `git status` cleanup check | fold | Reverted to one-line `.gitignore`; staging deliberately visible to git status; noted in loop-review contract. Lesson recorded: an undiscussed "improvement" over a gated document, caught by the gate one round later |

**Cut list:** empty.
**Escalations:** none. One disclosed judgment call: R7 deferral to first real
post-install gate (recorded in the plan's driver-verification section).

## Revision 3 — owner-initiated amendment (2026-07-16)

Follows the spec's post-gate reversal (see the spec ledger): no shipped codex
profile. Plan changes: five targets; profile precondition and MACHINE.md profile
row removed; probe commands profile-less at pinned low effort; dispatch settings
and call-shape contracts pin `approval_policy="never"`; codex-skill contract must
state that model/tier inherit the machine's base config. Verified by the combined
high-effort round below alongside the round-1 folds.

## Combined round — high effort, both documents (2026-07-16)

Owner's proportionality ruling: one round at high (subsystem deletion, not new
design). Reviewer: codex gpt-5.6-sol · effort high · read-only · profile-less
call shape (the reversal, dogfooded).

Results: **P1–P13 all RESOLVED. Reversal propagation coherent. Reversals: 0.**
One new finding:

| id | sev | finding (one line) | disposition | reason / fold location |
|----|-----|--------------------|-------------|------------------------|
| N1 | major | Both installer probes pinned only effort — violating the docs' own explicit-on-every-call rule; codex-skill verify too weak to catch incomplete shapes | fold | Probes gain `-c 'web_search="disabled"' -c approval_policy="never"` (disabled, not live: probes need no web); Task 1 verify now asserts live, disabled, both effort levels, and approvals |

**Both documents ready for implementation dispatches** pending the owner's
commit.

## Revision 4 — owner-initiated KISS purge (2026-07-16, post-implementation)

Follows the spec ledger's REVERSAL 2. Implementation note: the owner also ruled
that the pack itself is implemented by the driver, not dispatched to codex —
the deliverables are instructions for a Claude runtime (native-speaker
authorship), prose has no test net (the loop's own codex-implements rationale
doesn't hold), and codex authoring `skills/codex/SKILL.md` would be the dog
writing its own leash. Plan changes: installer contract stripped to
game-over-check + link + record + report; `--no-probe` flag deleted (nothing
left to skip); probe/login/ambient steps deleted; loop-review contract:
always-stage external dependencies; verify battery updated (PATH-without-codex
test added; probe tests removed).

## Revision 5 — owner-initiated plugin-style install (2026-07-16)

Follows the spec ledger's REVERSAL 3. Plain copies with an in-dir `.luna-loop`
marker dropped last as a receipt; symlinks at a target are conflicts; no
`MACHINE.md`, no `.gitignore`, no force-copy seam, no mechanism chain.
Implementation transitioned live on the origin machine: five old symlinks
removed, battery green (fresh, idempotent re-copy, dir conflict, symlink
conflict, codex-missing exit 2, bad arg exit 64, no personal paths), real
install re-run as plain directories with markers verified. Installed skills now
owe nothing to the clone.

## Code review — install.sh (codex, high effort, 2026-07-16)

4 findings: 1 blocker / 1 major / 2 minor. **4 fold, 0 cut** — all correctness
bugs in the minimal design; none re-litigated the KISS rulings. Reversals: 0.

| id | sev | finding (one line) | disposition | fix, verified |
|----|-----|--------------------|-------------|---------------|
| C1 | blocker | Failed `rm -rf` didn't gate `cp -R` — new copy nests inside the survivor, old SKILL.md passes validation, stale install blessed with exit 0 | fold | Deletion is a hard gate: cp only into a confirmed-absent dest; verified with a chmod-555 skills dir → `failed (could not remove previous copy)`, exit 2, no nested copy |
| C2 | major | Marker-creation failure ignored → false success, unowned partial copy | fold | `: > marker` joined to the success chain; any failure → remnants removed, `failed` line, exit 2 |
| C3 | minor | Unset HOME under `set -u` → bash's own exit status, outside the 0/1/2/64 contract | fold | Explicit guard: no CLAUDE_CONFIG_DIR and no HOME → clear message, exit 2; verified with `env -u HOME -u CLAUDE_CONFIG_DIR` |
| C4 | minor | Validation tested existence (`-f`) not readability | fold | `-f && -r` |

Reviewer's verdict pre-fix: "not safe to publish as-is." Post-fix battery: all
original scenarios plus locked-dir and no-HOME — green. Quoting, spaces,
`cp -R`, `: >` judged suitable for macOS bash 3.2 and Git Bash.

Two further findings from the **owner's own read** of the script, same day:

| id | sev | finding (one line) | disposition | fix, verified |
|----|-----|--------------------|-------------|---------------|
| C5 | major | `rm -rf` as the deletion instrument — bounded in practice (hardcoded names, marker-gated, quoted, set -u) but recursive force deletion fails the screenshot test and would plow through unexpected content | fold | `remove_ours()`: delete exactly the two files the pack writes, then `rmdir` — which refuses a non-empty dir. Verified: a user file planted inside an owned skill dir survives; run reports `failed`, exit 2. `grep -c "rm -rf" install.sh` → 0 |
| C6 | major | No parent validation — a bogus or relative `CLAUDE_CONFIG_DIR` made `mkdir -p` build the wrong tree and report a silent wrong-install as success | fold | Environment gates: the Claude config dir must pre-exist (Claude Code creates it) and be absolute; verified: nonexistent dir → message + exit 2 + nothing created; relative path → exit 2 |

Running score for install.sh: codex found the correctness bugs (C1–C4); the
owner found the trust bugs (C5–C6). Both kinds were invisible from inside the
author's intent.
