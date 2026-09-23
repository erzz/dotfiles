#!/usr/bin/env bash
# bootstrap.sh — native macOS entry point for the mise dotfiles project.
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' 'This bootstrap is supported on macOS only.' >&2
  exit 1
fi

DOTFILES_DIR="${HOME}/dotfiles"
REPOSITORY_URL='https://github.com/erzz/dotfiles.git'
BOOTSTRAP_BRANCH="${BOOTSTRAP_BRANCH:-}"
ALLOW_DIRTY_DOTFILES="${ALLOW_DIRTY_DOTFILES:-}"

if [ -L "$DOTFILES_DIR" ]; then
  printf '%s\n' "$DOTFILES_DIR is a symlink; refusing canonical-path indirection." >&2
  exit 1
fi

printf '%s\n' '==> Preparing native macOS prerequisites'

# Git is supplied by the Apple Command Line Tools. Do not attempt to bypass
# their GUI installer, since it must be accepted by the user.
selected_developer_dir=''
clang_path=''
if ! selected_developer_dir=$(xcode-select -p 2>/dev/null) \
  || [ ! -d "$selected_developer_dir" ] \
  || ! command -v git >/dev/null 2>&1 \
  || ! clang_path=$(xcrun --find clang 2>/dev/null) \
  || [ ! -x "$clang_path" ]; then
  printf '%s\n' 'Usable Xcode Command Line Tools and Git are required.' >&2
  printf '%s\n' 'Run xcode-select --install, complete the GUI installer, then retry.' >&2
  exit 1
fi

if [ ! -e "$DOTFILES_DIR" ]; then
  printf '%s\n' "==> Acquiring $DOTFILES_DIR"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  clone_args=()
  if [ -n "$BOOTSTRAP_BRANCH" ]; then
    clone_args=(--branch "$BOOTSTRAP_BRANCH")
  fi
  if [ "${#clone_args[@]}" -gt 0 ]; then
    git clone "${clone_args[@]}" "$REPOSITORY_URL" "$DOTFILES_DIR"
  else
    git clone "$REPOSITORY_URL" "$DOTFILES_DIR"
  fi
elif ! checkout_root="$(git -C "$DOTFILES_DIR" rev-parse --show-toplevel 2>/dev/null)" || [ "$(cd "$checkout_root" && pwd -P)" != "$(cd "$DOTFILES_DIR" && pwd -P)" ]; then
  printf '%s\n' "$DOTFILES_DIR exists but is not a Git checkout; refusing to overwrite it." >&2
  exit 1
else
  printf '%s\n' "==> Using existing Git checkout at $DOTFILES_DIR (local changes will not be overwritten)"
  if [ -n "$BOOTSTRAP_BRANCH" ]; then
    current_branch="$(git -C "$DOTFILES_DIR" symbolic-ref --short -q HEAD 2>/dev/null || true)"
    if [ -z "$current_branch" ]; then
      printf '%s\n' "BOOTSTRAP_BRANCH=$BOOTSTRAP_BRANCH was requested, but $DOTFILES_DIR has a detached HEAD." >&2
      exit 1
    fi
    if [ "$current_branch" != "$BOOTSTRAP_BRANCH" ]; then
      printf '%s\n' "BOOTSTRAP_BRANCH=$BOOTSTRAP_BRANCH does not match existing checkout branch $current_branch." >&2
      exit 1
    fi
  fi
fi

origin_url="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
normalized_origin="${origin_url#git@github.com:}"
normalized_origin="${normalized_origin#https://github.com/}"
normalized_origin="${normalized_origin#ssh://git@github.com/}"
normalized_origin="${normalized_origin%.git}"
if [ "$normalized_origin" != 'erzz/dotfiles' ]; then
  printf '%s\n' "Unexpected origin for $DOTFILES_DIR: ${origin_url:-<none>}" >&2
  printf '%s\n' 'Expected https://github.com/erzz/dotfiles.git (or its equivalent SSH form).' >&2
  exit 1
fi
if [ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ] && [ "$ALLOW_DIRTY_DOTFILES" != '1' ]; then
  printf '%s\n' "Refusing preparation because $DOTFILES_DIR has uncommitted changes." >&2
  printf '%s\n' 'Review or commit them, or explicitly set ALLOW_DIRTY_DOTFILES=1 to opt in.' >&2
  exit 1
fi

# Prefer the helper checked into the acquired checkout. It keeps Homebrew
# native and scopes its shellenv to the child command.
native_helper="$DOTFILES_DIR/scripts/ensure-native-homebrew.sh"
if [ ! -f "$native_helper" ]; then
  printf '%s\n' "Native Homebrew helper not found: $native_helper" >&2
  exit 1
fi
bash "$native_helper" true

mise_cmd=''
mise_candidates=(/opt/homebrew/bin/mise /usr/local/bin/mise)
# Tests may replace the fixed native locations only when explicitly opting into
# the hermetic seam; normal bootstrap never accepts an arbitrary override.
if [ "${BOOTSTRAP_TEST_MODE:-}" = 1 ]; then
  if [ -z "${BOOTSTRAP_TEST_MISE_PATH:-}" ] || [ ! -x "$BOOTSTRAP_TEST_MISE_PATH" ]; then
    printf '%s\n' 'BOOTSTRAP_TEST_MODE requires an executable BOOTSTRAP_TEST_MISE_PATH.' >&2
    exit 1
  fi
  mise_candidates=("$BOOTSTRAP_TEST_MISE_PATH")
fi
for candidate in "${mise_candidates[@]}"; do
  if [ -z "$mise_cmd" ] && [ -x "$candidate" ]; then
    mise_cmd="$candidate"
    break
  fi
done
if [ -z "$mise_cmd" ]; then
  printf '%s\n' 'mise is not installed; installing it with native Homebrew.'
  bash "$native_helper" brew install mise
  for candidate in "${mise_candidates[@]}"; do
    if [ -x "$candidate" ]; then
      mise_cmd="$candidate"
      break
    fi
  done
fi
if [ -z "$mise_cmd" ]; then
  printf '%s\n' 'mise is required but no supported executable was found.' >&2
  exit 1
fi

printf '%s\n' '==> Preparing the pre-auth control plane (no authenticated sync yet)'
"$mise_cmd" -C "$DOTFILES_DIR" run prepare
printf '%s\n' ''
printf '%s\n' 'Bootstrap preparation is complete. Before syncing:'
printf '%s\n' '  1. Open 1Password, sign in, and enable CLI integration.'
printf '%s\n' '  2. Run: gh auth login'
printf '%s\n' '  3. Sign in to the App Store if prompted or required.'
printf '%s\n' "  4. Run: mise -C \"$DOTFILES_DIR\" run sync"
printf '%s\n' 'The authenticated sync is intentionally not run automatically.'
