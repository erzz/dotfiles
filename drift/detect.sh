#!/usr/bin/env bash
# Check local repository, mise, and native Homebrew state.
#
# This is intentionally an explicit check. It does not fetch, authenticate, or
# prompt for network access, so it is safe to run from a terminal when needed.
#
# Exit contract: detected drift and check failures are reported or flagged but
# this script exits 0 because it may be called by a shell prompt. A successful
# exit must never turn an incomplete check into "Native checks passed.".

COLOUR='\033[0;33m'
NC='\033[0m'
DRIFT_FLAG="${TMPDIR:-/tmp}/dotfiles-drift.${UID}"
DRIFT_TMP="${DRIFT_FLAG}.$$"
CHECK_FAILURES=()

SCRIPT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." 2>/dev/null && pwd -P) || exit 0
ROOT=''
if [ -n "${MISE_CONFIG_ROOT:-}" ] && [ -f "$MISE_CONFIG_ROOT/mise.toml" ]; then
	ROOT="$MISE_CONFIG_ROOT"
elif [ -f "$SCRIPT_ROOT/mise.toml" ]; then
	ROOT="$SCRIPT_ROOT"
fi
[ -d "$ROOT" ] || exit 0
cd "$ROOT" || exit 0

MESSAGES=()

# Local repository state only. In particular, do not fetch or inspect a remote.
GIT_STATUS=$(git status --short 2>/dev/null)
GIT_STATUS_CODE=$?
if [ "$GIT_STATUS_CODE" -ne 0 ]; then
	CHECK_FAILURES+=("git status check failed")
elif [ -n "$GIT_STATUS" ]; then
	MESSAGES+=("${COLOUR}Repository has uncommitted changes${NC}")
fi

if command -v mise >/dev/null 2>&1; then
	# Bootstrap status is read-only. Exit 1 with normal status output means
	# drift; an error or unsupported command must remain a check failure.
	MISE_BOOTSTRAP_STDERR="${DRIFT_TMP}.bootstrap.stderr"
	MISE_BOOTSTRAP_STATUS=$(mise bootstrap status --missing 2>"$MISE_BOOTSTRAP_STDERR")
	MISE_BOOTSTRAP_CODE=$?
	MISE_BOOTSTRAP_ERROR=$(<"$MISE_BOOTSTRAP_STDERR")
	rm -f "$MISE_BOOTSTRAP_STDERR"
	if [ "$MISE_BOOTSTRAP_CODE" -eq 0 ] && [ -n "$MISE_BOOTSTRAP_STATUS" ]; then
		MESSAGES+=("${COLOUR}mise bootstrap items are missing or differ (run: mise run sync)${NC}")
	elif [ "$MISE_BOOTSTRAP_CODE" -eq 1 ] && [ -n "$MISE_BOOTSTRAP_STATUS" ] && [ -z "$MISE_BOOTSTRAP_ERROR" ]; then
		MESSAGES+=("${COLOUR}mise bootstrap items are missing or differ (run: mise run sync)${NC}")
	elif [ "$MISE_BOOTSTRAP_CODE" -ne 0 ]; then
		CHECK_FAILURES+=("mise bootstrap status check failed")
	fi

	MISE_MISSING=$(mise ls --missing 2>/dev/null)
	MISE_MISSING_CODE=$?
	if [ "$MISE_MISSING_CODE" -ne 0 ]; then
		CHECK_FAILURES+=("mise missing-tools check failed")
	elif [ -n "$MISE_MISSING" ]; then
		MESSAGES+=("${COLOUR}mise tools are missing (run: mise install)${NC}")
	fi
else
  CHECK_FAILURES+=("mise is unavailable")
fi

# Casks and fonts remain dedicated native owners. The aggregate Brewfile is
# intentionally not checked here.
BREW_AVAILABLE=1
if ! command -v brew >/dev/null 2>&1; then
	BREW_AVAILABLE=0
	CHECK_FAILURES+=("brew is unavailable")
fi

if [ "$BREW_AVAILABLE" -eq 1 ]; then
	for brewfile in Brewfile.casks Brewfile.fonts; do
		if [ -f "$ROOT/brew/$brewfile" ]; then
			BREW_BUNDLE_STDOUT="${DRIFT_TMP}.${brewfile}.stdout"
			BREW_BUNDLE_STDERR="${DRIFT_TMP}.${brewfile}.stderr"
			brew bundle check --no-upgrade --file="$ROOT/brew/$brewfile" >"$BREW_BUNDLE_STDOUT" 2>"$BREW_BUNDLE_STDERR"
			BREW_BUNDLE_CODE=$?
			BREW_BUNDLE_OUTPUT=$(<"$BREW_BUNDLE_STDOUT")
			BREW_BUNDLE_ERROR=$(<"$BREW_BUNDLE_STDERR")
			rm -f "$BREW_BUNDLE_STDOUT" "$BREW_BUNDLE_STDERR"

			case "$brewfile" in
				Brewfile.casks) label='Cask Brewfile' ;;
				Brewfile.fonts) label='Font Brewfile' ;;
			esac
			# Homebrew may report the normal unmet-dependencies summary on stderr
			# (alongside a verified-parameter warning) and return 1. Recognize the
			# summary itself, rather than treating any stderr as a command failure.
			# Keep this deliberately narrow: an unrecognized non-zero result must
			# remain a failure so that a broken check cannot look like success.
			BREW_BUNDLE_ALL_OUTPUT=$(printf '%s\n%s' "$BREW_BUNDLE_OUTPUT" "$BREW_BUNDLE_ERROR" | tr '\n' ' ')
			BREW_BUNDLE_HAS_MISSING_SUMMARY=0
			if [[ "$BREW_BUNDLE_ALL_OUTPUT" =~ [Ff]ollowing[[:space:]]+(dependencies|packages|casks|formulae|fonts).*([Nn]ot[[:space:]]+installed|[Mm]issing) ]] ||
				[[ "$BREW_BUNDLE_ALL_OUTPUT" =~ [Mm]issing[[:space:]]+(dependencies|packages|casks|formulae|fonts) ]]; then
				BREW_BUNDLE_HAS_MISSING_SUMMARY=1
			fi
			if [ "$BREW_BUNDLE_CODE" -eq 1 ] && [ "$BREW_BUNDLE_HAS_MISSING_SUMMARY" -eq 1 ]; then
				MESSAGES+=("${COLOUR}${label} has missing packages (run: brew bundle check --file=brew/$brewfile)${NC}")
			elif [ "$BREW_BUNDLE_CODE" -ne 0 ]; then
				CHECK_FAILURES+=("$label check failed")
			fi
		fi
	done
fi

if [ "${#CHECK_FAILURES[@]}" -gt 0 ]; then
	for failure in "${CHECK_FAILURES[@]}"; do
		MESSAGES+=("${COLOUR}Unable to complete ${failure}; native state may be unknown${NC}")
	done
fi

if [ "${#MESSAGES[@]}" -gt 0 ]; then
	printf '%b\n' "${MESSAGES[@]}" >"$DRIFT_TMP" && mv -f "$DRIFT_TMP" "$DRIFT_FLAG"
	printf '%b\n' "${MESSAGES[@]}"
else
	rm -f "$DRIFT_FLAG" "$DRIFT_TMP"
	printf '%s\n' 'Native checks passed.'
fi
