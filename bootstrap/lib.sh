# shellcheck shell=bash
# bootstrap/lib.sh — shared helpers for all phase scripts.
#
# Sourced by bootstrap.sh after `set -euo pipefail` is in effect, then
# inherited by each sourced phase file. All functions and colour vars
# defined here are available to every phase.

# ─────────────────────────────────────────────────────────────────────
# Colours
# ─────────────────────────────────────────────────────────────────────

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# ─────────────────────────────────────────────────────────────────────
# Output helpers
# ─────────────────────────────────────────────────────────────────────

phase()   { printf '\n%b==> %s%b\n\n' "${BLUE}" "$*" "${NC}"; }
step()    { printf '%b--> %s%b\n' "${BLUE}" "$*" "${NC}"; }
ok()      { printf '%b    ✓ %s%b\n' "${GREEN}" "$*" "${NC}"; }
warn()    { printf '%b    ! %s%b\n' "${YELLOW}" "$*" "${NC}"; }
fail()    { printf '%b    ✗ %s%b\n' "${RED}" "$*" "${NC}"; exit 1; }

box() {
  local line
  printf '%b┌─ %s ─' "${YELLOW}" "$1"
  for ((i=${#1}; i<60; i++)); do printf '─'; done
  printf '┐%b\n' "${NC}"
  shift
  for line in "$@"; do
    printf '%b│%b %-62s %b│%b\n' "${YELLOW}" "${NC}" "$line" "${YELLOW}" "${NC}"
  done
  printf '%b└' "${YELLOW}"
  for ((i=0; i<64; i++)); do printf '─'; done
  printf '┘%b\n' "${NC}"
}

prompt_continue() {
  printf '\n%bPress ENTER to continue (or Ctrl-C to abort)...%b ' "${YELLOW}" "${NC}"
  read -r _
}

prompt_done() {
  printf '\n%bPress ENTER once you have done the above (or Ctrl-C to abort)...%b ' "${YELLOW}" "${NC}"
  read -r _
}

# ─────────────────────────────────────────────────────────────────────
# Best-effort step wrapper (used by Phase 4 finalisers)
# ─────────────────────────────────────────────────────────────────────
#
# try <label> <cmd...> — run cmd; on failure, warn and record the label.
# Lets a phase keep running through transient failures while still surfacing
# them in a summary at the end.
#
# Note: invoking <cmd> as the condition of `if` disables errexit inside the
# called function. Functions called via `try` should therefore use explicit
# `|| return 1` on probes whose failure must abort the function.

FINALISER_OK=0
FINALISER_WARN=0
FINALISER_FAILS=()

try() {
  local label="$1"; shift
  if "$@"; then
    FINALISER_OK=$((FINALISER_OK + 1))
  else
    warn "step '${label}' failed (exit $?) — continuing"
    FINALISER_WARN=$((FINALISER_WARN + 1))
    FINALISER_FAILS+=("${label}")
  fi
}
