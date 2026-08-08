# Luna Loop v6

Independent skill packs for Claude Code and Codex, built around the same engineering discipline: evidence first, explicit owner decisions, durable project state, and only as much process as the work earns.

## Quick start

Install or refresh either pack—or both:

```bash
./install_claude_main.sh
./install_codex_main.sh
```

Check each installation independently:

```bash
./whats_installed.sh
```

```text
Luna Loop Claude pack: not installed.
Luna Loop Codex pack: installed.
```

Remove a pack:

```bash
./uninstall_claude_main.sh
./uninstall_codex_main.sh
```

The packs may coexist. Installing or removing one never selects, removes, or changes the other.

## Version 6

- The Claude pack collapsed from six skills to two: `luna-loop` carries the entire workflow — decision ledger, falsifiable plan, the grill, gated dog execution — and `codex` carries dispatch mechanics with verify-then-triage of findings. The retired `loop-spec`/`loop-plan`/`loop-review`/`loop-execute` layout is removed only explicitly: run `uninstall_claude_main.sh`, then `install_claude_main.sh`.
- Blind Codex review of a ledger or plan is now on explicit request only, and there are no `.review.md` ledger files — accepted findings land directly in the reviewed document.
- Carried over from Version 5: both packs expose the branded `luna-loop` entry name, the Codex receipt layout is `codex-v2`, and `whats_installed.sh` reports each pack independently.

The public name is unified; the pack architectures remain intentionally different.

## Pack overview

| Pack | Main driver | Optional independent backstop | Implementation |
|---|---|---|---|
| Claude-main | Claude Code | Codex | Claude implements small settled work directly; planned work runs as cold Codex dispatches |
| Codex-main | Codex | Opus | Codex implements with its live session context |

### Why the packs differ

Claude-main dispatches planned implementation to a cold Codex executor that sees only its prompt, so its plan format must carry the full contract — the format lives inside the `luna-loop` skill, and the `codex` skill owns how dispatches are called and how their findings are triaged.

Codex-main has no cold executor to feed. Codex plans and implements with its live session context, while Opus acts only as an optional independent backstop.

The drivers also fail in opposite directions: Codex resists imposed phase divisions, while Claude tends to over-apply them. Both choose the lightest adequate route, but their internal controls are deliberately not mirror images.

## Installation and safety

Installed skills are plain copies:

- Claude: `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`
- Codex: `$HOME/.agents/skills`

Updating is `git pull` followed by the relevant installer. Retired layouts must be removed with the matching uninstaller before installing the current pack.

Each script has one job and no shared mode engine:

- Installers validate every source and managed destination before copying.
- Existing receipt-backed skills can be refreshed in place.
- Foreign, symlinked, modified, or unexpectedly shaped managed directories stop the operation.
- Uninstallers preflight the entire owned name set, remove only exact known files, and contain no recursive deletion command.
- Unrelated skills are left alone.
- Codex uninstall recognizes Version 4's `loop` entry and both older six-skill layouts; Claude uninstall recognizes both retired six-skill layouts.

Exit codes:

- `0` — operation completed, the requested pack was already absent, or inspection found no inconsistent pack.
- `1` — ownership/layout conflict, or inspection found an incomplete or modified pack.
- `2` — invalid environment or filesystem operation.
- `64` — invalid arguments.

## Codex-main: one adaptive loop

Codex-main installs two skills from `codex_main_driver/skills/`:

- **luna-loop** — chooses the lightest disciplined route through evidence gathering, architectural discussion, durable decisions, a falsifiable design contract, implementation planning, direct implementation, and verification.
- **opus** — dispatches a fresh read-only, web-enabled Opus session for review, research, or a second opinion.

Invoke `$luna-loop`, say `Luna Loop`, or ask to `use the loop`. Codex inspects read-only context, recommends a route, and asks for confirmation when the route is not already explicit. Invoke `$opus` or explicitly ask Opus for a review, research pass, or second opinion. Every Opus dispatch is billable, so Luna Loop asks before calling it unless the user already requested Opus or granted blanket permission for the current loop.

The lightest adequate route wins:

```text
small, settled, and local                 → implement directly
settled but mechanically nontrivial       → plan → implement
unsettled decisions, clear implementation → ledger → plan → implement
multiple compliant designs remain         → contract → plan or implement
genuinely hard system work                 → ledger → contract → optional reviews
                                                → plan → implement → verify
```

These are examples, not mandatory phases. A ledger, contract, plan, or review exists only when it protects against a real failure mode. Skipping an artifact never permits skipping the reasoning it would have protected.

The loop prefers measured repository and system evidence over confident guesses. It distinguishes observed facts, inferences, unknowns, and owner choices. When evidence cannot be collected within existing authority, Codex proposes the exact probe instead of improvising.

Authorization does not cascade. Discussion does not authorize implementation; implementation does not authorize commits; commits do not authorize pushes; and none of those authorize image builds, publication, releases, or deployment. One instruction may authorize several actions only when it names them and their material targets clearly.

Opus may challenge discussion, contracts, plans, research, or implementation. Every finding is triaged as fold, cut, or escalate; Opus severity labels are claims, not verdicts. A clean review is never a convergence requirement. The dispatcher uses the supported `opus` alias, `xhigh` effort by default, and a fresh non-persistent session. `max` is used only when the user explicitly requests it.

## Claude-main: how it works

Claude drives; Codex implements. Claude-main installs two skills from `claude_main_driver/skills/`:

- **luna-loop** — the whole process: route weighting, the decision ledger, the falsifiable plan, the grill that keeps ledger and plan in sync, and gated execution through cold Codex dispatches.
- **codex** — dispatch mechanics: sandbox table, the two call shapes, verify-then-triage of review findings, never resume.

