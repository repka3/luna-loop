#!/usr/bin/env bash
# Isolated regression tests. Fixtures remain under /tmp for inspection.
set -u

TEST_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
REPO_ROOT="$(cd "$TEST_DIR/.." && pwd -P)" || exit 1
CLAUDE_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute codex"
CODEX_TARGETS="loop-ledger loop-behavior loop-plan loop-review loop-execute opus"
LEGACY_CODEX_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute opus"
PASS_COUNT=0
FAIL_COUNT=0
LAST_STATUS=0
LAST_OUTPUT=""

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf 'ok %s\n' "$1"; }

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'not ok %s\n' "$1" >&2
  [ -f "$LAST_OUTPUT" ] && sed -n '1,120p' "$LAST_OUTPUT" >&2
}

assert_true() {
  local name="$1"
  shift
  if "$@"; then pass "$name"; else fail "$name"; fi
}

assert_false() {
  local name="$1"
  shift
  if "$@"; then fail "$name"; else pass "$name"; fi
}

assert_status() {
  local name="$1" expected="$2"
  if [ "$LAST_STATUS" -eq "$expected" ]; then
    pass "$name"
  else
    fail "$name (expected $expected, got $LAST_STATUS)"
  fi
}

assert_output() {
  local name="$1" expected="$2" actual
  actual="$(cat "$LAST_OUTPUT")"
  if [ "$actual" = "$expected" ]; then
    pass "$name"
  else
    fail "$name (expected '$expected', got '$actual')"
  fi
}

new_fixture() {
  FIXTURE_ROOT="$(mktemp -d /tmp/luna-loop-test.XXXXXX)" || exit 1
  CASE_HOME="$FIXTURE_ROOT/home"
  CASE_CLAUDE="$CASE_HOME/.claude"
  mkdir -p "$CASE_CLAUDE" || exit 1
  LAST_OUTPUT="$FIXTURE_ROOT/output"
}

run_script() {
  local executable="$1"
  shift
  env HOME="$CASE_HOME" CLAUDE_CONFIG_DIR="$CASE_CLAUDE" \
    "$executable" "$@" > "$LAST_OUTPUT" 2>&1
  LAST_STATUS=$?
}

assert_receipts() {
  local root="$1" mode="$2" layout="$3"
  shift 3
  local skill receipt failed=0
  for skill in "$@"; do
    receipt="$root/$skill/.luna-loop"
    [ -f "$receipt" ] || { failed=1; continue; }
    [ "$(sed -n '1p' "$receipt")" = luna-loop-receipt-v2 ] || failed=1
    [ "$(sed -n '2p' "$receipt")" = "mode=$mode" ] || failed=1
    [ "$(sed -n '3p' "$receipt")" = "skill=$skill" ] || failed=1
    [ "$(sed -n '4p' "$receipt")" = "layout=$layout" ] || failed=1
  done
  [ "$failed" -eq 0 ]
}

write_legacy_codex_pack() {
  local root="$1" skill
  mkdir -p "$root" || exit 1
  for skill in $LEGACY_CODEX_TARGETS; do
    mkdir -p "$root/$skill/agents" || exit 1
    printf '%s\n' '---' "name: $skill" '---' > "$root/$skill/SKILL.md" || exit 1
    printf 'interface: {}\n' > "$root/$skill/agents/openai.yaml" || exit 1
    printf 'luna-loop-receipt-v2\nmode=codex-main\nskill=%s\nlayout=codex-v1\n' \
      "$skill" > "$root/$skill/.luna-loop" || exit 1
  done
}

printf 'fixtures are retained under /tmp/luna-loop-test.* for inspection\n'

# Empty roots are a determinate state.
new_fixture
run_script "$REPO_ROOT/who_is_driving.sh"
assert_status "empty inspection succeeds" 0
assert_output "empty inspection reports nobody" "Nobody is driving."

# Each installer owns only its own pack. Both may coexist, making the driver ambiguous.
new_fixture
mkdir -p "$CASE_HOME/.agents/skills/unrelated" || exit 1
printf 'keep\n' > "$CASE_HOME/.agents/skills/unrelated/owner.txt" || exit 1
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "Claude install succeeds" 0
assert_true "Claude receipts are exact" assert_receipts \
  "$CASE_CLAUDE/skills" claude-main claude-v1 $CLAUDE_TARGETS
run_script "$REPO_ROOT/who_is_driving.sh"
assert_output "inspection reports Claude" "Claude is driving."
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "Claude reinstall is idempotent" 0

run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "Codex install succeeds without removing Claude" 0
assert_true "Codex receipts are exact" assert_receipts \
  "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "Codex reinstall is idempotent" 0
assert_true "Codex install is a byte copy" cmp -s \
  "$REPO_ROOT/codex_main_driver/skills/loop-behavior/SKILL.md" \
  "$CASE_HOME/.agents/skills/loop-behavior/SKILL.md"
assert_false "retired interview name is not installed" \
  test -e "$CASE_HOME/.agents/skills/loop-interview"
