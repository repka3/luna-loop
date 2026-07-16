# Review Ledger — docs/specs/2026-07-16-luna-loop-design.md

Reviewer (cold gate): codex gpt-5.6-sol · profile sol-high-fast · effort max ·
sandbox read-only · web live.

## Round 1 — baseline `c71d5fd` (2026-07-16)

23 findings: 3 blocker / 16 major / 3 minor.
Dispositions: 21 fold (2 simplified), 1 partial cut, 3 owner rulings.
Reversals: n/a (first round).

| id | sev | finding (one line) | disposition | reason / fold location |
|----|-----|--------------------|-------------|------------------------|
| F1 | blocker | "Cold" not enforced: codex loads global AGENTS.md + own skills; no per-invocation off switch | fold (owner-ruled) | Disclose-never-manage: Trust Boundary reworded; MACHINE.md ambient section; post-install reminder. Measured: no switch exists in codex 0.144 |
| F2 | blocker | No-clobber skips the very skill the pack replaces; no migration path | fold (owner-revised) | Conflicts fail clean: pre-flight all targets; any foreign same-name dir → install nothing, name it, exit non-zero. Installer never moves/backs up user files. Supersedes an interim backup-adopt design |
| F3 | blocker | Windows "supported" vs bash-only installer; workspace-write barred until measured | fold + partial cut | Fold: Git Bash declared a hard prerequisite; Windows marked provisional. Cut: "cannot run implementation half yet" is the staged design, by intent |
| F4 | major | review/codex skill runtime contract undefined | fold | loop-review owns composition/triage/rounds/approval; codex owns call mechanics ("dispatch per the codex skill"); self-containment rule scoped to executor-facing text |
| F5 | major | Installer lacks ownership/state machine | fold (simplified) | Ownership = link-into-clone or MACHINE.md-recorded copy; update = pull+install always; copies never hand-edited. Heavyweight hash/atomicity machinery cut as over-engineering for five dirs |
| F6 | major | "First mechanism that works" undefined | fold | Sentinel-read validation after create; failed attempt removed before next mechanism; `cygpath -w` for mklink paths |
| F7 | major | Dry probe hangs on stdin, omits mandatory flags | fold | Probe = full review-shape flags + trivial prompt + `</dev/null`; `--no-probe` opt-out; failure loud, never silently certified |
| F8 | major | Differing existing profile: no resolution semantics | fold | Keep-theirs → profile marked DIVERGED in MACHINE.md + printed warning that skill cost/behavior assumptions may not hold |
| F9 | major | Hardcoded `~/.claude`, `~/.codex` | fold | `CLAUDE_CONFIG_DIR` / `CODEX_HOME` honored with those defaults |
| F10 | major | No version floors or capability checks | fold | codex ≥0.144 (measured floor); Claude symlinked-skill floor → Pending Measurements; installer records local versions |
| F11 | major | No durable ledger/baseline schema across cold rounds | fold | This file is the fix: `<doc>.review.md` committed beside the doc; schema = reviewer header + finding rows + per-round git baseline + reversal count |
| F12 | major | §5 redistribution loses seven load-bearing behaviors | fold | Reassigned: reality scan + implementation prompt anatomy → loop-plan; per-round user approval → loop-review; banner check, `-o` capture, background runs, subagent isolation, distilled reporting, driver-verifies-diff-and-tests → codex |
| F13 | major | Outside-worktree read assumption is machine-specific, unprobed | fold | Install runs a read-scope probe → MACHINE.md; loop-review consults it; confined scope → copy dependencies into worktree before dispatch |
| F14 | major | No frontmatter/trigger/invocation policy for the five skills | fold | Frontmatter table added; dispatch skills (loop-review, codex) declare explicit-invocation-only in their own descriptions |
| F15 | major | Global Constraints only "implicitly" included in tasks | fold | Extraction contract: every dispatch promptfile = constraints header verbatim + the one task, always |
| F16 | major | Spec violates its own template (no Requirements section) | fold | Requirements & Acceptance added (R1–R10); spec template gains an Acceptance section |
| F17 | major | `web_search="live"` in all modes contradicts "sandbox is only containment" | fold (owner-ruled) | Write dispatches add `-c 'web_search="disabled"'` (enum `disabled\|cached\|indexed\|live` and WEB-OFF effect measured); read-only keeps live; boundary names web a separate capability |
| F18 | major | Public-repo hygiene aspirational | fold | `.gitignore` = MACHINE.md; promptfiles/raw reviewer output live in driver scratchpad, never in repo; ledgers committed by design |
| F19 | major | Profile always copied → drift despite symlinked skills | fold | `git pull && ./install.sh` habit refreshes profile too; diff+ask only on user-modified profile |
| F20 | minor | Repo-root/artifact-path semantics unstated | fold | Artifacts resolve relative to driver's project root; git required for round baselines; non-git → manual verify, stated in report |
| F21 | minor | "Withhold decided-X-because-Y" contradicts the Decisions section | fold | Reworded: withhold = out-of-band advocacy; the document, Decisions included, is the artifact |
| F22 | minor | Effort policy ambiguous for untested work | fold | Rule: max = document gates + tiebreaks; high = everything else; when in doubt, high |
| F23 | minor | Origin-machine observations universalized | fold | Labeled as origin measurements; portable requirements (always `--profile`, file-backed long prompts) stated separately |

