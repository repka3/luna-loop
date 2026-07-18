#!/usr/bin/env bash
# Isolated installer regression tests. Every fixture lives under a fresh /tmp
# directory and is intentionally left for inspection; this suite never uses a
# recursive deletion command.
set -u

TEST_DIR="$(cd "$(dirname "$0")" && pwd -P)" || exit 1
REPO_ROOT="$(cd "$TEST_DIR/.." && pwd -P)" || exit 1
COMMON_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute"
CLAUDE_TARGETS="$COMMON_TARGETS codex"
CODEX_TARGETS="$COMMON_TARGETS opus"
PASS_COUNT=0
FAIL_COUNT=0
LAST_STATUS=0
LAST_OUTPUT=""

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'ok %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'not ok %s\n' "$1" >&2
  if [ -n "$LAST_OUTPUT" ] && [ -f "$LAST_OUTPUT" ]; then
    sed -n '1,120p' "$LAST_OUTPUT" >&2
  fi
}

assert_true() {
  assertion_name="$1"
  shift
  if "$@"; then pass "$assertion_name"; else fail "$assertion_name"; fi
}

assert_false() {
  assertion_name="$1"
  shift
  if "$@"; then fail "$assertion_name"; else pass "$assertion_name"; fi
}

assert_status() {
  assertion_name="$1"
  expected_status="$2"
  if [ "$LAST_STATUS" -eq "$expected_status" ]; then
    pass "$assertion_name"
  else
    fail "$assertion_name (expected $expected_status, got $LAST_STATUS)"
  fi
}

assert_output() {
  assertion_name="$1"
  expected_output="$2"
  actual_output="$(cat "$LAST_OUTPUT")"
  if [ "$actual_output" = "$expected_output" ]; then
    pass "$assertion_name"
  else
    fail "$assertion_name (expected '$expected_output', got '$actual_output')"
  fi
}

new_fixture() {
  FIXTURE_ROOT="$(mktemp -d /tmp/luna-loop-test.XXXXXX)" || exit 1
  CASE_HOME="$FIXTURE_ROOT/home"
  CASE_CLAUDE="$CASE_HOME/.claude"
  CASE_CODEX="$CASE_HOME/.codex"
  mkdir -p "$CASE_CLAUDE/projects" "$CASE_CODEX/sessions" || exit 1
  LAST_OUTPUT="$FIXTURE_ROOT/output"
}

run_installer() {
  executable="$1"
  shift
  env HOME="$CASE_HOME" \
    CLAUDE_CONFIG_DIR="$CASE_CLAUDE" \
    CODEX_HOME="$CASE_CODEX" \
    "$executable" "$@" > "$LAST_OUTPUT" 2>&1
  LAST_STATUS=$?
}

run_installer_with_path() {
  executable="$1"
  test_path="$2"
  shift 2
  env HOME="$CASE_HOME" \
    CLAUDE_CONFIG_DIR="$CASE_CLAUDE" \
    CODEX_HOME="$CASE_CODEX" \
    PATH="$test_path" \
    "$executable" "$@" > "$LAST_OUTPUT" 2>&1
  LAST_STATUS=$?
}

assert_mode_receipts() {
  skills_root="$1"
  mode_name="$2"
  layout_name="$3"
  shift 3
  receipt_failed=0
  for receipt_skill in "$@"; do
    receipt_path="$skills_root/$receipt_skill/.luna-loop"
    [ -f "$receipt_path" ] || { receipt_failed=1; continue; }
    [ "$(sed -n '1p' "$receipt_path")" = "luna-loop-receipt-v2" ] \
      || receipt_failed=1
    [ "$(sed -n '2p' "$receipt_path")" = "mode=$mode_name" ] \
      || receipt_failed=1
    [ "$(sed -n '3p' "$receipt_path")" = "skill=$receipt_skill" ] \
      || receipt_failed=1
    [ "$(sed -n '4p' "$receipt_path")" = "layout=$layout_name" ] \
      || receipt_failed=1
  done
  [ "$receipt_failed" -eq 0 ]
}

make_tool_shims() {
  shim_dir="$1"
  call_log="$2"
  mkdir "$shim_dir" || exit 1
  for shim_tool in claude codex; do
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" "%s" >> "%s"\nexit 99\n' \
      "$shim_tool" "$call_log" > "$shim_dir/$shim_tool" || exit 1
    chmod 755 "$shim_dir/$shim_tool" || exit 1
  done
}

