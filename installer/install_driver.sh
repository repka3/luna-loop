#!/usr/bin/env bash
# Shared luna-loop installer. Public entry points pass exactly one mode.
#
# Exit codes:
#   0  selected mode installed and inactive mode removed
#   1  ownership/layout conflict; no change
#   2  environment, staging, cutover, or rollback failure
#   3  selected mode is active, but inactive-mode cleanup was incomplete
#   64 internal/public argument error
set -u

MARKER=".luna-loop"
RECEIPT_HEADER="luna-loop-receipt-v2"
COMMON_TARGETS="loop-interview loop-spec loop-plan loop-review loop-execute"
CLAUDE_TARGETS="$COMMON_TARGETS codex"
CODEX_TARGETS="$COMMON_TARGETS opus"
ALL_TARGETS="$COMMON_TARGETS codex opus"

say_error() {
  echo "luna-loop: $*" >&2
}

fail_environment() {
  say_error "$*"
  exit 2
}

is_absolute() {
  case "$1" in
    /*) return 0 ;;
    *) return 1 ;;
  esac
}

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

plain_dir() {
  [ -d "$1" ] && [ ! -L "$1" ]
}

plain_file() {
  [ -f "$1" ] && [ ! -L "$1" ]
}

entry_count() {
  local count_dir="$1"
  local count_value=0
  local count_entry
  for count_entry in "$count_dir"/* "$count_dir"/.[!.]* "$count_dir"/..?*; do
    if path_exists "$count_entry"; then
      count_value=$((count_value + 1))
    fi
  done
  printf '%s\n' "$count_value"
}

receipt_text() {
  printf '%s\nmode=%s\nskill=%s\nlayout=%s\n' \
    "$RECEIPT_HEADER" "$1" "$2" "$3"
}

marker_is_current() {
  local marker_path="$1/$MARKER"
  local marker_mode="$2"
  local marker_skill="$3"
  local marker_layout="$4"
  plain_file "$marker_path" || return 1
  [ "$(cat "$marker_path" 2>/dev/null)" = \
    "$(receipt_text "$marker_mode" "$marker_skill" "$marker_layout")" ]
}

marker_is_legacy() {
  local marker_path="$1/$MARKER"
  plain_file "$marker_path" && [ ! -s "$marker_path" ]
}

layout_is_claude() {
  local layout_dir="$1"
  [ "$(entry_count "$layout_dir")" = "2" ] || return 1
  plain_file "$layout_dir/SKILL.md" || return 1
  plain_file "$layout_dir/$MARKER" || return 1
}

layout_is_codex() {
  local layout_dir="$1"
  [ "$(entry_count "$layout_dir")" = "3" ] || return 1
  plain_file "$layout_dir/SKILL.md" || return 1
  plain_file "$layout_dir/$MARKER" || return 1
  plain_dir "$layout_dir/agents" || return 1
  [ "$(entry_count "$layout_dir/agents")" = "1" ] || return 1
  plain_file "$layout_dir/agents/openai.yaml" || return 1
}

source_layout_is_claude() {
  local source_dir="$1"
  local source_skill="$2"
  local first_line
  plain_dir "$source_dir" || return 1
  [ "$(entry_count "$source_dir")" = "1" ] || return 1
  plain_file "$source_dir/SKILL.md" || return 1
  first_line="$(sed -n '1p' "$source_dir/SKILL.md" 2>/dev/null)"
  [ "$first_line" = "---" ] || return 1
  grep -Eq "^name:[[:space:]]*$source_skill[[:space:]]*$" \
    "$source_dir/SKILL.md" 2>/dev/null
}

source_layout_is_codex() {
  local source_dir="$1"
  local source_skill="$2"
  local first_line
  plain_dir "$source_dir" || return 1
  [ "$(entry_count "$source_dir")" = "2" ] || return 1
  plain_file "$source_dir/SKILL.md" || return 1
  plain_dir "$source_dir/agents" || return 1
  [ "$(entry_count "$source_dir/agents")" = "1" ] || return 1
  plain_file "$source_dir/agents/openai.yaml" || return 1
  first_line="$(sed -n '1p' "$source_dir/SKILL.md" 2>/dev/null)"
  [ "$first_line" = "---" ] || return 1
  grep -Eq "^name:[[:space:]]*$source_skill[[:space:]]*$" \
    "$source_dir/SKILL.md" 2>/dev/null
}

owned_layout() {
  local owned_dir="$1"
  local owned_skill="$2"
  local owned_allow_legacy="$3"

  if marker_is_current "$owned_dir" claude-main "$owned_skill" claude-v1 \
      && layout_is_claude "$owned_dir"; then
    printf '%s\n' claude-v1
    return 0
  fi
  if marker_is_current "$owned_dir" codex-main "$owned_skill" codex-v1 \
      && layout_is_codex "$owned_dir"; then
    printf '%s\n' codex-v1
    return 0
  fi
  if [ "$owned_allow_legacy" = yes ]; then
    case " $CLAUDE_TARGETS " in
      *" $owned_skill "*)
        if marker_is_legacy "$owned_dir" && layout_is_claude "$owned_dir"; then
          printf '%s\n' legacy-claude-v1
          return 0
        fi
        ;;
    esac
  fi
  return 1
}

remove_exact_owned_dir() {
  local remove_dir="$1"
  local remove_skill="$2"
  local remove_allow_legacy="$3"
  local remove_layout
  remove_layout="$(owned_layout "$remove_dir" "$remove_skill" \
    "$remove_allow_legacy")" || return 1

  case "$remove_layout" in
    claude-v1|legacy-claude-v1)
      rm "$remove_dir/SKILL.md" || return 1
      rm "$remove_dir/$MARKER" || return 1
      rmdir "$remove_dir" || return 1
      ;;
    codex-v1)
      rm "$remove_dir/SKILL.md" || return 1
      rm "$remove_dir/agents/openai.yaml" || return 1
      rmdir "$remove_dir/agents" || return 1
      rm "$remove_dir/$MARKER" || return 1
      rmdir "$remove_dir" || return 1
      ;;
    *) return 1 ;;
  esac
}

remove_staged_dir() {
  local staged_dir="$1"
  local staged_mode="$2"
  local staged_skill="$3"
  if [ "$staged_mode" = claude-main ]; then
    marker_is_current "$staged_dir" claude-main "$staged_skill" claude-v1 \
      && layout_is_claude "$staged_dir" || return 1
    rm "$staged_dir/SKILL.md" || return 1
    rm "$staged_dir/$MARKER" || return 1
    rmdir "$staged_dir" || return 1
  else
    marker_is_current "$staged_dir" codex-main "$staged_skill" codex-v1 \
      && layout_is_codex "$staged_dir" || return 1
    rm "$staged_dir/SKILL.md" || return 1
    rm "$staged_dir/agents/openai.yaml" || return 1
    rmdir "$staged_dir/agents" || return 1
    rm "$staged_dir/$MARKER" || return 1
    rmdir "$staged_dir" || return 1
  fi
}

validate_selected_dir() {
  local selected_dir="$1"
  local selected_skill="$2"
  if [ "$MODE" = claude-main ]; then
    marker_is_current "$selected_dir" claude-main "$selected_skill" claude-v1 \
      && layout_is_claude "$selected_dir"
  else
    marker_is_current "$selected_dir" codex-main "$selected_skill" codex-v1 \
      && layout_is_codex "$selected_dir"
  fi
}

rollback_selected() {
  local rollback_failed=0
  local rollback_skill rollback_dest rollback_new rollback_old rollback_had
  for rollback_skill in $SELECTED_TARGETS; do
    rollback_dest="$SELECTED_SKILLS/$rollback_skill"
    rollback_new="$STAGE_ROOT/new/$rollback_skill"
    rollback_old="$STAGE_ROOT/old/$rollback_skill"
    rollback_had="$STAGE_ROOT/had-$rollback_skill"

    # Same-filesystem directory renames are atomic. A missing staged-new
    # directory proves that the new copy reached its destination; a present
    # staged-old directory proves that the previous copy moved aside.
    if [ ! -d "$rollback_new" ] && path_exists "$rollback_dest"; then
      if validate_selected_dir "$rollback_dest" "$rollback_skill"; then
        remove_staged_dir "$rollback_dest" "$MODE" "$rollback_skill" \
          || rollback_failed=1
      else
        rollback_failed=1
      fi
    fi
    if [ -f "$rollback_had" ] && [ -d "$rollback_old" ]; then
      if path_exists "$rollback_dest" || [ ! -d "$rollback_old" ]; then
        rollback_failed=1
      else
        mv "$rollback_old" "$rollback_dest" || rollback_failed=1
      fi
    fi
  done
  [ "$rollback_failed" -eq 0 ]
}

cleanup_stage_shell() {
  local cleanup_failed=0
  local cleanup_skill cleanup_new cleanup_old cleanup_had
  for cleanup_skill in $SELECTED_TARGETS; do
    cleanup_new="$STAGE_ROOT/new/$cleanup_skill"
    cleanup_old="$STAGE_ROOT/old/$cleanup_skill"
    cleanup_had="$STAGE_ROOT/had-$cleanup_skill"
    if [ -d "$cleanup_new" ]; then
      remove_staged_dir "$cleanup_new" "$MODE" "$cleanup_skill" \
        || cleanup_failed=1
    fi
    if [ -d "$cleanup_old" ]; then
      remove_exact_owned_dir "$cleanup_old" "$cleanup_skill" \
        "$SELECTED_ALLOW_LEGACY" \
        || cleanup_failed=1
    fi
    if [ -f "$cleanup_had" ] && [ ! -L "$cleanup_had" ]; then
      rm "$cleanup_had" || cleanup_failed=1
    fi
  done
  rmdir "$STAGE_ROOT/new" 2>/dev/null || cleanup_failed=1
  rmdir "$STAGE_ROOT/old" 2>/dev/null || cleanup_failed=1
  rmdir "$STAGE_ROOT" 2>/dev/null || cleanup_failed=1
  [ "$cleanup_failed" -eq 0 ]
}

if [ "$#" -ne 1 ]; then
  say_error "internal usage: install_driver.sh claude-main|codex-main"
  exit 64
fi
MODE="$1"
case "$MODE" in
  claude-main)
    SELECTED_TARGETS="$CLAUDE_TARGETS"
    INACTIVE_TARGETS="$CODEX_TARGETS"
    SOURCE_BRANCH="claude_main_driver"
    SELECTED_LAYOUT="claude-v1"
    ;;
  codex-main)
    SELECTED_TARGETS="$CODEX_TARGETS"
    INACTIVE_TARGETS="$CLAUDE_TARGETS"
    SOURCE_BRANCH="codex_main_driver"
    SELECTED_LAYOUT="codex-v1"
    ;;
  *)
    say_error "unknown internal mode: $MODE"
    exit 64
    ;;
esac

command -v claude >/dev/null 2>&1 \
  || fail_environment "Claude CLI was not found on PATH. Install and authenticate it first."
command -v codex >/dev/null 2>&1 \
  || fail_environment "Codex CLI was not found on PATH. Install and authenticate it first."

[ -n "${HOME:-}" ] || fail_environment "HOME is unset."
is_absolute "$HOME" || fail_environment "HOME must be absolute: $HOME"
plain_dir "$HOME" || fail_environment "HOME is not an ordinary directory: $HOME"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)" \
  || fail_environment "Cannot resolve the installer directory."
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)" \
  || fail_environment "Cannot resolve the repository root."
SOURCE_ROOT="$REPO_ROOT/$SOURCE_BRANCH/skills"
plain_dir "$SOURCE_ROOT" \
  || fail_environment "Missing source skill directory: $SOURCE_ROOT"

CLAUDE_ROOT="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_ROOT="${CODEX_HOME:-$HOME/.codex}"
is_absolute "$CLAUDE_ROOT" \
  || fail_environment "CLAUDE_CONFIG_DIR must be absolute: $CLAUDE_ROOT"
is_absolute "$CODEX_ROOT" \
  || fail_environment "CODEX_HOME must be absolute: $CODEX_ROOT"
plain_dir "$CLAUDE_ROOT" \
  || fail_environment "Claude config root is not an ordinary directory: $CLAUDE_ROOT"
plain_dir "$CODEX_ROOT" \
  || fail_environment "Codex config root is not an ordinary directory: $CODEX_ROOT"

CLAUDE_ROOT="$(cd "$CLAUDE_ROOT" && pwd -P)" \
  || fail_environment "Cannot resolve Claude config root."
CODEX_ROOT="$(cd "$CODEX_ROOT" && pwd -P)" \
  || fail_environment "Cannot resolve Codex config root."
HOME_PHYSICAL="$(cd "$HOME" && pwd -P)" \
  || fail_environment "Cannot resolve HOME."

[ "$CLAUDE_ROOT" != "/" ] && [ "$CLAUDE_ROOT" != "$HOME_PHYSICAL" ] \
  || fail_environment "Refusing a broad Claude config root: $CLAUDE_ROOT"
[ "$CODEX_ROOT" != "/" ] && [ "$CODEX_ROOT" != "$HOME_PHYSICAL" ] \
  || fail_environment "Refusing a broad Codex config root: $CODEX_ROOT"

case "$CLAUDE_ROOT/" in
  "$CODEX_ROOT/"*) fail_environment "Claude and Codex config roots overlap." ;;
esac
case "$CODEX_ROOT/" in
  "$CLAUDE_ROOT/"*) fail_environment "Claude and Codex config roots overlap." ;;
esac

claude_recognized=0
plain_file "$CLAUDE_ROOT/settings.json" && claude_recognized=1
plain_file "$CLAUDE_ROOT/CLAUDE.md" && claude_recognized=1
plain_dir "$CLAUDE_ROOT/projects" && claude_recognized=1
plain_dir "$CLAUDE_ROOT/plugins" && claude_recognized=1
[ "$claude_recognized" -eq 1 ] \
  || fail_environment "Claude config root is not recognized: $CLAUDE_ROOT"

codex_recognized=0
plain_file "$CODEX_ROOT/config.toml" && codex_recognized=1
plain_file "$CODEX_ROOT/AGENTS.md" && codex_recognized=1
plain_dir "$CODEX_ROOT/sessions" && codex_recognized=1
[ "$codex_recognized" -eq 1 ] \
  || fail_environment "Codex config root is not recognized: $CODEX_ROOT"

CLAUDE_SKILLS="$CLAUDE_ROOT/skills"
AGENTS_ROOT="$HOME_PHYSICAL/.agents"
CODEX_SKILLS="$AGENTS_ROOT/skills"

for checked_dir in "$CLAUDE_SKILLS" "$AGENTS_ROOT" "$CODEX_SKILLS"; do
  if path_exists "$checked_dir" && ! plain_dir "$checked_dir"; then
    fail_environment "Expected an ordinary directory, not a file or symlink: $checked_dir"
  fi
done

case "$CLAUDE_SKILLS/" in
  "$CODEX_SKILLS/"*) fail_environment "Claude and Codex skill roots overlap." ;;
esac
case "$CODEX_SKILLS/" in
  "$CLAUDE_SKILLS/"*) fail_environment "Claude and Codex skill roots overlap." ;;
esac

if [ "$MODE" = claude-main ]; then
  SELECTED_SKILLS="$CLAUDE_SKILLS"
  INACTIVE_SKILLS="$CODEX_SKILLS"
  SELECTED_ALLOW_LEGACY=yes
  INACTIVE_ALLOW_LEGACY=no
else
  SELECTED_SKILLS="$CODEX_SKILLS"
  INACTIVE_SKILLS="$CLAUDE_SKILLS"
  SELECTED_ALLOW_LEGACY=no
  INACTIVE_ALLOW_LEGACY=yes
fi

for source_skill in $SELECTED_TARGETS; do
  source_path="$SOURCE_ROOT/$source_skill"
  if [ "$MODE" = claude-main ]; then
    source_layout_is_claude "$source_path" "$source_skill" \
      || fail_environment "Invalid Claude-main source layout: $source_path"
  else
    source_layout_is_codex "$source_path" "$source_skill" \
      || fail_environment "Invalid Codex-main source layout: $source_path"
  fi
done

# Preflight every name this installer owns in both ecosystems before mkdir or copy.
conflicts=0
for target_root in "$CLAUDE_SKILLS" "$CODEX_SKILLS"; do
  for stale_stage in "$target_root"/.luna-loop-stage.*; do
    if path_exists "$stale_stage"; then
      say_error "conflict: unresolved prior transaction at $stale_stage"
      conflicts=1
    fi
  done
  if [ "$target_root" = "$CLAUDE_SKILLS" ]; then
    target_allow_legacy=yes
  else
    target_allow_legacy=no
  fi
  for target_skill in $ALL_TARGETS; do
    target_path="$target_root/$target_skill"
    if path_exists "$target_path"; then
      if ! plain_dir "$target_path" \
          || ! owned_layout "$target_path" "$target_skill" \
            "$target_allow_legacy" >/dev/null; then
        say_error "conflict: $target_path is foreign or has an unexpected layout"
        conflicts=1
      fi
    fi
  done
done
if [ "$conflicts" -ne 0 ]; then
  say_error "Nothing changed. Resolve the conflicts above and rerun."
  exit 1
fi

# Root recognition and all conflicts are settled; creating missing skill parents is safe.
if [ ! -d "$CLAUDE_SKILLS" ]; then
  mkdir "$CLAUDE_SKILLS" \
    || fail_environment "Cannot create Claude skills directory: $CLAUDE_SKILLS"
fi
if [ ! -d "$AGENTS_ROOT" ]; then
  mkdir "$AGENTS_ROOT" \
    || fail_environment "Cannot create Codex user-data directory: $AGENTS_ROOT"
fi
if [ ! -d "$CODEX_SKILLS" ]; then
  mkdir "$CODEX_SKILLS" \
    || fail_environment "Cannot create Codex skills directory: $CODEX_SKILLS"
fi

STAGE_ROOT="$(mktemp -d "$SELECTED_SKILLS/.luna-loop-stage.XXXXXX")" \
  || fail_environment "Cannot create a same-filesystem staging directory."
mkdir "$STAGE_ROOT/new" "$STAGE_ROOT/old" || {
  rmdir "$STAGE_ROOT" 2>/dev/null
  fail_environment "Cannot initialize staging directory: $STAGE_ROOT"
}

stage_failed=0
for stage_skill in $SELECTED_TARGETS; do
  stage_source="$SOURCE_ROOT/$stage_skill"
  stage_dest="$STAGE_ROOT/new/$stage_skill"
  mkdir "$stage_dest" || { stage_failed=1; break; }
  if [ "$MODE" = claude-main ]; then
    cp "$stage_source/SKILL.md" "$stage_dest/SKILL.md" || { stage_failed=1; break; }
    cmp -s "$stage_source/SKILL.md" "$stage_dest/SKILL.md" \
      || { stage_failed=1; break; }
  else
    mkdir "$stage_dest/agents" || { stage_failed=1; break; }
    cp "$stage_source/SKILL.md" "$stage_dest/SKILL.md" || { stage_failed=1; break; }
    cp "$stage_source/agents/openai.yaml" "$stage_dest/agents/openai.yaml" \
      || { stage_failed=1; break; }
    cmp -s "$stage_source/SKILL.md" "$stage_dest/SKILL.md" \
      || { stage_failed=1; break; }
    cmp -s "$stage_source/agents/openai.yaml" "$stage_dest/agents/openai.yaml" \
      || { stage_failed=1; break; }
  fi
  receipt_text "$MODE" "$stage_skill" "$SELECTED_LAYOUT" \
    > "$stage_dest/$MARKER" || { stage_failed=1; break; }
  validate_selected_dir "$stage_dest" "$stage_skill" \
    || { stage_failed=1; break; }
done

if [ "$stage_failed" -ne 0 ]; then
  say_error "Staging failed before cutover."
  cleanup_stage_shell \
    || say_error "Manual cleanup may be needed at: $STAGE_ROOT"
  exit 2
fi

cutover_failed=0
for cutover_skill in $SELECTED_TARGETS; do
  cutover_dest="$SELECTED_SKILLS/$cutover_skill"
  cutover_new="$STAGE_ROOT/new/$cutover_skill"
  cutover_old="$STAGE_ROOT/old/$cutover_skill"
  if path_exists "$cutover_dest"; then
    : > "$STAGE_ROOT/had-$cutover_skill" || { cutover_failed=1; break; }
    mv "$cutover_dest" "$cutover_old" || { cutover_failed=1; break; }
  fi
  mv "$cutover_new" "$cutover_dest" || { cutover_failed=1; break; }
  validate_selected_dir "$cutover_dest" "$cutover_skill" \
    || { cutover_failed=1; break; }
done

if [ "$cutover_failed" -ne 0 ]; then
  say_error "Selected-mode cutover failed; rolling back."
  if rollback_selected && cleanup_stage_shell; then
    say_error "Rollback completed; the previous state is restored."
  else
    say_error "Rollback was incomplete. Inspect exact staging path: $STAGE_ROOT"
  fi
  exit 2
fi

for verify_skill in $SELECTED_TARGETS; do
  validate_selected_dir "$SELECTED_SKILLS/$verify_skill" "$verify_skill" || {
    say_error "Post-cutover validation failed; rolling back."
    if rollback_selected && cleanup_stage_shell; then
      say_error "Rollback completed; the previous state is restored."
    else
      say_error "Rollback was incomplete. Inspect exact staging path: $STAGE_ROOT"
    fi
    exit 2
  }
done

# The selected mode is proven active. Only now move the inactive pack aside.
QUARANTINE="$STAGE_ROOT/inactive"
mkdir "$QUARANTINE" || {
  say_error "Selected mode is active, but inactive cleanup could not be staged."
  if ! cleanup_stage_shell; then
    say_error "Inspect leftover staging content under: $STAGE_ROOT"
  fi
  exit 3
}
inactive_move_failed=0
for inactive_skill in $INACTIVE_TARGETS; do
  inactive_path="$INACTIVE_SKILLS/$inactive_skill"
  if path_exists "$inactive_path"; then
    mv "$inactive_path" "$QUARANTINE/$inactive_skill" \
      || { inactive_move_failed=1; break; }
  fi
done

if [ "$inactive_move_failed" -ne 0 ]; then
  inactive_rollback_failed=0
  for inactive_skill in $INACTIVE_TARGETS; do
    quarantined_path="$QUARANTINE/$inactive_skill"
    if [ -d "$quarantined_path" ]; then
      mv "$quarantined_path" "$INACTIVE_SKILLS/$inactive_skill" \
        || inactive_rollback_failed=1
    fi
  done
  say_error "Selected mode is active, but inactive cleanup failed."
  [ "$inactive_rollback_failed" -ne 0 ] \
    && say_error "Some inactive skills remain under: $QUARANTINE"
  rmdir "$QUARANTINE" 2>/dev/null || true
  if ! cleanup_stage_shell; then
    say_error "Inspect leftover staging content under: $STAGE_ROOT"
  fi
  exit 3
fi

cleanup_failed=0
for inactive_skill in $INACTIVE_TARGETS; do
  quarantined_path="$QUARANTINE/$inactive_skill"
  if [ -d "$quarantined_path" ]; then
    remove_exact_owned_dir "$quarantined_path" "$inactive_skill" \
      "$INACTIVE_ALLOW_LEGACY" \
      || cleanup_failed=1
  fi
done
rmdir "$QUARANTINE" 2>/dev/null || cleanup_failed=1

if ! cleanup_stage_shell; then
  cleanup_failed=1
fi

if [ "$cleanup_failed" -ne 0 ]; then
  say_error "Selected mode is active, but exact cleanup was incomplete."
  say_error "Inspect leftover staging content under: $STAGE_ROOT"
  exit 3
fi

echo "luna-loop mode installed: $MODE"
echo "skills: $SELECTED_SKILLS"
echo "The installed copies are self-contained; this repository may be removed."
exit 0
