---
name: opus
description: "Dispatch a fresh read-only, web-enabled Opus session for independent review, research, or a second opinion. Invoke $opus explicitly because calls are billable; it never implements changes and no workflow phase requires it automatically."
---

# Opus Dispatch

Opus is an optional independent reviewer and research assistant. It never implements changes. The main Codex driver owns context, synthesis, writes, tests, and decisions.

## Fixed boundary

Every dispatch must:

- use the supported `opus` model alias;
- use effort `xhigh`; substitute `max` only on the user's explicit instruction;
- start a fresh non-persistent print session, never resume or continue;
- keep normal owner Claude context active;
- expose only file reading, search, installed skills, and built-in web search/fetch;
- deny shell, file mutation, agents, Chrome, and MCP tools;
- keep web available for every review and research call.

Owner `CLAUDE.md`, skills, plugins, and hooks remain the machine owner's domain. The model tool surface is read-only; owner-configured hooks may have independent effects and must be disclosed rather than silently suppressed.

## Prepare the dispatch

Create a private session scratch directory with `mktemp -d`. Put the prompt file, raw output, prepared diffs, and external review artifacts there, never in the project. Use the smallest exact `--add-dir` only when Opus must read staged artifacts; never grant all of `/tmp`.

Write a neutral, self-contained prompt. Include the subject, reading order, authority and scope, requested output, and evidence expectations. Do not include conversational advocacy or the driver's conclusion.

## Call shape

Run from the project root. Add `--add-dir "$scratch_dir"` only when staged artifacts are present.

```bash
claude -p \
  --model opus \
  --effort xhigh \
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

- **Review** — return numbered, referenced findings with severity, evidence, and practical cost for `$loop-review` or the driver to triage.
- **Research** — require direct sources, dates, uncertainty, alternatives, and conflicting evidence; independently verify material claims before deciding.
- **Second opinion** — state the question neutrally and compare the result against primary evidence rather than accepting it by model identity.

Read the raw output from scratch and distill it into the active context. Delete only the exact scratch directory created for the run. The Opus response remains a claim until the driver verifies it.
