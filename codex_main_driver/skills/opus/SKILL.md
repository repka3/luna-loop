---
name: opus
description: "Dispatch fresh Opus sessions for independent document review, implementation review, web research, or second opinions. Always read-only and web-enabled; billable, so invoke explicitly or when another luna-loop skill requires a gate."
---

# Opus Dispatch

Opus is an independent read-only backstop and research assistant. It never implements changes. The main Codex driver owns context, synthesis, writes, tests, and decisions.

## Fixed boundary

Every dispatch must:

- use the supported `opus` model alias;
- use effort `xhigh`; substitute `max` only on the user's explicit instruction;
- start a fresh non-persistent print session, never resume or continue;
- keep normal owner Claude context active;
- expose only file reading, search, installed skills, and built-in web search/fetch;
- deny shell, file mutation, agents, Chrome, and MCP tools;
- keep web available for every review and research call.

Owner CLAUDE.md, skills, plugins, and hooks remain the machine owner's domain. The model tool surface is read-only; owner-configured hooks may have independent effects and must be disclosed rather than silently suppressed.

## Prepare the dispatch

Create a private session scratch directory with `mktemp -d`. Put the promptfile, raw output, prepared diffs, and any external review artifacts there, never in the project. Use the smallest exact `--add-dir` only when Opus must read staged artifacts; never grant all of `/tmp`.

Write a neutral, self-contained prompt. Include the subject, reading order, trust boundary, requested output, and evidence expectations. Do not include conversational advocacy or the driver's conclusion.

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

- **Gate review:** return numbered, referenced findings with severities and boundary-human cost for `$loop-review` to triage.
- **Research:** require direct sources, dates, uncertainty, alternatives, and conflicting evidence; the driver independently checks material claims before deciding.
- **Second opinion:** state the question neutrally and compare the result against primary evidence rather than accepting it by model identity.

Read the raw output from scratch, distill it into the active context, and delete only the exact scratch directory created for the run. The Opus response is a claim until the driver verifies it.