make_failing_mv() {
  shim_dir="$1"
  count_path="$2"
  fail_at="$3"
  mkdir -p "$shim_dir" || exit 1
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    "count_path='$count_path'" \
    "fail_at='$fail_at'" \
    'count=0' \
    '[ -f "$count_path" ] && count="$(sed -n '\''1p'\'' "$count_path")"' \
    'count=$((count + 1))' \
    'printf '\''%s\n'\'' "$count" > "$count_path"' \
    '[ "$count" -eq "$fail_at" ] && exit 91' \
    'exec /usr/bin/mv "$@"' \
    > "$shim_dir/mv" || exit 1
  chmod 755 "$shim_dir/mv" || exit 1
}

make_post_failing_rmdir() {
  shim_dir="$1"
  count_path="$2"
  fail_at="$3"
  mkdir -p "$shim_dir" || exit 1
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    "count_path='$count_path'" \
    "fail_at='$fail_at'" \
    'count=0' \
    '[ -f "$count_path" ] && count="$(sed -n '\''1p'\'' "$count_path")"' \
    'count=$((count + 1))' \
    'printf '\''%s\n'\'' "$count" > "$count_path"' \
    '/usr/bin/rmdir "$@"' \
    'command_status=$?' \
    '[ "$count" -eq "$fail_at" ] && exit 91' \
    'exit "$command_status"' \
    > "$shim_dir/rmdir" || exit 1
  chmod 755 "$shim_dir/rmdir" || exit 1
}

printf 'fixtures are retained under /tmp/luna-loop-test.* for inspection\n'

# An empty installation has no active driver.
new_fixture
run_installer "$REPO_ROOT/who_is_driving.sh"
assert_status "empty installation has a determinate status" 0
assert_output "empty installation reports nobody" "Nobody is driving."

# Round trip, idempotence, exact receipts, unrelated-skill preservation, and
# proof that the installer checks tool presence without executing either tool.
new_fixture
mkdir -p "$CASE_HOME/.agents/skills/unrelated" || exit 1
printf 'keep\n' > "$CASE_HOME/.agents/skills/unrelated/owner.txt" || exit 1
make_tool_shims "$FIXTURE_ROOT/bin" "$FIXTURE_ROOT/tool-calls"
test_path="$FIXTURE_ROOT/bin:$PATH"
run_installer_with_path "$REPO_ROOT/install_claude_main.sh" "$test_path"
assert_status "Claude-main fresh install" 0
assert_true "Claude-main receipts" assert_mode_receipts \
  "$CASE_CLAUDE/skills" claude-main claude-v1 $CLAUDE_TARGETS
run_installer_with_path "$REPO_ROOT/who_is_driving.sh" "$test_path"
assert_status "Claude-main status is valid" 0
assert_output "status reports Claude-main" "Claude is driving."
assert_false "install does not execute either model CLI" test -e "$FIXTURE_ROOT/tool-calls"
run_installer_with_path "$REPO_ROOT/install_claude_main.sh" "$test_path"
assert_status "Claude-main reinstall is idempotent" 0
run_installer_with_path "$REPO_ROOT/install_codex_main.sh" "$test_path"
assert_status "switch Claude-main to Codex-main" 0
assert_true "Codex-main receipts" assert_mode_receipts \
  "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS
run_installer_with_path "$REPO_ROOT/who_is_driving.sh" "$test_path"
assert_status "Codex-main status is valid" 0
assert_output "status reports Codex-main" "Codex is driving."
assert_false "installed Codex skill is not a symlink" \
  test -L "$CASE_HOME/.agents/skills/loop-spec"
assert_true "installed Codex skill is a byte-for-byte copy" cmp -s \
  "$REPO_ROOT/codex_main_driver/skills/loop-spec/SKILL.md" \
  "$CASE_HOME/.agents/skills/loop-spec/SKILL.md"
assert_true "unrelated Codex skill survives" \
  test -f "$CASE_HOME/.agents/skills/unrelated/owner.txt"
assert_false "inactive Claude loop removed" test -e "$CASE_CLAUDE/skills/loop-spec"
run_installer_with_path "$REPO_ROOT/install_claude_main.sh" "$test_path"
assert_status "switch Codex-main back to Claude-main" 0
assert_false "inactive Opus skill removed" test -e "$CASE_HOME/.agents/skills/opus"
assert_true "unrelated skill survives both directions" \
  test -f "$CASE_HOME/.agents/skills/unrelated/owner.txt"

