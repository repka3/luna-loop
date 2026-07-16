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
