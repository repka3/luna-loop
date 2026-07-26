---
name: loop
description: "Run the adaptive Luna Loop for disciplined software work without mandatory phases. Use when the user invokes $loop, says Luna Loop or use the loop, or otherwise explicitly asks for the Luna Loop workflow to guide architectural discussion, durable decisions, a falsifiable design contract, implementation planning, direct implementation, verification, or optional Opus challenge. Recommend the lightest adequate route and never treat loop invocation alone as authorization to implement."
---

# Luna Loop

Use one adaptive workflow. Apply only the controls that address a real uncertainty or risk; never force a ledger, contract, plan, review, or implementation merely because another one occurred.

## Enter deliberately

Read the request, repository guidance, existing artifacts, and enough code or evidence to assess the work. Stay read-only while choosing a route.

When the user already selected a route, follow it. Otherwise:

1. Recommend the lightest adequate route with a concrete reason.
2. Identify any point where Opus would add meaningful independent scrutiny.
3. Ask the user to confirm the route before creating workflow artifacts.

Route confirmation authorizes the agreed in-project ledger, contract, or plan work. It does not authorize implementation. Require an explicit go-word such as `go` or `implement the settled change` after the implementation scope is settled.

Treat tentative language such as `I think`, `maybe`, `what if`, `probably`, and `it seems` as discussion, not a decision or authorization. Investigate, challenge, expand, and recommend; do not mutate while the user is considering an idea.

For example, `I think these logs should move lower in the handler` authorizes investigation and a recommendation only. It does not authorize an edit, commit, push, image build, publication, or deployment.

Treat an explicit request for the full workflow as permission to use every control that helps, not as a command to create empty artifacts.

## Select controls by failure mode

- **Discussion and ledger** — use when intent, architecture, boundaries, or material trade-offs remain unsettled.
- **Design contract** — use when materially different behaviors or architectures could all comply with the current authority.
- **Implementation plan** — use when behavior is settled but repository-specific sequencing, affected-surface analysis, migration, or verification needs durable precision.
- **Direct implementation** — use when the change is settled, localized, proportionate, and easy to verify.
- **Opus** — propose when an independent challenge, research pass, or implementation review has enough expected value to justify its cost.

Combine controls freely. Valid routes include direct implementation, plan then implementation, ledger then plan, contract then implementation, and the full ledger-contract-review-plan-review-implementation-review route.

Skip a separate artifact when its necessary content fits precisely in the next artifact. Skipping a document never permits skipping the reasoning it would have protected.

Increase rigor with uncertainty, blast radius, irreversibility, cost, security or data exposure, external side effects, and the number of users or systems affected. Do not optimize production work for one-shot benchmark completion.

## Ground decisions in evidence

Do not debate a fact that can be measured. Prefer current repository state, tests, logs, metrics, traces, controlled probes, and primary documentation over model memory or confident intuition.

Distinguish:

- **Observed** — supported by cited files, commands, tests, logs, measurements, or sources;
- **Inferred** — concluded from observations, with the reasoning stated;
- **Unknown** — not established, with the exact next probe identified;
- **Chosen** — an owner decision or trade-off that evidence alone cannot settle.

Give evidence enough provenance to evaluate it: environment, path or source, command or probe, relevant time window, sample size, and observed result. Check freshness, representativeness, and confounders before treating data as decisive.

Resolve discoverable engineering facts before asking the user. When a probe requires credentials, new tooling, cost, external access, production instrumentation, or any mutation outside the already authorized scope, explain the exact probe and wait for approval.

When a decision cannot wait for evidence, label the assumption, compare realistic alternatives, choose the safest reversible option within authority, and define the observation that will confirm, roll back, or reopen it. Never disguise a guess as a fact.

Write durable research or measurement evidence to `docs/notes/YYYY-MM-DD-HHMM-<topic>.md` using local time only when later work needs it.

## Keep direct work disciplined

Before implementation, establish:

- the exact intended change;
- the affected boundary and explicit non-goals;
- the settled behavior and architectural constraints;
- any unresolved decision that could materially change the result;
- verification capable of exposing an incorrect implementation;
- explicit authorization to modify the project.

If any item is materially unclear, stop and recommend the lightest missing control.

Do not silently turn a local request into a new subsystem, dependency, storage model, public interface, migration, cross-component protocol, or architectural pattern. When investigation exposes that expansion, report the evidence, explain the smallest viable routes, recommend one, and wait for the owner decision.

Keep authorization non-cascading:

1. A hypothesis does not settle a decision.
2. A settled decision does not approve a contract or plan.
3. A contract or plan does not authorize implementation.
4. Implementation authorization does not authorize a commit.
5. Commit authorization does not authorize a push.
6. A push does not authorize an image or package build, publication, release, or deployment.

One instruction may authorize several steps only when it names them clearly and supplies every material target. Otherwise stop at the last authorized boundary. Silence is not approval.

Ordinary focused tests and project builds needed to verify an authorized implementation remain in scope. Installing tools, changing authentication or host state, using a container daemon, creating external resources, committing, pushing, publishing, releasing, and deploying require their own explicit authority. Before any external mutation, confirm the account or owner, exact target and name, visibility, environment, and material side effects unless the user already specified them.

