#!/usr/bin/env bash
# Isolated regression tests. Fixtures remain under /tmp for inspection.
set -u

TEST_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
REPO_ROOT="$(cd "$TEST_DIR/.." && pwd -P)" || exit 1
CLAUDE_TARGETS="luna-loop codex"
PREVIOUS_CLAUDE_TARGETS="luna-loop loop-spec loop-plan loop-review loop-execute codex"
LEGACY_CLAUDE_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute codex"
CODEX_TARGETS="luna-loop opus"
RETIRED_ADAPTIVE_CODEX_TARGETS="loop opus"
PREVIOUS_CODEX_TARGETS="loop-ledger loop-behavior loop-plan loop-review loop-execute opus"
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

expected_pack_output() {
  printf 'Luna Loop Claude pack: %s.\nLuna Loop Codex pack: %s.\n' "$1" "$2"
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

write_retired_codex_pack() {
  local root="$1" skill
  shift
  mkdir -p "$root" || exit 1
  for skill in "$@"; do
    mkdir -p "$root/$skill/agents" || exit 1
    printf '%s\n' '---' "name: $skill" '---' > "$root/$skill/SKILL.md" || exit 1
    printf 'interface: {}\n' > "$root/$skill/agents/openai.yaml" || exit 1
    printf 'luna-loop-receipt-v2\nmode=codex-main\nskill=%s\nlayout=codex-v1\n' \
      "$skill" > "$root/$skill/.luna-loop" || exit 1
  done
}

write_retired_claude_pack() {
  local root="$1" skill
  shift
  mkdir -p "$root" || exit 1
  for skill in "$@"; do
    mkdir -p "$root/$skill" || exit 1
    printf '%s\n' '---' "name: $skill" '---' > "$root/$skill/SKILL.md" || exit 1
    printf 'luna-loop-receipt-v2\nmode=claude-main\nskill=%s\nlayout=claude-v1\n' \
      "$skill" > "$root/$skill/.luna-loop" || exit 1
  done
}

codex_source_layout_is_exact() {
  local actual
  actual="$(find "$REPO_ROOT/codex_main_driver/skills" \
    -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)"
  [ "$actual" = "$(printf 'luna-loop\nopus')" ]
}

claude_source_layout_is_exact() {
  local actual
  actual="$(find "$REPO_ROOT/claude_main_driver/skills" \
    -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort)"
  [ "$actual" = "$(printf 'codex\nluna-loop')" ]
}

codex_opus_effort_policy_is_exact() {
  local skill="$REPO_ROOT/codex_main_driver/skills/opus/SKILL.md"
  grep -Fq 'The supported efforts for this dispatcher are `high`, `xhigh`, and `max`.' "$skill" &&
    grep -Fq 'default to `high`.' "$skill" &&
    grep -Fq 'that exact value.' "$skill" &&
    grep -Fq 'do not dispatch and do not' "$skill" &&
    grep -Fq 'Announcing a substituted effort is not consent' "$skill" &&
    grep -Fq 'opus_effort=high' "$skill" &&
    grep -Fq -- '--effort "$opus_effort"' "$skill" &&
    ! grep -Fq -- '--effort xhigh' "$skill"
}

printf 'fixtures are retained under /tmp/luna-loop-test.* for inspection\n'

assert_true "Codex source pack has exactly luna-loop and opus" codex_source_layout_is_exact
assert_true "Claude source pack has exactly luna-loop and codex" claude_source_layout_is_exact
assert_true "Codex Opus effort follows the current user or defaults high" \
  codex_opus_effort_policy_is_exact

# Empty roots are a determinate state.
new_fixture
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "empty inspection succeeds" 0
assert_output "empty inspection reports both packs independently" \
  "$(expected_pack_output "not installed" "not installed")"

# Each installer owns only its own pack, and both installed is a valid state.
new_fixture
mkdir -p "$CASE_HOME/.agents/skills/unrelated" || exit 1
printf 'keep\n' > "$CASE_HOME/.agents/skills/unrelated/owner.txt" || exit 1
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "Claude install succeeds" 0
assert_true "Claude receipts are exact" assert_receipts \
  "$CASE_CLAUDE/skills" claude-main claude-v1 $CLAUDE_TARGETS
run_script "$REPO_ROOT/whats_installed.sh"
assert_output "inspection reports only the Claude pack installed" \
  "$(expected_pack_output installed "not installed")"
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "Claude reinstall is idempotent" 0

run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "Codex install succeeds without removing Claude" 0
assert_true "Codex receipts are exact" assert_receipts \
  "$CASE_HOME/.agents/skills" codex-main codex-v2 $CODEX_TARGETS
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "Codex reinstall is idempotent" 0
assert_true "Codex install is a byte copy" cmp -s \
  "$REPO_ROOT/codex_main_driver/skills/luna-loop/SKILL.md" \
  "$CASE_HOME/.agents/skills/luna-loop/SKILL.md"
assert_true "Codex Opus install is a byte copy" cmp -s \
  "$REPO_ROOT/codex_main_driver/skills/opus/SKILL.md" \
  "$CASE_HOME/.agents/skills/opus/SKILL.md"
assert_false "retired workflow names are not installed" \
  test -e "$CASE_HOME/.agents/skills/loop-ledger"
assert_false "retired interview name is not installed" \
  test -e "$CASE_HOME/.agents/skills/loop-interview"
assert_true "Claude pack remains installed" test -f "$CASE_CLAUDE/skills/luna-loop/SKILL.md"
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "two installed packs are a valid state" 0
assert_output "inspection reports both packs installed independently" \
  "$(expected_pack_output installed installed)"

run_script "$REPO_ROOT/uninstall_claude_main.sh"
assert_status "Claude uninstall succeeds" 0
assert_false "Claude pack is removed" test -e "$CASE_CLAUDE/skills/luna-loop"
run_script "$REPO_ROOT/whats_installed.sh"
assert_output "inspection reports only the Codex pack installed" \
  "$(expected_pack_output "not installed" installed)"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstall succeeds" 0
assert_false "Codex pack is removed" test -e "$CASE_HOME/.agents/skills/luna-loop"
assert_true "unrelated skill survives" test -f "$CASE_HOME/.agents/skills/unrelated/owner.txt"
run_script "$REPO_ROOT/whats_installed.sh"
assert_output "inspection returns to both packs absent" \
  "$(expected_pack_output "not installed" "not installed")"
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
  test -e "$CASE_HOME/.agents/skills/luna-loop"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "foreign Codex target blocks uninstall" 1
assert_true "foreign target survives uninstall refusal" \
  test -f "$CASE_HOME/.agents/skills/loop-plan/KEEP"
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "foreign managed name makes inspection fail" 1
assert_output "inspection isolates the inconsistent Codex pack" \
  "$(expected_pack_output "not installed" "incomplete or modified")"

# Modified receipt-backed content is not silently overwritten or deleted.
new_fixture
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "modified-layout setup install" 0
printf 'unexpected\n' > "$CASE_HOME/.agents/skills/luna-loop/EXTRA" || exit 1
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "modified owned target blocks refresh" 1
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "modified owned target blocks uninstall" 1
assert_true "unexpected content remains untouched" \
  test -f "$CASE_HOME/.agents/skills/luna-loop/EXTRA"

# The Version 4 two-skill Codex pack is detected and removed only by the
# explicit uninstaller.
new_fixture
write_retired_codex_pack "$CASE_HOME/.agents/skills" $RETIRED_ADAPTIVE_CODEX_TARGETS
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "Version 4 Codex pack is recognized" 0
assert_output "Version 4 Codex pack is reported" \
  "$(expected_pack_output "not installed" "retired; reinstall recommended")"
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "Version 5 installer refuses implicit entry rename" 1
assert_true "Version 4 entry remains after refusal" \
  test -f "$CASE_HOME/.agents/skills/loop/SKILL.md"
assert_false "refused rename creates no Version 5 entry" \
  test -e "$CASE_HOME/.agents/skills/luna-loop"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstaller removes Version 4 pack" 0
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "Version 5 pack installs after explicit uninstall" 0
assert_true "Version 5 pack uses the unified entry name" \
  test -f "$CASE_HOME/.agents/skills/luna-loop/SKILL.md"
assert_false "Version 4 entry name stays absent" \
  test -e "$CASE_HOME/.agents/skills/loop"

# The previous Codex pack is detected and removed only by the explicit uninstaller.
new_fixture
write_retired_codex_pack "$CASE_HOME/.agents/skills" $PREVIOUS_CODEX_TARGETS
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "previous Codex pack is recognized" 0
assert_output "previous Codex pack is reported" \
  "$(expected_pack_output "not installed" "retired; reinstall recommended")"
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "current installer refuses implicit retired-name migration" 1
assert_true "retired pack remains after refusal" \
  test -f "$CASE_HOME/.agents/skills/loop-ledger/SKILL.md"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstaller removes retired pack" 0
run_script "$REPO_ROOT/install_codex_main.sh"
assert_status "current Codex pack installs after explicit uninstall" 0
assert_true "current pack replaces retired names" \
  test -f "$CASE_HOME/.agents/skills/luna-loop/SKILL.md"
assert_false "retired ledger name stays absent" \
  test -e "$CASE_HOME/.agents/skills/loop-ledger"

# The oldest Codex six-skill pack remains detectable and removable.
new_fixture
write_retired_codex_pack "$CASE_HOME/.agents/skills" $LEGACY_CODEX_TARGETS
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "oldest Codex pack is recognized" 0
assert_output "oldest Codex pack is reported" \
  "$(expected_pack_output "not installed" "retired; reinstall recommended")"
run_script "$REPO_ROOT/uninstall_codex_main.sh"
assert_status "Codex uninstaller removes oldest pack" 0
assert_false "oldest spec name is removed" \
  test -e "$CASE_HOME/.agents/skills/loop-spec"

# The previous Claude six-skill pack is detected and removed only by the
# explicit uninstaller.
new_fixture
write_retired_claude_pack "$CASE_CLAUDE/skills" $PREVIOUS_CLAUDE_TARGETS
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "previous Claude pack is recognized" 0
assert_output "previous Claude pack is reported" \
  "$(expected_pack_output "retired; reinstall recommended" "not installed")"
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "Claude installer refuses implicit previous-pack migration" 1
assert_true "previous Claude pack remains after refusal" \
  test -f "$CASE_CLAUDE/skills/loop-spec/SKILL.md"
run_script "$REPO_ROOT/uninstall_claude_main.sh"
assert_status "Claude uninstaller removes previous pack" 0
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "current Claude pack installs after explicit uninstall" 0
assert_true "current pack keeps the luna-loop entry" \
  test -f "$CASE_CLAUDE/skills/luna-loop/SKILL.md"
assert_false "previous spec name stays absent" \
  test -e "$CASE_CLAUDE/skills/loop-spec"

# The oldest Claude six-skill pack is detected and removed only by the explicit uninstaller.
new_fixture
write_retired_claude_pack "$CASE_CLAUDE/skills" $LEGACY_CLAUDE_TARGETS
run_script "$REPO_ROOT/whats_installed.sh"
assert_status "oldest Claude pack is recognized" 0
assert_output "oldest Claude pack is reported" \
  "$(expected_pack_output "retired; reinstall recommended" "not installed")"
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "Claude installer refuses implicit retired-name migration" 1
assert_true "oldest Claude pack remains after refusal" \
  test -f "$CASE_CLAUDE/skills/loop-interview/SKILL.md"
assert_false "refused Claude install creates no entry skill" \
  test -e "$CASE_CLAUDE/skills/luna-loop"
run_script "$REPO_ROOT/uninstall_claude_main.sh"
assert_status "Claude uninstaller removes oldest pack" 0
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "current Claude pack installs after oldest-pack uninstall" 0
assert_true "current pack includes the luna-loop entry" \
  test -f "$CASE_CLAUDE/skills/luna-loop/SKILL.md"
assert_false "retired interview name stays absent" \
  test -e "$CASE_CLAUDE/skills/loop-interview"

# Custom Claude roots and the original empty Claude marker remain supported.
new_fixture
CASE_CLAUDE="$FIXTURE_ROOT/custom-claude"
mkdir "$CASE_CLAUDE" || exit 1
run_script "$REPO_ROOT/install_claude_main.sh"
assert_status "custom Claude root is supported" 0
: > "$CASE_CLAUDE/skills/luna-loop/.luna-loop"
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
  install_codex_main.sh uninstall_codex_main.sh whats_installed.sh; do
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
