# Luna Loop v5

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

## Version 5

- Both packs now expose the branded `luna-loop` entry name. In Codex, invoke `$luna-loop`; natural mentions such as `Luna Loop` and `use the loop` still work.
- `whats_installed.sh` replaces the old driver detector. It reports the Claude and Codex packs independently instead of trying to infer which model owns the current session.
- The Codex receipt layout is now `codex-v2`. Moving from Version 4's `loop`/`opus` layout remains explicit: run `uninstall_codex_main.sh`, then `install_codex_main.sh`.

The public name is unified; the pack architectures remain intentionally different.

## Pack overview

| Pack | Main driver | Optional independent backstop | Implementation |
|---|---|---|---|
| Claude-main | Claude Code | Codex | Claude implements small settled work directly; planned work runs as cold Codex dispatches |
| Codex-main | Codex | Opus | Codex implements with its live session context |

### Why the packs differ

Claude-main uses its spec, plan, review, and execution skills as inter-agent interfaces. Planned work goes to a cold Codex executor that sees only its prompt, so those formats must carry the full contract.

Codex-main has no cold executor to feed. Codex plans and implements with its live session context, while Opus acts only as an optional independent backstop. Its workflow can therefore stay inside one adaptive entry skill.

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
- Codex uninstall recognizes Version 4's `loop` entry and both older six-skill layouts; Claude uninstall recognizes the retired `loop-interview` layout.

Exit codes:

- `0` — operation completed, the requested pack was already absent, or inspection found no inconsistent pack.
- `1` — ownership/layout conflict, or inspection found an incomplete or modified pack.
- `2` — invalid environment or filesystem operation.
- `64` — invalid arguments.

## Codex-main: one adaptive loop

Codex-main installs two skills from `codex_main_driver/skills/`:

- **luna-loop** — chooses the lightest disciplined route through evidence gathering, architectural discussion, durable decisions, a falsifiable design contract, implementation planning, direct implementation, and verification.
- **opus** — dispatches a fresh read-only, web-enabled Opus session for review, research, or a second opinion.

Invoke `$luna-loop`, say `Luna Loop`, or ask to `use the loop`. Codex inspects read-only context, recommends a route, and asks for confirmation when the route is not already explicit. `$opus` remains explicitly authorized because every dispatch is billable.

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

Both packs now use `luna-loop` as their entry-skill name. Claude needs the distinct name because Claude Code ships a built-in `/loop` command; Codex has no equivalent collision, but Version 5 adopts the same branded name so users can invoke and discuss Luna Loop consistently across drivers.

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

The scripts are exercised with isolated fake homes, independent installation and removal, coexistence detection, idempotent refresh/removal, the current Codex pack, the Version 4 two-skill Codex pack, both older six-skill Codex packs, custom Claude roots, unrelated-skill preservation, foreign/modified/symlink refusal, and exact receipts:

```bash
bash tests/installers.sh
```

Fixtures are retained under `/tmp/luna-loop-test.*` for inspection. The suite and production uninstallers use no recursive deletion command.
