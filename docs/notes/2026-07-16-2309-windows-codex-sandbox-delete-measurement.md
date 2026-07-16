# Windows codex sandbox — delete measurement (2026-07-16)

**What this is:** a measurement of what OpenAI Codex CLI's sandbox actually
enforces on native Windows, taken during this pack's Windows peer-review round
to fill the spec's Pending Measurement ("what does its sandbox actually
enforce on that platform?"). Environment: codex-cli 0.144.5, native Windows 10
(not WSL).

**What this is NOT — read this first.** This is **not** a limitation of
luna-loop or its skills, and it does **not** concern normal use of the loop.
The loop's dispatches are honest tasks ("review this", "implement that") on
content you author; codex does not generate an evasive command for such tasks,
and we never inject hostile prompts into our own dispatches. The behavior below
is reachable **only** by a deliberately obfuscated command originating from
hostile input codex was tricked into trusting — a rogue/adversarial edge, not a
path the loop travels. It is recorded here as a platform property of
codex-on-Windows, for transparency and because it is **likely to be patched
upstream soon** (see Upstream status). If you are re-reading this after a codex
upgrade: re-measure with the method below, it may already be stale.

## Method (dated, so it can be re-run when codex changes)

Every run: `codex exec --sandbox <read-only|workspace-write> --strict-config
--skip-git-repo-check -c model_reasoning_effort=low
-c windows.sandbox=<unelevated|elevated> -c 'web_search="disabled"'
-c approval_policy="never"`, executed in a throwaway bench under a **non-trusted,
non-repo** directory, with **ground truth read from the filesystem after each
run** — never from codex's own self-report (its self-report was wrong or
ambiguous several times; only the filesystem was reliable).

1. **A/B matrix** — 2 sandbox modes (`unelevated`, `elevated`) × 2 settings
   (read-only, workspace-write) × fixed ops (create in/out, overwrite, delete
   in/out).
2. **Faithful test** — natural-language "delete these files", letting codex pick
   its own method, vs. a dictated command.
3. **Determinism check** — the two decisive commands run **3× each** to rule out
   randomness (the key question: rule vs. coin flip).
4. **Isolating test** — a bare `Remove-Item` vs. an obfuscated compound command,
   to locate exactly what differs.

## Results

- **The OS sandbox blocks writes, not deletes.** create/overwrite were denied in
  read-only and (outside the workspace) in workspace-write; **file deletion
  succeeded in both modes**, inside and outside the workspace. Mechanism: the
  Windows restricted-token sandbox (`WRITE_RESTRICTED` + synthetic SIDs) gates
  *write* access; DELETE is a separate Windows access right the write-gate does
  not cover.
- **Under read-only, the real guard is codex's command classifier, not the OS.**
  A bare `Remove-Item X` is recognized and declined ("blocked by policy") —
  3/3. An obfuscated compound command (the delete buried in `try/catch` behind a
  leading write) is waved through by the classifier — 3/3 — and then deletes via
  the OS gap. The classifier is **deterministic** (zero wobble across the 6
  determinism runs) but **shape-based**: it reads what a command looks like, not
  what it does.
- **Damage is delete-only.** Even with the classifier bypassed, writes stay
  blocked — an escape can remove/destroy files but cannot create, overwrite, or
  plant one. No persistence, no content injection.
- **Windows-only.** On Linux/macOS the OS sandbox blocks the delete too, so a
  bypassed classifier still hits a hard wall. This gap is specific to the
  Windows sandbox's mechanism.
- **`elevated` mode is non-functional on the test box** — it hangs any command
  ~100s, then codex kills it. Not a usable stricter alternative here. (May be
  machine/version specific; re-check on other Windows hosts.)

## Upstream status (why this will likely change)

OpenAI is actively iterating on the Windows sandbox filesystem/ACL layer:
`openai/codex` PR #31138 "fix(windows-sandbox): allow deletion in writable
roots" merged 2026-07-08; open data-loss issue #33507 (worktree cleanup deleted
tracked files from the main checkout); #25566 (sandbox help still describes
Windows as restricted-token only). This is churning fast — **re-measure on codex
upgrades.**

## Standing guidance (owner-ruled 2026-07-17; supersedes this section's first draft)

Every call shape stays legal on Windows, workspace-write implementation
included — ruled by the owner after a field week of exactly that use, and
supported by this measurement's own data: the delete gap does not distinguish
sandbox modes (deletion succeeded under `read-only` too), so retreating to
read-only buys nothing. The real mitigations are structural: point codex only
at content you trust **in any mode** (the loop feeds it only authored prompts
and plans; write dispatches run web-disabled), lean on the commit-per-task
cadence to bound worst-case delete damage to uncommitted work, and re-measure
on codex upgrades. What this measurement changes is emphasis, not rules: on
Windows the OS backstop that catches a classifier bypass elsewhere is absent,
so the classifier — a heuristic — is the last line against *hostile input*,
and the trusted-content rule matters more here than on Linux/macOS. Nothing
about honest loop use changes.