assert_true "Claude pack remains installed" test -f "$CASE_CLAUDE/skills/loop-spec/SKILL.md"
run_script "$REPO_ROOT/who_is_driving.sh"
assert_status "two installed packs are ambiguous" 1
assert_output "ambiguity is explicit" \
  "Both Claude and Codex packs are installed; the driver is ambiguous."

run_script "$REPO_ROOT/uninstall_claude_main.sh"
assert_status "Claude uninstall succeeds" 0
assert_false "Claude pack is removed" test -e "$CASE_CLAUDE/skills/loop-spec"
run_script "$REPO_ROOT/who_is_driving.sh"
assert_output "inspection reports Codex" "Codex is driving."
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstall succeeds" 0
assert_false "Codex pack is removed" test -e "$CASE_HOME/.agents/skills/loop-behavior"
assert_true "unrelated skill survives" test -f "$CASE_HOME/.agents/skills/unrelated/owner.txt"
run_script "$REPO_ROOT/who_is_driving.sh"
assert_output "inspection returns to nobody" "Nobody is driving."
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstall is idempotent" 0

# A foreign managed name blocks install and uninstall before any mutation.
new_fixture
mkdir -p "$CASE_HOME/.agents/skills/loop-plan" || exit 1
printf 'owner content\n' > "$CASE_HOME/.agents/skills/loop-plan/KEEP" || exit 1
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "foreign Codex target blocks install" 1
assert_true "foreign target survives install refusal" \
  test -f "$CASE_HOME/.agents/skills/loop-plan/KEEP"
assert_false "refused install creates no partial pack" \
  test -e "$CASE_HOME/.agents/skills/loop-ledger"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "foreign Codex target blocks uninstall" 1
assert_true "foreign target survives uninstall refusal" \
  test -f "$CASE_HOME/.agents/skills/loop-plan/KEEP"

# Modified receipt-backed content is not silently overwritten or deleted.
new_fixture
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "modified-layout setup install" 0
printf 'unexpected\n' > "$CASE_HOME/.agents/skills/loop-review/EXTRA" || exit 1
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "modified owned target blocks refresh" 1
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "modified owned target blocks uninstall" 1
assert_true "unexpected content remains untouched" \
  test -f "$CASE_HOME/.agents/skills/loop-review/EXTRA"

# The retired Codex pack is detected and removed only by the explicit uninstaller.
new_fixture
write_legacy_codex_pack "$CASE_HOME/.agents/skills"
run_script "$REPO_ROOT/who_is_driving.sh"
assert_status "retired Codex pack is recognized" 0
assert_output "retired Codex pack is reported" \
  "Codex is driving with the retired skill names; reinstall is recommended."
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "current installer refuses implicit retired-name migration" 1
assert_true "retired pack remains after refusal" \
  test -f "$CASE_HOME/.agents/skills/loop-interview/SKILL.md"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstaller removes retired pack" 0
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "current Codex pack installs after explicit uninstall" 0
assert_true "current pack replaces retired names" \
  test -f "$CASE_HOME/.agents/skills/loop-ledger/SKILL.md"
assert_false "retired spec name stays absent" \
  test -e "$CASE_HOME/.agents/skills/loop-spec"

# Custom Claude roots and the original empty Claude marker remain supported.
new_fixture
CASE_CLAUDE="$FIXTURE_ROOT/custom-claude"
mkdir "$CASE_CLAUDE" || exit 1
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "custom Claude root is supported" 0
: > "$CASE_CLAUDE/skills/loop-spec/.luna-loop"
run_script "$REPO_ROOT/uninstall_claude_main.sh"
assert_status "legacy empty Claude receipt can be uninstalled" 0

# Direct symlinks are foreign and are never followed.
new_fixture
mkdir -p "$CASE_CLAUDE/skills" "$FIXTURE_ROOT/outside" || exit 1
printf 'outside\n' > "$FIXTURE_ROOT/outside/keep" || exit 1
ln -s "$FIXTURE_ROOT/outside" "$CASE_CLAUDE/skills/loop-plan" || exit 1
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "symlink target blocks Claude install" 1
assert_true "symlink destination remains untouched" test -f "$FIXTURE_ROOT/outside/keep"

# Public arguments are unambiguous.
new_fixture
for script in install_claude_main.sh uninstall_claude_main.sh \
  install_codex_main.sh uninstall_codex_main.sh who_is_driving.sh; do
  run_script "$REPO_ROOT/$script" unexpected
  assert_status "$script rejects arguments" 64
done

# No installer or uninstaller contains a recursive deletion mechanism.
if rg -n 'rm[[:space:]]+-[^[:space:]]*[rR]|find.*-delete' \
    "$REPO_ROOT/install_claude_main.sh" \
    "$REPO_ROOT/uninstall_claude_main.sh" \
    "$REPO_ROOT/install_codex_main.sh" \
    "$REPO_ROOT/uninstall_codex_main.sh" > "$LAST_OUTPUT" 2>&1; then
  fail "scripts contain no recursive deletion mechanism"
else
  pass "scripts contain no recursive deletion mechanism"
fi

printf 'passes=%s failures=%s\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
