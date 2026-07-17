---
name: loop-review
description: "Run independent Opus gates for specifications, plans, and completed implementations; compose neutral context-complete briefs, triage findings, maintain ledgers, and track convergence. Use when a loop artifact reaches a required review gate."
---

# Loop Review

Use Opus as a read-only, web-enabled independent backstop. `$opus` owns call mechanics; this skill owns what to send, how to triage the result, and when the gate is settled.

## Compose a blind, complete brief

- Withhold the conversation and out-of-band advocacy. Send the whole artifact, including recorded decisions and reasons.
- Provide every artifact the subject cites, depends on, or inherits from, in reading order. Missing context makes a cold reviewer invent the system.
- For external artifacts, place exact copies in the private session scratch directory and grant Opus read access only to that directory.
- For implementation review, provide the gated spec and plan, the reviewed commit range or prepared diff, relevant source paths, and the driver's verified test results.
- Ask Opus to walk failure timelines as the boundary human and state what that person sees and loses for every finding.
- Ask for numbered findings with severity, evidence, and precise references. Do not ask the reviewer to approve the work or declare convergence.

## Keep a durable ledger

Document gates use `<document-basename>.review.md`. Final implementation review uses `<plan-basename>.implementation.review.md`.

Record reviewer/model/effort/tool boundary, reviewed baseline, finding rows, dispositions, reversal count, and escalation outcomes. In non-git projects, state that no baseline exists and run full-artifact rounds.

## Triage every finding

First state the cost if the finding is real, then choose:

- **fold** — real and inside the written trust boundary; change the authority artifact or implementation.
- **cut** — technically possible but outside the boundary; record the boundary-based reason.
- **escalate** — a real user-visible trade-off or meaning change; bring both sides' evidence to the user.

Do not defer a finding with vague language. Do not let either model silently win a disagreement.

## Run verification rounds

- Document fixes: send the reworked document, ledger, original reading-order inputs, and baseline; ask for diff-only verification without re-litigating cuts or settled decisions.
- Implementation fixes: rerun focused and standard tests first, then send a fresh diff-only Opus verification when the accepted fixes materially changed code.
- Report each round with finding count, severity split, reversal count, boundary-human cost, and recommended disposition.
- A reversal stops the line. Bring both positions and evidence to the user.
- The user decides convergence. The reviewer never declares itself done.

Invoke `$opus` at `xhigh`. Use `max` only when the user explicitly requests it.