# Migrate the original installer format: exact SKILL.md plus an empty marker.
new_fixture
mkdir "$CASE_CLAUDE/skills" || exit 1
for legacy_skill in $CLAUDE_TARGETS; do
  mkdir "$CASE_CLAUDE/skills/$legacy_skill" || exit 1
  cp "$REPO_ROOT/claude_main_driver/skills/$legacy_skill/SKILL.md" \
    "$CASE_CLAUDE/skills/$legacy_skill/SKILL.md" || exit 1
  : > "$CASE_CLAUDE/skills/$legacy_skill/.luna-loop"
done
run_installer "$REPO_ROOT/who_is_driving.sh"
assert_status "legacy Claude status is valid" 0
assert_output "legacy pack reports Claude-main" "Claude is driving."
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "legacy Claude pack switches to Codex-main" 0
assert_false "legacy Claude pack removed exactly" test -e "$CASE_CLAUDE/skills/codex"
assert_true "legacy migration installs Codex receipts" assert_mode_receipts \
  "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS

# The legacy marker was never emitted in the Codex user-skill root, so the same
# shape there must be treated as foreign rather than claimed by migration.
new_fixture
mkdir -p "$CASE_HOME/.agents/skills/loop-spec" || exit 1
cp "$REPO_ROOT/claude_main_driver/skills/loop-spec/SKILL.md" \
  "$CASE_HOME/.agents/skills/loop-spec/SKILL.md" || exit 1
: > "$CASE_HOME/.agents/skills/loop-spec/.luna-loop"
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "legacy marker outside Claude root is foreign" 1
assert_true "foreign empty marker remains untouched" \
  test -f "$CASE_HOME/.agents/skills/loop-spec/.luna-loop"

# A foreign target aborts before parent creation or partial installation.
new_fixture
mkdir -p "$CASE_CLAUDE/skills/loop-plan" || exit 1
printf 'owner content\n' > "$CASE_CLAUDE/skills/loop-plan/KEEP" || exit 1
run_installer "$REPO_ROOT/who_is_driving.sh"
assert_status "foreign managed name makes status inconsistent" 1
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "foreign target is a conflict" 1
assert_true "foreign target is untouched" test -f "$CASE_CLAUDE/skills/loop-plan/KEEP"
assert_false "conflict creates no Codex skill parent" test -e "$CASE_HOME/.agents"

# An owned receipt with unexpected content is no longer an exact owned layout.
new_fixture
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "setup exact owned layout" 0
printf 'unexpected\n' > "$CASE_HOME/.agents/skills/loop-spec/EXTRA" || exit 1
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "extra content converts owned target to conflict" 1
assert_true "extra content survives refusal" test -f "$CASE_HOME/.agents/skills/loop-spec/EXTRA"

# Direct symlinks are rejected and never followed.
new_fixture
mkdir "$CASE_CLAUDE/skills" "$FIXTURE_ROOT/outside" || exit 1
printf 'outside\n' > "$FIXTURE_ROOT/outside/keep" || exit 1
ln -s "$FIXTURE_ROOT/outside" "$CASE_CLAUDE/skills/loop-review" || exit 1
run_installer "$REPO_ROOT/install_claude_main.sh"
assert_status "symlink target is a conflict" 1
assert_true "symlink destination remains untouched" test -f "$FIXTURE_ROOT/outside/keep"

# Config roots need independent, non-secret recognition evidence.
new_fixture
rmdir "$CASE_CLAUDE/projects" || exit 1
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "unrecognized Claude root is rejected" 2
assert_false "unrecognized root causes no installation" test -e "$CASE_HOME/.agents"

# Explicit custom config roots are supported after independent recognition.
new_fixture
CASE_CLAUDE="$FIXTURE_ROOT/custom/claude-state"
CASE_CODEX="$FIXTURE_ROOT/custom/codex-state"
mkdir -p "$CASE_CLAUDE/plugins" "$CASE_CODEX/sessions" || exit 1
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "recognized custom Claude and Codex roots are supported" 0
assert_true "custom-root install still uses official Codex user-skill path" \
  assert_mode_receipts "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS

