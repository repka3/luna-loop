---
name: loop-review
description: "Run the independent review gate on a spec or plan: compose a blind codex dispatch, triage findings fold/cut/escalate, keep the review ledger, run diff-only rounds. Dispatches cost real money — invoke only on explicit user request."
---

# loop-review — the gate

A **gate** is the checkpoint a document must pass before anything downstream is
built on it: review → triage → rework rounds repeat until the findings dry up
and the human declares convergence. A gated document is settled foundation —
reopening one is a reversal, and reversals stop the line.

This skill owns what to send and what to do with what comes back. How to call
codex — flags, sandbox, effort — is the `codex` skill; dispatch per it, review
shape, effort max.

## Composing the dispatch — blind means no advocacy, not no context

- **Withhold, always:** the conversation, and any advocacy beyond the document —
  "we're confident about X", "go easy on Y". Priming buys agreement, and
  independence is the entire value. The document itself, including its
  Decisions-with-why section, is the artifact and is always sent whole.
- **Provide, always:** the document, plus **every artifact it cites, depends
  on, or claims to inherit from**, listed in reading order. A cold reviewer
  that cannot read the system a document depends on will *invent that system
  and review its invention* — confidently, at max effort, formatted exactly
  like a real finding. (Measured: a max review missing one sibling repo
  returned its only blocker at the wrong severity and a security finding the
  withheld context ruled out.)
- **External dependencies are always staged.** Never assume the read-only
  sandbox can read outside the worktree — on platforms where it can't, the
  review doesn't fail, it silently invents the missing context. Copy external
  dependencies into a temporary `.luna-loop-staging/` directory inside the
  worktree, point the reading order there, delete it when the round completes,
  and check `git status` afterward — the directory is deliberately NOT
  gitignored, so a leftover is visible instead of silently committable.
  In-worktree dependencies are cited by path; no staging needed.
- **Instruct the boundary walk.** Tell the reviewer to walk the document's
  failure timelines as the person at the system boundary (user, API consumer,
  operator on call) and name what that person sees and loses per finding. A
  review that answers only convergent technical questions certifies only what
  it was asked — its confidence does not generalize to the human question
  unless the dispatch asks it.
- The promptfile lives in the session scratchpad, never in the project.
- Ask for numbered findings with severities and references.

## The ledger

Every gated document gets `<doc-basename>.review.md` beside it, committed.
It is what makes rounds reproducible across cold sessions — finding identity,
cut reasons, and baselines survive outside anyone's context window.

- Header: document path, reviewer identity (model / effort / sandbox).
- Per round: the **git baseline ref** the round reviewed against; one row per
  finding — `id | severity | one-line | disposition | reason or fold location`;
  the **reversal count stated explicitly** (zero is the health signal);
  escalation outcomes.
- Non-git projects: no baselines and no diff-only rounds — run full-document
  rounds, verify cleanup manually, and state both plainly in the round report.

## Triage — fold / cut / escalate

The reviewer at max is high-recall and low-precision by design; triage converts
noise into signal. Per finding, write one line of what it costs if real, then:

- **fold** — real and inside the document's Trust Boundary → into the document.
- **cut** — technically correct, outside the stated boundary → cut list, with a
  one-line reason. Cuts are argued against the Trust Boundary section, not
  against taste.
- **escalate** — genuinely the human's call → a short interview round, then
  fold or cut with the answer recorded.

## Rounds

- **Verification rounds are diff-only:** the reworked document, the ledger
  (with cut list), and the baseline — plus the instruction "review these
  fixes; do not re-litigate settled decisions or cut findings."
- **Report each round to the user and wait for their approval** before the
  next dispatch.
- **Track reversals, not counts.** A healthy series shrinks and never reopens
  settled ground. A reversal stops the loop — bring both sides' evidence to
  the human.
- **Convergence is a decision, not a discovery.** The reviewer never says
  "done." Scale rounds and effort to stakes: a small utility can gate after
  one round, and a converging series can drop from max to high. The
  proportionality dial — like convergence itself — belongs to the human.
