# Luna Loop v3 — Swappable Claude and Codex Skill Packs

Luna Loop installs one small skill pack for Claude Code or Codex. The two packs share an engineering attitude—evidence first, explicit owner decisions, durable project state—but they do not pretend the two drivers think or work identically.

Version 3 is a Codex-focused fix. It leaves Claude-main unchanged and replaces Codex-main's five separate workflow-phase skills with one adaptive `loop` skill alongside `opus`. The result is lighter and more context-aware: small, settled work stays small, while difficult system work can still use durable decisions, a falsifiable design contract, a repository-grounded plan, and independently triaged reviews when those controls protect against a real failure mode.

| Pack | Main driver | Optional independent backstop | Implementation |
|---|---|---|---|
| Claude-main | Claude Code | Codex | Established Claude-led loop |
| Codex-main | Codex | Opus | Codex implements with its live session context |

There is no automatic mode switch. Installation and removal are separate, explicit operations.

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

Updating is `git pull` followed by the relevant installer. Moving from either retired six-skill Codex pack is intentionally explicit: run `./uninstall_codex_main.sh`, then `./install_codex_main.sh`.

## Script safety

Each script has one job and no shared mode engine.

- Installers validate every source and existing managed destination before copying.
- Existing receipt-backed skills can be refreshed in place.
- A foreign, symlinked, modified, or unexpectedly shaped managed directory stops the operation.
- Uninstallers preflight the whole owned name set before deleting anything.
- Uninstallers remove only exact known files from receipt-backed directories, then use `rmdir`; they contain no recursive deletion command.
- Unrelated skills are left alone.
- The Codex uninstaller recognizes the current two-skill pack and both retired six-skill layouts.

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

## Claude-main

Claude-main installs the established six-skill pack from `claude_main_driver/skills/`:

- **loop-interview**
- **loop-spec**
- **loop-plan**
- **loop-review**
- **loop-execute**
- **codex**

This redesign does not change the Claude skill sources. Claude drives its established loop; Codex remains its independent reviewer and bounded executor.

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