**Cut list (do not re-litigate):**
- F3 (part): Windows cannot run implementation dispatches until its sandbox is
  measured — staged rollout by design, not a gap.
- F5 (part): full installer state machine (content hashes, atomicity,
  interrupted-run recovery) — over-engineering for five directories; the ownership
  rule plus the pull+install habit covers the real risk.

**Owner rulings (settled):**
- F1: ambient codex context is the machine owner's domain — disclose and remind,
  never manage or work around.
- F2: the installer never moves, renames, or backs up user files — conflicts fail
  clean with an explanation.
- F17: web disabled on write dispatches, live on read-only dispatches.

## Round 2 — diff-only vs baseline `c71d5fd` (2026-07-16)

Fold grading: **20 RESOLVED / 3 PARTIAL (F2, F7, F19) / 0 UNADDRESSED.**
New findings: N1–N7 (4 major, 3 minor). **Reversals: 0.**
Trajectory: 23 wide → 7 narrow, nothing reopened — converging.

| id | sev | finding (one line) | disposition | reason / fold location |
|----|-----|--------------------|-------------|------------------------|
| N1 | major | Superseded adopt/backup language survives at three sites (skill naming, install report, R10) | fold | Purged; fail-clean is the only migration language left. Also closes F2-partial |
| N2 | major | Profile "diff and ask" contradicts the abort-all conflict rule | fold (owner-confirmed) | Resolved by unification: the profile is a sixth install target — same mechanism chain, same fail-clean conflict rule, installer fully non-interactive. The interim provenance-hash proposal is discarded as compensation machinery. Also dissolves F19-partial |
| N3 | major | Confined-read dependency copies can dirty — and be committed into — the user's project | fold | Temporary `.luna-loop-staging/` inside the worktree, deleted post-round, `git status` check afterward |
| N4 | major | R7's "only the ledger + baseline" blesses a context-starved verification round | fold | Reworded: ledger + baseline + standard reading-order inputs; what is excluded is conversational context |
| N5 | minor | "Silent when nothing to do" vs "reports all no-ops" is ambiguous | fold | Contract: never interactive, one status line per target; six no-op lines are the idempotency proof |
| N6 | minor | Boundary's "ledgers contain only findings" contradicts the ledger schema | fold | Boundary reworded: review-process data (findings, dispositions, baselines, reversal counts), never personal/machine data |
| N7 | minor | R3 seeds the repo source path, not the install target | fold | `$CLAUDE_CONFIG_DIR/skills/codex` |
| F7p | — | Probe mislabeled "review-shape" while omitting the max override | fold | Relabeled: mandatory flag set at profile-default effort — a connectivity/profile-resolution check, deliberately not max |

**Owner rulings added this round:**
- Profile unification (symlink like the skills, one rule for six targets) — the
  copy special-case protected an impossible scenario; owner's gut caught the
  asymmetry, analysis confirmed, ruled in.

## Round 3 — diff-only vs baseline `c71d5fd` (2026-07-16)

Fold grading: **7 of 8 RESOLVED, N1 PARTIAL. Reversals: 0** (third consecutive
zero-reversal round). New findings: N8 (major), N9 (minor).
Trajectory: 23 → 7 → 2.

| id | sev | finding (one line) | disposition | reason / fold location |
|----|-----|--------------------|-------------|------------------------|
| N1p | — | Three residual "backup" occurrences | **cut** | They are the prohibition itself ("never moves, renames, backs up…") and the Decisions section's historical provenance of the superseded design — rule and record, not operational language. Root cause: the round-3 reviewer instruction said "no backup *language* anywhere" where it should have said "no operational backup *behavior*"; the reviewer obeyed literally |
| N8 | major | Multi-Machine section still described `MACHINE.md` with the pre-unification schema (per *skill*, pack-owned *dirs*, "profile divergence") | fold | Reworded to per-target ownership; "profile divergence" removed — the concept no longer exists |
| N9 | minor | Probe claims to prove profile resolution "through the link" — false on copy-fallback machines | fold | "through the installed target" |

**Owner additions (entering unreviewed, disclosed):**
- Artifact naming gains the time: `YYYY-MM-DD-HHMM-` (24-hour, local machine time)
  for specs, plans, and notes — several artifacts land per day, and the timestamp
  makes lexicographic order chronological. Ledgers inherit the document's basename.
  Existing two files grandfathered during this series.
- The term **gate** is now defined in The Loop section — the pack's central term
  was used throughout and defined nowhere; caught by the owner's clarifying
  question after three max-effort rounds missed it.

## GATE — spec v1

Owner declared convergence after round 3 and reviewed the final diff personally.
Series: 3 rounds, 32 findings total (23 + 7 + 2), 0 reversals across all rounds,
2 cuts, 5 owner rulings. The two unreviewed owner additions above entered at gate
time with the owner as their reviewer. This document is settled foundation; any
change to it from here is a reversal and stops the line.
