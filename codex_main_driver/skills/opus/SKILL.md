---
name: opus
description: "Dispatch a fresh read-only, web-enabled Opus session when the user invokes $opus or explicitly asks Opus for an independent review, research pass, or second opinion. Calls are billable; it never implements changes and no workflow phase requires it automatically."
---

# Opus Dispatch

Opus is an optional independent reviewer and research assistant. It may challenge discussion, a design contract, a plan, an implementation, or a research question, but it never implements changes. The main Codex driver owns context, synthesis, triage, writes, tests, and decisions.

## Fixed boundary

Every dispatch must:

- use the supported `opus` model alias;
- resolve effort from the current user's instruction exactly as described
  below;
- start a fresh non-persistent print session, never resume or continue;
- keep the outer Codex session as the context-owning driver;
- expose only file reading, search, installed skills, and built-in web search/fetch;
- deny shell, file mutation, agents, Chrome, and MCP tools;
- keep web available for every review and research call.

Owner `CLAUDE.md`, skills, plugins, and hooks remain the machine owner's domain. The model tool surface is read-only; owner-configured hooks may have independent effects and must be disclosed rather than silently suppressed.

## Resolve effort without substitution

The supported efforts for this dispatcher are `high`, `xhigh`, and `max`.

- If the user explicitly names one of those efforts for the current call, use
  that exact value.
- If the user does not name an effort for the current call, default to `high`.
- If the user explicitly requests another effort, do not dispatch and do not
  substitute a supported value. State the supported values and ask the user to
  choose.

A live explicit user instruction for the current billable call overrides every
effort default, example, recommendation, or earlier preference in this skill.
Never silently increase or decrease effort because the review seems important,
because an earlier call used another value, or because the command example has
a default. Announcing a substituted effort is not consent; obtain a new
explicit instruction before spending at a different effort.

## Prepare the dispatch

Create a private session scratch directory with `mktemp -d`. Put the prompt file, raw output, prepared diffs, and external review artifacts there, never in the project. Use the smallest exact `--add-dir` only when Opus must read staged artifacts; never grant all of `/tmp`.

Write a neutral, self-contained prompt. Include the subject, reading order, authority and scope, requested output, and evidence expectations. Require Opus to inspect cited repository evidence directly instead of accepting the reviewed artifact's claims as facts. Do not include conversational advocacy or the driver's conclusion.

## Call shape

Run from the project root. Add `--add-dir "$scratch_dir"` only when staged artifacts are present.

Set `opus_effort` to the value resolved above. The assignment below shows the
no-instruction default; replace it only with the user's exact supported choice
for the current call.

```bash
opus_effort=high

claude -p \
  --model opus \
  --effort "$opus_effort" \
  --permission-mode dontAsk \
  --tools "Read,Glob,Grep,Skill,WebSearch,WebFetch" \
  --allowedTools "Read" "Glob" "Grep" "Skill" "WebSearch" "WebFetch" \
  --disallowedTools "Bash" "Edit" "Write" "NotebookEdit" "Agent" "mcp__*" \
  --strict-mcp-config \
  --no-chrome \
  --no-session-persistence \
  --settings '{"disableSkillShellExecution":true}' \
  --output-format text \
  "Treat the complete stdin content as the task brief." \
  < "$prompt_file" > "$output_file"
```

`--allowedTools` pre-approves; it does not restrict availability. `--tools` restricts built-in tools, while the explicit MCP denial and strict empty MCP configuration close external action surfaces. Never use bypass permissions.

## Use the result

- **Review** — return numbered findings classified as blocker, major, minor, or nitpick, with exact references, realistic reachability, concrete impact, uncertainty, and the smallest supported correction for `$luna-loop` or the driver to triage.
- **Research** — require direct sources, dates, uncertainty, alternatives, and conflicting evidence; independently verify material claims before deciding.
- **Second opinion** — state the question neutrally and compare the result against primary evidence rather than accepting it by model identity.

Read the raw output from scratch and distill it into the active context. Never use the absence of findings as a convergence requirement, and never repeat a review merely to make Opus return clean. Delete only the exact scratch directory created for the run. The Opus response and its severity labels remain claims until the driver verifies them against primary evidence, proposes a disposition to the owner, and receives the owner's decision under the active workflow.
