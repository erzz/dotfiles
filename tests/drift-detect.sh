#!/usr/bin/env bash
# Exercise drift/detect.sh with fake, read-only commands in a temporary root.
# This does not test real mise/Homebrew state or mutate the repository/home.
set -euo pipefail

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/drift-detect.XXXXXX")"
FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$FAKE_BIN"
trap 'rm -rf "$TEST_ROOT"' EXIT

printf '%s\n' '# temporary config used only by this harness' >"$TEST_ROOT/mise.toml"

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
chmod +x "$FAKE_BIN/git" "$FAKE_BIN/mise"

# Keep common system utilities available while excluding typical Homebrew
# locations. Thus the detector must report brew as unavailable.
TEST_PATH="$FAKE_BIN:/usr/bin:/bin"
DETECT="$(cd "$(dirname "$0")/.." && pwd -P)/drift/detect.sh"

run_case() {
  MISE_TEST_MODE="$1" PATH="$TEST_PATH" TMPDIR="$TEST_ROOT" \
    MISE_CONFIG_ROOT="$TEST_ROOT" bash "$DETECT"
}

drift_output="$(run_case drift)"
case "$drift_output" in
  *"mise bootstrap items are missing or differ"*) : ;;
  *) printf '%s\n' "$drift_output"; echo "missing expected mise drift report" >&2; exit 1 ;;
esac
case "$drift_output" in
  *"Unable to complete brew is unavailable"*) : ;;
  *) printf '%s\n' "$drift_output"; echo "missing expected brew failure report" >&2; exit 1 ;;
esac

failure_output="$(run_case failure)"
case "$failure_output" in
  *"Unable to complete mise bootstrap status check failed"*) : ;;
  *) printf '%s\n' "$failure_output"; echo "missing expected mise check failure report" >&2; exit 1 ;;
esac
echo "Validated drift reporting for expected mise drift, mise failure, and missing brew"
