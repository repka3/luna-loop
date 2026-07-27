# Luna Loop v4 — Swappable Claude and Codex Skill Packs

Luna Loop installs one small skill pack for Claude Code or Codex. The two packs share an engineering attitude—evidence first, explicit owner decisions, durable project state—but they do not pretend the two drivers think or work identically.

Version 3 replaced Codex-main's five workflow-phase skills with one adaptive `loop` skill beside `opus`. Version 4 brings adaptivity to Claude-main: a `luna-loop` entry recommends the lightest adequate route, and the remaining skills — spec, plan, review, execute, codex — become controls it invokes only when they protect against a real failure mode, never mandatory phases. Small, settled work stays small, while hard system work can still use a falsifiable spec, blind review gates, a repository-grounded plan, and task-by-task cold execution. The two fixes are deliberately not the same fix; the asymmetry section below explains why.

| Pack | Main driver | Optional independent backstop | Implementation |
|---|---|---|---|
| Claude-main | Claude Code | Codex | Claude implements small settled work directly; planned work runs as cold Codex dispatches |
| Codex-main | Codex | Opus | Codex implements with its live session context |

There is no automatic mode switch. Installation and removal are separate, explicit operations.

## The asymmetry is intentional

The structural difference is who implements. In Claude-main the driver never implements planned work itself: Claude drives, and implementation is dispatched to Codex — a cold executor from a different model family — with the driver verifying every diff. In Codex-main the driver and the implementer are the same agent: Codex implements with its own live session context, and the independent backstop (Opus) only reviews.

That split is why the packs cannot be mirror images. Claude-main needs its deep control skills because its documents are inter-agent interfaces: the spec and plan formats are the wire format to a cold executor that sees nothing but its promptfile, and the review machinery is the interface to a blind reviewer. Codex-main has no cold executor to feed, so its artifacts only serve decisions and durability — which is why they could collapse into one adaptive skill.

The entry skills differ for a second reason: the drivers fail in opposite directions. Codex fought imposed phase divisions — given separate mandatory workflow skills, it produced hollow artifacts or abandoned the loop entirely (the v2 field experience); its fix was flattening into one skill it actually reads and follows. Claude over-complies — given a six-phase pipeline, it dutifully runs the full ceremony on work that needed none of it; its fix is route selection that makes skipping legal, not flattening.

A mirror-image simplification would have fixed a problem Claude does not have while destroying protocol its architecture still depends on. Do not "unify" the packs; their difference is the design.

## Commands

Install or refresh one pack:

```bash
./install_claude_main.sh
./install_codex_main.sh
```

Remove one pack:

```bash
./uninstall_claude_main.sh
./uninstall_codex_main.sh
```

Inspect both standard skill roots without changing them:

```bash
./who_is_driving.sh
```

The detector makes a best effort from the installed receipt-backed files. It cannot inspect which model is actually handling the current terminal session. If both packs are installed, it reports the driver as ambiguous.

To switch deliberately:

```bash
./uninstall_claude_main.sh
./install_codex_main.sh
```

or the reverse. Installing one pack never removes the other.

The installed skills are plain copies:

- Claude skills: `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`
- Codex skills: `$HOME/.agents/skills`

Updating is `git pull` followed by the relevant installer. Moving from a retired layout is intentionally explicit: run the pack's uninstaller, then its installer. This applies to both retired six-skill Codex packs and to the retired Claude pack that shipped `loop-interview`.

## Script safety

Each script has one job and no shared mode engine.

- Installers validate every source and existing managed destination before copying.
- Existing receipt-backed skills can be refreshed in place.
- A foreign, symlinked, modified, or unexpectedly shaped managed directory stops the operation.
- Uninstallers preflight the whole owned name set before deleting anything.
- Uninstallers remove only exact known files from receipt-backed directories, then use `rmdir`; they contain no recursive deletion command.
- Unrelated skills are left alone.
- Each uninstaller recognizes its current pack and its retired layouts (Codex: both retired six-skill packs; Claude: the retired `loop-interview` pack).

Exit codes are intentionally small:

- `0` — requested operation completed, or the requested pack was already absent.
- `1` — ownership/layout conflict; the script refused the operation. For the detector, the state is ambiguous or inconsistent.
- `2` — invalid environment or filesystem operation.
- `64` — invalid command arguments.

## Codex-main: one adaptive loop

Codex-main installs two skills from `codex_main_driver/skills/`:

- **loop** — chooses the lightest disciplined route through evidence gathering, architectural discussion, durable decisions, a falsifiable design contract, implementation planning, direct implementation, and verification.
- **opus** — dispatches a fresh read-only, web-enabled Opus session for review, research, or a second opinion.

Invoke `$loop`, say `Luna Loop`, or ask to `use the loop`. Codex inspects read-only context, recommends a route, and asks for confirmation when the route is not already explicit. `$opus` remains explicitly authorized because every dispatch is billable.

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

## Claude-main: adaptive entry, deep controls

Claude-main installs six skills from `claude_main_driver/skills/`:

- **luna-loop** — the adaptive entry: interview discipline, lightest-adequate-route selection, evidence rules, and non-cascading authorization. It invokes the other skills as controls.
- **loop-spec** — freezes settled decisions into a falsifiable specification whose Trust Boundary calibrates review triage.
- **loop-plan** — turns settled behavior into cold-executor dispatches: exact files, contracts verbatim, verify commands, STOP rule.
- **loop-review** — the blind Codex review gate: dispatch composition, fold/cut/escalate triage, the review ledger.
- **loop-execute** — runs a settled plan task-by-task as cold Codex dispatches: dispatch → verify → commit → next.
- **codex** — dispatch mechanics: sandbox table, call shapes, effort economics, never resume.

The entry is named `luna-loop`, not `loop`, because Claude Code ships a built-in `/loop` command; the Codex skill root has no such collision.

The lightest adequate route wins:

```text
small, settled, and local            → implement directly, verify
settled, needs durable sequencing    → plan → dispatch → verify
decisions unsettled                  → interview → one of the above
multiple compliant designs remain    → interview → spec → plan → …
hard system work                     → interview → spec → gate → plan
                                          → gate → dispatch → verify
```

The execution line: work that needs no plan, Claude implements and verifies in place; work that earns a plan is dispatched cold to Codex — the plan format exists to be extracted into promptfiles, and the cold executor's STOP rule is part of what a plan buys.

Unlike Codex-main, whose driver implements with its live session context, Claude-main keeps the deep protocol skills: the spec and plan formats are the interface to a cold executor, and the review machinery is the interface to a blind reviewer. The entry skill decides *whether* those interfaces are needed; the control skills define *how* they work.

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

The scripts are exercised with isolated fake homes, independent installation and removal, coexistence detection, idempotent refresh/removal, the current and both retired Codex packs, custom Claude roots, unrelated-skill preservation, foreign/modified/symlink refusal, and exact receipts:

```bash
bash tests/installers.sh
```

Fixtures are retained under `/tmp/luna-loop-test.*` for inspection. The suite and production uninstallers use no recursive deletion command.
