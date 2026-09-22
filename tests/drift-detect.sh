#!/usr/bin/env bash
# Exercise drift/detect.sh with fake, read-only commands in a temporary root.
# This does not test real mise/Homebrew state or mutate the repository/home.
set -euo pipefail

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/drift-detect.XXXXXX")"
FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$FAKE_BIN"
trap 'rm -rf "$TEST_ROOT"' EXIT

printf '%s\n' '# temporary config used only by this harness' >"$TEST_ROOT/mise.toml"
mkdir -p "$TEST_ROOT/brew"
printf '%s\n' 'cask "synthetic-cask"' >"$TEST_ROOT/brew/Brewfile.casks"
printf '%s\n' 'cask "synthetic-font"' >"$TEST_ROOT/brew/Brewfile.fonts"

cat >"$FAKE_BIN/git" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat >"$FAKE_BIN/mise" <<'EOF'
#!/usr/bin/env bash
if [ "${MISE_TEST_MODE:-drift}" = "failure" ] && [ "$1" = bootstrap ]; then
  printf '%s\n' 'synthetic mise failure' >&2
  exit 2
fi
if [ "$1" = bootstrap ]; then
  printf '%s\n' 'synthetic missing bootstrap item'
  exit 1
fi
exit 0
EOF
cat >"$FAKE_BIN/brew" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = bundle ] && [ "$2" = check ]; then
  case "${BREW_TEST_MODE:-pass}:$*" in
    stderr-drift:*Brewfile.casks|stderr-drift:*Brewfile.fonts)
      printf '%s\n' 'The following dependencies are not installed:' '  synthetic package' >&2
      printf '%s\n' 'Warning: verified parameter warning' >&2
      exit 1
      ;;
    failure:*Brewfile.casks)
      printf '%s\n' 'Error: synthetic brew command failure' >&2
      exit 2
      ;;
  esac
  exit 0
fi
printf '%s\n' 'Error: unexpected fake brew invocation' >&2
exit 2
EOF
chmod +x "$FAKE_BIN/git" "$FAKE_BIN/mise" "$FAKE_BIN/brew"

# Keep common system utilities available while using only the fake commands.
TEST_PATH="$FAKE_BIN:/usr/bin:/bin"
DETECT="$(cd "$(dirname "$0")/.." && pwd -P)/drift/detect.sh"

run_case() {
  MISE_TEST_MODE="$1" BREW_TEST_MODE="${2:-pass}" PATH="$TEST_PATH" TMPDIR="$TEST_ROOT" \
    MISE_CONFIG_ROOT="$TEST_ROOT" bash "$DETECT"
}

drift_output="$(run_case drift)"
case "$drift_output" in
  *"mise bootstrap items are missing or differ"*) : ;;
  *) printf '%s\n' "$drift_output"; echo "missing expected mise drift report" >&2; exit 1 ;;
esac

failure_output="$(run_case failure)"
case "$failure_output" in
  *"Unable to complete mise bootstrap status check failed"*) : ;;
  *) printf '%s\n' "$failure_output"; echo "missing expected mise check failure report" >&2; exit 1 ;;
esac

brew_drift_output="$(run_case clean stderr-drift)"
case "$brew_drift_output" in
  *"Cask Brewfile has missing packages"*"Font Brewfile has missing packages"*) : ;;
  *) printf '%s\n' "$brew_drift_output"; echo "missing expected Homebrew stderr drift report" >&2; exit 1 ;;
esac
case "$brew_drift_output" in
  *"Unable to complete Cask Brewfile check failed"*|*"Unable to complete Font Brewfile check failed"*)
    printf '%s\n' "$brew_drift_output"; echo "normal Homebrew drift was reported as a check failure" >&2; exit 1 ;;
  *) : ;;
esac

brew_failure_output="$(run_case clean failure)"
case "$brew_failure_output" in
  *"Unable to complete Cask Brewfile check failed"*) : ;;
  *) printf '%s\n' "$brew_failure_output"; echo "missing expected Homebrew check failure report" >&2; exit 1 ;;
esac
echo "Validated Homebrew stderr drift, Homebrew failure, and existing mise drift/failure"