# A prior unresolved transaction is evidence to stop, not debris to ignore.
new_fixture
mkdir -p "$CASE_HOME/.agents/skills/.luna-loop-stage.stale" || exit 1
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "stale transaction directory blocks a new install" 1
assert_true "stale transaction evidence is preserved" \
  test -d "$CASE_HOME/.agents/skills/.luna-loop-stage.stale"
assert_false "stale transaction conflict installs nothing" \
  test -e "$CASE_HOME/.agents/skills/loop-spec"

# A cutover failure after one completed replacement restores the exact old copy.
new_fixture
run_installer "$REPO_ROOT/install_codex_main.sh"
assert_status "rollback setup install" 0
printf '\nrollback-sentinel\n' >> "$CASE_HOME/.agents/skills/loop-interview/SKILL.md" || exit 1
make_failing_mv "$FIXTURE_ROOT/fail-bin" "$FIXTURE_ROOT/mv-count" 3
run_installer_with_path "$REPO_ROOT/install_codex_main.sh" \
  "$FIXTURE_ROOT/fail-bin:$PATH"
assert_status "injected selected cutover failure returns environment error" 2
assert_true "selected cutover rollback restores previous bytes" \
  grep -q '^rollback-sentinel$' "$CASE_HOME/.agents/skills/loop-interview/SKILL.md"
assert_true "selected cutover rollback restores all receipts" assert_mode_receipts \
  "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS
stage_count="$(find "$CASE_HOME/.agents/skills" -mindepth 1 -maxdepth 1 \
  -name '.luna-loop-stage.*' -print | wc -l | tr -d ' ')"
assert_true "successful rollback leaves no transaction directory" test "$stage_count" -eq 0

# If inactive cleanup fails, the new mode stays active and moved old skills are
# restored rather than half-deleted. Exit 3 makes the dual state explicit.
new_fixture
run_installer "$REPO_ROOT/install_claude_main.sh"
assert_status "inactive-cleanup setup install" 0
make_failing_mv "$FIXTURE_ROOT/fail-bin" "$FIXTURE_ROOT/mv-count" 8
run_installer_with_path "$REPO_ROOT/install_codex_main.sh" \
  "$FIXTURE_ROOT/fail-bin:$PATH"
assert_status "injected inactive cleanup failure is explicit partial success" 3
assert_true "new Codex-main mode remains complete" assert_mode_receipts \
  "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS
assert_true "old Claude pack is restored after cleanup failure" assert_mode_receipts \
  "$CASE_CLAUDE/skills" claude-main claude-v1 $CLAUDE_TARGETS
run_installer "$REPO_ROOT/who_is_driving.sh"
assert_status "simultaneously active packs are inconsistent" 1

# A cleanup command that reports failure after completing its exact operation
# must still produce exit 3; function-local state must not erase that receipt.
new_fixture
run_installer "$REPO_ROOT/install_claude_main.sh"
assert_status "cleanup-status setup install" 0
make_post_failing_rmdir "$FIXTURE_ROOT/fail-bin" "$FIXTURE_ROOT/rmdir-count" 7
run_installer_with_path "$REPO_ROOT/install_codex_main.sh" \
  "$FIXTURE_ROOT/fail-bin:$PATH"
assert_status "reported cleanup failure cannot be reset by stage cleanup" 3
assert_true "selected mode is complete after reported cleanup failure" \
  assert_mode_receipts "$CASE_HOME/.agents/skills" codex-main codex-v1 $CODEX_TARGETS

# Bad invocations and a missing tool are stable, documented failures.
new_fixture
run_installer "$REPO_ROOT/install_codex_main.sh" unexpected
assert_status "public installer rejects arguments" 64
run_installer "$REPO_ROOT/who_is_driving.sh" unexpected
assert_status "status script rejects arguments" 64
run_installer_with_path "$REPO_ROOT/install_codex_main.sh" "/usr/bin:/bin"
assert_status "missing model CLI is an environment failure" 2

# The installer source itself must contain no recursive deletion mechanism.
if rg -n 'rm[[:space:]]+-[^[:space:]]*[rR]|find.*-delete' \
    "$REPO_ROOT/install_claude_main.sh" \
    "$REPO_ROOT/install_codex_main.sh" \
    "$REPO_ROOT/installer/install_driver.sh" > "$LAST_OUTPUT" 2>&1; then
  fail "installer contains no recursive deletion mechanism"
else
  pass "installer contains no recursive deletion mechanism"
fi

printf 'passes=%s failures=%s\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
