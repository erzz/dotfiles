#!/usr/bin/env bash
# Ensure the native Homebrew CLI exists, independently of mise's brew backend.
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' 'Native Homebrew setup is supported on macOS only.' >&2
  exit 1
fi

test_mode="${NATIVE_HOMEBREW_TEST_MODE:-0}"
brew_path=''
if [ "$test_mode" = 1 ]; then
  brew_path="${NATIVE_HOMEBREW_BREW_PATH:-}"
fi
if [ -n "$brew_path" ] && [ ! -x "$brew_path" ]; then
  brew_path=''
fi
if [ -z "$brew_path" ] && { [ "$test_mode" != 1 ] || [ "${NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS:-0}" != 1 ]; } && [ -x /opt/homebrew/bin/brew ]; then
  brew_path=/opt/homebrew/bin/brew
elif [ -z "$brew_path" ] && { [ "$test_mode" != 1 ] || [ "${NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS:-0}" != 1 ]; } && [ -x /usr/local/bin/brew ]; then
  brew_path=/usr/local/bin/brew
fi

if [ -z "$brew_path" ]; then
  selected_developer_dir=''
  clang_path=''
  clt_ready=true

  # Override hooks are intentionally opt-in for hermetic tests; production
  # defaults remain the platform commands and Homebrew installer.
  xcode_select_cmd='xcode-select'
  xcrun_cmd=/usr/bin/xcrun
  if [ "$test_mode" = 1 ]; then
    xcode_select_cmd="${NATIVE_HOMEBREW_XCODE_SELECT:-xcode-select}"
    xcrun_cmd="${NATIVE_HOMEBREW_XCRUN:-/usr/bin/xcrun}"
  fi
  if ! selected_developer_dir=$("$xcode_select_cmd" -p 2>/dev/null); then
    clt_ready=false
  elif [ ! -d "$selected_developer_dir" ]; then
    clt_ready=false
  elif ! clang_path=$("$xcrun_cmd" --find clang 2>/dev/null) || [ ! -x "$clang_path" ]; then
    clt_ready=false
  fi

  if [ "$clt_ready" != true ]; then
    printf '%s\n' 'Usable Xcode Command Line Tools are required before installing Homebrew.' >&2
    printf '%s\n' 'Run: xcode-select --install' >&2
    printf '%s\n' "Complete Apple's GUI installer, then retry mise run sync." >&2
    exit 1
  fi

  printf '%s\n' 'Homebrew CLI not found; installing native Homebrew...' >&2
  installer=''
  if [ "$test_mode" = 1 ]; then
    installer="${NATIVE_HOMEBREW_INSTALLER:-}"
  fi
  if [ -n "$installer" ]; then
    NONINTERACTIVE=1 "$installer"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [ "$test_mode" = 1 ] && [ -n "${NATIVE_HOMEBREW_BREW_PATH:-}" ] && [ -x "$NATIVE_HOMEBREW_BREW_PATH" ]; then
    brew_path="$NATIVE_HOMEBREW_BREW_PATH"
  elif [ -x /opt/homebrew/bin/brew ]; then
    brew_path=/opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    brew_path=/usr/local/bin/brew
  else
    printf '%s\n' 'Homebrew installer completed without creating /opt/homebrew/bin/brew or /usr/local/bin/brew.' >&2
    exit 1
  fi
fi

# Keep setup scoped to this helper process; exec-ed commands inherit it.
eval "$("$brew_path" shellenv)"

if [ "$#" -gt 0 ]; then
  exec "$@"
fi
