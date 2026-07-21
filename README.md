# Luna Loop — Swappable Claude and Codex Skill Packs

Luna Loop installs one small skill pack for Claude Code or Codex. The two packs share an engineering attitude—evidence first, explicit owner decisions, durable project state—but they do not pretend the two drivers think or work identically.

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

Updating is `git pull` followed by the relevant installer. The first update from the retired Codex names is intentionally explicit: run `./uninstall_codex_main.sh`, then `./install_codex_main.sh`.

## Script safety

Each script has one job and no shared mode engine.

- Installers validate every source and existing managed destination before copying.
- Existing receipt-backed skills can be refreshed in place.
- A foreign, symlinked, modified, or unexpectedly shaped managed directory stops the operation.
- Uninstallers preflight the whole owned name set before deleting anything.
- Uninstallers remove only exact known files from receipt-backed directories, then use `rmdir`; they contain no recursive deletion command.
- Unrelated skills are left alone.
- The Codex uninstaller recognizes both current and retired luna-loop skill names.

Exit codes are intentionally small:

- `0` — requested operation completed, or the requested pack was already absent.
- `1` — ownership/layout conflict; the script refused the operation. For the detector, the state is ambiguous or inconsistent.
- `2` — invalid environment or filesystem operation.
- `64` — invalid command arguments.

## Codex-main: optional tools, not a ceremony

Codex-main installs six explicit skills from `codex_main_driver/skills/`:

- **loop-ledger** — resolves genuine owner decisions and persists each settled answer immediately.
- **loop-behavior** — defines exact observable behavior when durable authority is useful.
- **loop-plan** — plans nontrivial implementation work when sequencing or affected-surface analysis adds value.
- **loop-review** — runs an optional independent Opus review and triages findings against evidence.
- **loop-execute** — implements explicitly authorized work directly and verifies it proportionately.
- **opus** — dispatches a fresh read-only, web-enabled Opus session for review, research, or a second opinion.

All six disable implicit invocation. The user or active workflow selects them deliberately.

The lightest adequate route wins:

```text
small and clear                     → implement directly
clear but nontrivial                → plan → implement
unsettled intent or trade-offs      → ledger → choose the next useful action
observable rules need authority     → behavior → plan or implement
evidence-dependent work             → note/research → record decisions if needed
meaningful independent uncertainty  → optional review at the useful point
```

These are examples, not mandatory phases. A ledger may end in a note. A behavior definition does not require a ledger. A plan does not require either. Review is never automatic, and implementation still requires an explicit go-word.

Opus remains read-only. Its dispatcher uses the supported `opus` alias, `xhigh` effort by default, and a fresh non-persistent session. `max` is used only when the user explicitly requests it.

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

Artifacts belong to the project being developed, not this delivery repository. Codex chooses only the artifacts that help the work:

- `docs/notes/YYYY-MM-DD-HHMM-<topic>.md` — research, evidence, incidents, roadmaps, and evidence ladders.
- `docs/ledgers/YYYY-MM-DD-HHMM-<topic>.md` — settled decisions, reversals, open owner decisions, and the resume point.
- `docs/behaviors/YYYY-MM-DD-HHMM-<topic>.md` — exact observable behavior and acceptance authority.
- `docs/plans/YYYY-MM-DD-HHMM-<topic>.md` — implementation recipes.
- `<subject-basename>.review.md` — optional review record beside the reviewed artifact.
- `<plan-basename>.implementation.review.md` — optional implementation review record.

Notes are not a required phase. The artifact names describe their job; they do not impose a progression.

The material under `docs/` in this repository is historical design evidence. It is not a second source of current installation instructions; this README and the five top-level scripts describe the current packs.

## Verification

The scripts are exercised with isolated fake homes, independent installation and removal, coexistence detection, idempotent refresh/removal, current and retired Codex packs, custom Claude roots, unrelated-skill preservation, foreign/modified/symlink refusal, and exact receipts:

```bash
bash tests/installers.sh
```

Fixtures are retained under `/tmp/luna-loop-test.*` for inspection. The suite and production uninstallers use no recursive deletion command.