## Resolve decisions in a ledger

Use conversation to help the user reason, not merely to transcribe. Inspect discoverable facts first. Challenge assumptions, identify gotchas, expand promising ideas, explain concrete alternatives, and say when a proposal conflicts with evidence.

Write `docs/ledgers/YYYY-MM-DD-HHMM-<topic>.md` using local time only when decisions need durable state. Update the governing ledger instead of creating a parallel account. Prefix every new document under `docs/` with its local date and time in this sortable form; never use a date-only filename.

Keep only useful content:

- status, scope, and non-goals;
- settled decisions with short reasons;
- rejected alternatives when the reason prevents reopening;
- reversals and downstream artifacts requiring reconciliation;
- open owner decisions;
- pending evidence with an owner and next probe;
- the current resume point.

Ask one genuine owner decision at a time and include a recommendation. Persist a decision when it settles; do not preserve exploratory noise as authority. Before pausing or leaving discovery, reconcile the conversation with the ledger.

## Write a falsifiable design contract

Write `docs/contracts/YYYY-MM-DD-HHMM-<topic>.md` using local time, or update the existing governing contract. Mark it **draft**, **accepted**, or **superseded**.

Use this completeness test:

> If two materially different behaviors or intentionally constrained architectures can both comply with a rule, the rule is incomplete.

Allow freedom only for mechanics that do not matter to the settled design. Include internal architecture when ownership, boundaries, sources of truth, transaction scope, ordering, or another structural choice must constrain downstream plans.

For every material rule, define:

- **Where** — the exact subsystem, boundary, entry point, state, or interface;
- **When** — the triggering condition and relevant combinations;
- **Which** — enumerated fields, values, actors, states, and errors;
- **What** — the required operation, output, transition, ordering, limit, or prohibition;
- **Failure** — the exact result when the operation cannot complete;
- **Evidence** — an observation or test capable of falsifying the rule.

Replace undefined terms such as `safe`, `sanitized`, `appropriate`, `sensitive`, `caller data`, `robust`, `properly`, and `handle correctly` with exact sets, operations, conditions, and results. Use decision tables when combinations matter.

Map each material rule to acceptance evidence. Put unmeasured engineering facts under **Pending evidence** with an owner and probe. Do not accept the contract while owner decisions, placeholders, conflicting interpretations, or unverified repository claims remain.

## Produce a repository-grounded plan

Write `docs/plans/YYYY-MM-DD-HHMM-<topic>.md` using local time, or update the existing plan.

Derive the plan from the latest user authority, accepted contract when present, settled ledger decisions, repository guidance, and verified code. Do not invent missing behavior. When no separate contract is useful, put the exact behavioral rules and acceptance evidence in the plan itself.

Inspect every path, symbol, dependency, consumer, test, and command named by the plan. Organize work in dependency order. For each meaningful task include only what helps execution:

- observable outcome and reason;
- exact create, modify, remove, and test paths;
- affected interfaces, schemas, invariants, and state transitions;
- implementation detail sufficient to prevent rediscovery;
- exact verification and expected evidence;
- evidence or disagreement that requires stopping or replanning.

Cover migrations, compatibility, documentation, and pinning tests only when the change actually affects them. Remove placeholders and vague instructions. A plan does not authorize implementation.

## Use Opus as adversarial input

Propose `$opus` during discussion, contract work, planning, research, or implementation review when independent scrutiny is worthwhile. Because every dispatch is billable, ask before each call unless the user granted blanket Opus permission for the current loop.

Give Opus a neutral, self-contained brief and the complete relevant authority. Ask for numbered findings classified as **blocker**, **major**, **minor**, or **nitpick**, with exact evidence, realistic reachability, concrete impact, uncertainty, and the smallest supported correction.

Treat every Opus finding and severity as a claim. Triage every finding against primary evidence:

- **fold** — supported, reachable, in scope, and proportionate; recommend the smallest correction and apply it only within existing write authorization;
- **cut** — incorrect, already handled, duplicated, out of scope, disproportionate, or dependent on an implausible theoretical condition;
- **escalate** — exposes a genuine owner decision or changes settled meaning.

Do not dump raw findings on the user. Summarize what to fold, explain what was cut, and bring forward only genuine forks with evidence, consequences, and a recommendation.

Never use a clean review as the convergence condition. Do not repeat reviews merely because Opus can find another issue. Re-review only when folded changes materially alter the reviewed subject. Finish when accepted material findings are resolved and every remaining finding has a justified disposition.

Do not create a review record by default. When the triage has durable audit or resume value, write an adjacent `<timestamped-subject-basename>.review.md`; otherwise fold material authority into the ledger, contract, or plan and leave reviewer noise behind.

## Preserve authority and finish cleanly

Apply authority in this order:

1. the user's latest explicit correction;
2. the accepted design contract;
3. the implementation plan;
4. the ledger and evidence notes.

When these disagree materially, reconcile the durable artifacts or stop for an owner decision. During implementation, inspect the actual diff, run focused checks and the proportionate project suite, diagnose failures from evidence, and update only artifacts that would otherwise mislead the next session.

At completion, report the result, changed files, verification evidence, artifact reconciliations, and residual risk. No final Opus pass or other ceremonial gate is mandatory.