Both packs use `luna-loop` as their entry-skill name. Claude needs the distinct name because Claude Code ships a built-in `/loop` command; Codex has no equivalent collision, but since Version 5 both packs share the branded name so users can invoke and discuss Luna Loop consistently across drivers.

### The route

The process scales to the request — invoking the loop never authorizes implementation by itself:

```text
trivial and settled ("swap those two buttons")   → just do it, verify
settled, execution needs durable precision       → plan → execute
hard system work, unsettled decisions, or the
user calls "the whole circus"                    → ledger → plan (grill) → execute
```

When the user picks the route, Claude follows it. Otherwise Claude recommends the lightest adequate one, with the reason, and confirms before creating artifacts. Rigor rises with uncertainty, blast radius, irreversibility, cost, and security exposure — never with ceremony.

### Ledger and plan

The ledger is the only pre-plan artifact: a running log of decisions, one entry per decision with its why, updated step by step as the discussion settles things. It starts sparse and grows — it is not expected to predict the future.

The plan is derived from the ledger and must be falsifiable: two different executors, given the same plan, should produce roughly the same implementation. That means what, where, how, and what-not — exact files, exact interfaces, contracts verbatim, verify commands that would actually fail on a wrong implementation. Spec-generalities are banned: "we do not log caller data" admits a hundred compliant implementations and forbids none of the wrong ones. Each task is written to be extracted verbatim into a cold executor's promptfile — the plan's Global Constraints plus the one task, nothing else — and every task carries a STOP rule for when the plan and reality disagree.

Documents are datetime-prefixed: `docs/ledgers/YYYY-MM-DD-HHMM-<topic>.md`, `docs/plans/YYYY-MM-DD-HHMM-<topic>.md`.

### The grill

The failure this exists to kill: while writing the plan, hitting something the ledger does not settle and silently deciding "not clear — I'm going with this." From that moment the plan is no longer based on the ledger, and nobody knows until it hurts.

So: every point the ledger under-determines becomes a question to the user — always with a recommendation, and a bit of back-and-forth is the normal cost of a real decision. Every answer is folded back into the ledger before the plan builds on it, so the two documents never diverge. The bar is question quality, not question count: no "do you agree we should not wipe the database," but also no silent guessing on anything genuinely open. Pure implementation details Claude settles itself and reports, so they can be vetoed.

### Execution

The dog on a leash: on the user's go-word — a finished plan is never the trigger — Codex implements one task per cold dispatch. One task is in flight at a time; Claude reads every diff hunk by hunk against the task, runs its verify commands and the project suite, and commits green before the next dispatch, so every dispatch lands on a verified tree and a bug's suspect is one task's diff.

A smell — scope creep, a change beyond the task's boundary, the dog gone wild — stops the line and goes to the user with the evidence. An executor STOP is a plan bug found cheaply: Claude diagnoses against reality, amends the plan, folds the amendment into the ledger if it touches a decision, and dispatches fresh — never resumes.

### Review and second opinions

On explicit request — never as a standing toll — a ledger or plan goes to Codex for a cold, blind review; Codex can also serve as a second-opinion or brainstorm search agent during discussion. Either way its output is never taken as delivered: every claim is verified against the actual code first, then triaged as fold (a real bug, reachable in practice), Jupiter alignment (technically correct, but requiring edge-case preconditions that do not occur in practice), or out of scope. Claude recommends the disposition; the user decides.

Every skill is self-contained by design: the pack assumes no machine-level `CLAUDE.md` or other standing configuration, so it behaves identically on a fresh machine.

## Project artifacts

Artifacts belong to the project being developed, not this delivery repository. Every new artifact starts with local `YYYY-MM-DD-HHMM` so files sort chronologically. Codex creates only the artifacts that help:

- `docs/notes/YYYY-MM-DD-HHMM-<topic>.md` — research, evidence, incidents, roadmaps, and evidence ladders.
- `docs/ledgers/YYYY-MM-DD-HHMM-<topic>.md` — settled decisions, reversals, open owner decisions, and the resume point.
- `docs/contracts/YYYY-MM-DD-HHMM-<topic>.md` — falsifiable behavior and intentionally constrained architecture.
- `docs/plans/YYYY-MM-DD-HHMM-<topic>.md` — implementation recipes.
- `<timestamped-subject-basename>.review.md` — optional durable triage record beside the reviewed artifact.

Notes are not a required phase. The artifact names describe their job; they do not impose a progression.

The material under `docs/` in this repository is historical design evidence. It is not a second source of current installation instructions; this README and the top-level scripts describe the current packs.

## Ubuntu 24.04 Bubblewrap repair

If Codex fails before commands start with `bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted`, run:

```bash
./fix_ubuntu_codex_bwrap.sh
```

The script confirms its host changes interactively, installs Ubuntu's packaged Bubblewrap and AppArmor profile support, loads the specific `bwrap` profile, and probes user and network namespace creation. It does not disable AppArmor's unprivileged-user-namespace restriction globally.

## Verification

The scripts are exercised with isolated fake homes, independent installation and removal, coexistence detection, idempotent refresh/removal, the current Codex pack, the Version 4 two-skill Codex pack, both older six-skill Codex packs, both retired six-skill Claude packs, custom Claude roots, unrelated-skill preservation, foreign/modified/symlink refusal, and exact receipts:

```bash
bash tests/installers.sh
```

Fixtures are retained under `/tmp/luna-loop-test.*` for inspection. The suite and production uninstallers use no recursive deletion command.
