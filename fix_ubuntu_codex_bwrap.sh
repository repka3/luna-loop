#!/usr/bin/env bash
# Repair Codex's Bubblewrap sandbox on Ubuntu 24.04 without disabling
# AppArmor's unprivileged-user-namespace restriction globally.
set -eu

SOURCE_PROFILE="/usr/share/apparmor/extra-profiles/bwrap-userns-restrict"
TARGET_PROFILE="/etc/apparmor.d/bwrap-userns-restrict"

fail() {
  printf 'codex-bwrap-fix: %s\n' "$*" >&2
  exit 1
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

if [ "$#" -ne 0 ]; then
  printf 'usage: %s\n' "$0" >&2
  exit 64
fi

[ -r /etc/os-release ] || fail "cannot read /etc/os-release"

# shellcheck disable=SC1091
. /etc/os-release

[ "${ID:-}" = "ubuntu" ] || fail "this repair is only for Ubuntu"
[ "${VERSION_ID:-}" = "24.04" ] ||
  fail "this repair is intentionally limited to Ubuntu 24.04; found ${VERSION_ID:-unknown}"

command -v apt-get >/dev/null 2>&1 || fail "apt-get is unavailable"
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null 2>&1 || fail "sudo is unavailable; run this script as root"
fi

printf '%s\n' \
  "This will make these host-system changes:" \
  "  1. Refresh Ubuntu package indexes." \
  "  2. Install Ubuntu's bubblewrap, apparmor-profiles, and apparmor-utils packages." \
  "  3. Copy the packaged bwrap-userns-restrict profile to:" \
  "       $TARGET_PROFILE" \
  "     only if that destination is absent or already identical." \
  "  4. Load that AppArmor profile into the running kernel." \
  "" \
  "It will NOT disable kernel.apparmor_restrict_unprivileged_userns."

if [ ! -t 0 ]; then
  fail "interactive confirmation is required; run this script from a terminal"
fi

printf 'Continue? [y/N] '
read -r answer
case "$answer" in
  y|Y|yes|YES|Yes) ;;
  *) printf '%s\n' "No changes made."; exit 0 ;;
esac

if [ "$(id -u)" -ne 0 ]; then
  printf '%s\n' "Requesting sudo authorization for the package and AppArmor changes."
  sudo -v
fi

run_as_root apt-get update
run_as_root apt-get install --yes bubblewrap apparmor-profiles apparmor-utils

[ -f "$SOURCE_PROFILE" ] ||
  fail "Ubuntu's packaged profile is still missing at $SOURCE_PROFILE; no system-wide fallback was applied"

if [ -L "$TARGET_PROFILE" ]; then
  fail "refusing symlink destination $TARGET_PROFILE"
elif [ -e "$TARGET_PROFILE" ]; then
  run_as_root test -f "$TARGET_PROFILE" ||
    fail "refusing to replace non-regular destination $TARGET_PROFILE"
  if ! run_as_root cmp -s "$SOURCE_PROFILE" "$TARGET_PROFILE"; then
    fail "refusing to overwrite a modified $TARGET_PROFILE; inspect it manually"
  fi
  printf '%s\n' "The installed AppArmor profile already matches Ubuntu's packaged profile."
else
  run_as_root install -m 0644 "$SOURCE_PROFILE" "$TARGET_PROFILE"
  printf 'Installed %s\n' "$TARGET_PROFILE"
fi

run_as_root apparmor_parser -r "$TARGET_PROFILE"
printf '%s\n' "Loaded the bwrap AppArmor profile."

command -v bwrap >/dev/null 2>&1 ||
  fail "bubblewrap was installed but bwrap is not on PATH"

if bwrap \
    --ro-bind / / \
    --dev /dev \
    --proc /proc \
    --unshare-user \
    --uid 0 \
    --gid 0 \
    --unshare-net \
    /bin/true; then
  printf '%s\n' \
    "Bubblewrap successfully created user and network namespaces." \
    "Restart Codex (or open a new Codex session) before testing normal sandboxed commands."
else
  fail "the profile loaded, but the Bubblewrap namespace probe still failed; restart Codex and inspect AppArmor denials before changing sysctls"
fi
