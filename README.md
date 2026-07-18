# Luna Loop — A Swappable Claude ↔ Codex Development Harness

Luna Loop is a small, copy-installed skill pack for running the same disciplined development loop in either direction:

| Mode | Main driver | Independent backstop | Implementation |
|---|---|---|---|
| Claude-main | Claude Code | Codex | Codex receives bounded execution tasks |
| Codex-main | Codex | Opus | Codex implements directly with its full session context |

The spirit is shared, but the skills are native to their driver. They are not forced to have identical wording or even identical dispatch mechanics.

```text
interview → spec → independent gate → plan → independent gate → implement → verify
```

A gate is not a model vote. The driver sends a neutral, context-complete brief, checks every finding against primary evidence and the written trust boundary, records fold/cut/escalate decisions, and lets the user decide convergence.

## Install or switch modes

Prerequisites:

- Bash and standard Unix utilities. On Windows, use Git Bash.
- Claude Code and Codex CLI, installed and authenticated.
- Existing, recognizable Claude and Codex config roots. The installer will not invent them.

Clone the repository, enter it, then choose one mode explicitly:

```bash
./install_codex_main.sh
```

or:

```bash
./install_claude_main.sh
```

Running the other script later switches direction. Updating is `git pull` followed by the same explicit installer.

Check the current mode without changing anything:

```bash
./who_is_driving.sh
```

It reports `Claude is driving.`, `Codex is driving.`, or `Nobody is driving.` A partial, mixed, foreign, or simultaneously active state is reported as inconsistent instead of being guessed.

The installed skills are plain copies, never symlinks:

- Claude skills go to `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills`.
- Codex user skills go to `$HOME/.agents/skills`—not `.codex/skills`. `CODEX_HOME` (default `$HOME/.codex`) is used only to recognize the Codex installation and is not used as the user-skill destination.

After a successful install, the clone can be deleted without affecting the loop. Clone it again only to update or switch.

The installers do not choose the main Codex model or reasoning effort. Those remain user/session choices.

## Installer safety contract

The two public scripts share one transaction engine. It:

- checks that both CLI names exist on `PATH` but never executes either CLI;
- recognizes config roots using non-credential sentinels and never reads auth data;
- rejects direct symlinks, overlapping roots, broad roots, malformed receipts, and foreign content at every managed name;
- preflights luna-loop names in both skill ecosystems before creating or copying anything;
- stages complete byte-checked copies on the destination filesystem and writes the ownership receipt last;
- uses same-filesystem directory renames for cutover and restores the previous selected pack if cutover fails;
- removes the inactive pack only after the selected pack validates in full;
- deletes only known files from exact receipt-backed directories, then uses `rmdir`; it contains no recursive deletion command and no wildcard deletion;
- leaves unrelated Claude and Codex skills alone.

The original Claude-main install used an empty `.luna-loop` marker. That exact two-file legacy layout is migratable only from the real Claude skill root. A marker is never enough by itself: unexpected files turn the directory into a conflict.

Exit codes:

- `0` — selected mode installed and inactive luna-loop pack removed.
- `1` — ownership/layout conflict; nothing changed.
- `2` — environment, staging, cutover, or rollback failure.
- `3` — selected mode is active, but inactive-pack or transaction cleanup was incomplete; inspect the exact path printed by the installer.
- `64` — invalid or ambiguous invocation.

There is intentionally no automated uninstall command. To uninstall, first inspect the receipt-backed luna-loop directories in the active skill root, then remove only the six active skill directories. Unrelated skills are not part of the pack.

## Codex-main

Codex-main installs six Codex-native skills from `codex_main_driver/skills/`:

- **loop-interview** — discovers facts first and resolves one real user decision at a time.
- **loop-spec** — writes the behavior authority, trust boundary, failure walkthroughs, acceptance checks, and decision reasons.
- **loop-plan** — creates a decision-complete plan for direct implementation by the context-rich Codex driver.
- **loop-review** — runs required Opus gates, triages findings, and maintains review ledgers.
- **loop-execute** — implements directly after an explicit go-word, verifies each task, and runs the required final implementation gate.
- **opus** — dispatches fresh read-only, web-enabled Opus sessions for gates, research, and second opinions.

The Codex-main loop is intentionally asymmetric:

```text
Codex interview
  → Codex spec
  → Opus spec gate
  → Codex plan
  → Opus plan gate
  → Codex implements directly
  → Codex verifies
  → Opus final implementation gate
  → user calls convergence
```

Opus never writes. Dispatches keep normal owner Claude context, allow reading/search plus built-in web search/fetch, and deny shell, editing, agents, Chrome, and MCP tools. Owner-configured hooks remain owner state and may have independent effects.

The dispatcher uses `--model opus`, `--effort xhigh`, and a fresh non-persistent session. The alias was measured on 2026-07-17 through Claude's structured `modelUsage` metadata and resolved to `claude-opus-4-8`. Using the supported alias allows a future Opus release to become current without editing the skill. `max` effort is used only when the user explicitly requests it.

## Claude-main

Claude-main installs the established six-skill pack from `claude_main_driver/skills/`:

- **loop-interview**
- **loop-spec**
- **loop-plan**
- **loop-review**
- **loop-execute**
- **codex**

Claude drives the conversation and gates; Codex is the independent reviewer and bounded executor. Codex calls still follow the machine owner's own `AGENTS.md`, skills, and Codex configuration.

## Artifacts

Loop artifacts belong to the project being developed, not this delivery repository:

- `docs/specs/YYYY-MM-DD-HHMM-<topic>.md`
- `docs/plans/YYYY-MM-DD-HHMM-<topic>.md`
- `docs/notes/YYYY-MM-DD-HHMM-<topic>.md`
- `<document-basename>.review.md`
- `<plan-basename>.implementation.review.md`

The material under `docs/` in this repository records earlier design work and measurements. It is historical evidence, not a second source of current installation instructions; this README and the installer code describe the current dual-mode pack.

## Verification status

The dual-mode installer is measured on Linux with isolated fake homes, both switch directions, idempotent reinstalls, legacy migration, unrelated-skill preservation, malformed/foreign/symlink refusal, missing-root/tool failures, forced mid-cutover rollback, and forced inactive-cleanup failure. The repository test is:

```bash
bash tests/installers.sh
```

The test retains its fresh `/tmp/luna-loop-test.*` fixtures for inspection and itself uses no recursive cleanup. macOS and Git Bash are designed-for but should be treated as unmeasured for this new dual-mode installer until their test runs are recorded. Historical Windows Codex sandbox measurements remain under `docs/notes/`.
