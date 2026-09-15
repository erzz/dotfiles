#!/usr/bin/env bash
# Hermetic behavioral coverage for bootstrap.sh and the real native helper.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
wrapper="$root/bootstrap.sh"
helper="$root/bootstrap/ensure-native-homebrew.sh"
work="$(mktemp -d "${TMPDIR:-/tmp}/bootstrap-wrapper.XXXXXX")"
trap 'rm -rf "$work"' EXIT
bin="$work/bin"; home="$work/home"; clt="$work/clt"; log="$work/log"
mkdir -p "$bin" "$home" "$clt"

cat >"$bin/uname" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' Darwin
EOF
cat >"$bin/xcode-select" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$FAKE_CLT"
EOF
cat >"$bin/xcrun" <<'EOF'
#!/usr/bin/env bash
[ "${1:-}" = --find ] && printf '%s\n' "$FAKE_CLANG"
EOF
cat >"$bin/clang" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat >"$bin/mise" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "mise $*" >>"$FAKE_LOG"
EOF
chmod +x "$bin"/*
cat >"$bin/mise" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "mise $*" >>"$FAKE_LOG"
EOF
chmod +x "$bin/mise"

# The fake brew is selected only through the helper's explicit test seam.
fake_brew="$work/fake-brew"
cat >"$fake_brew" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "brew $*" >>"$FAKE_LOG"
if [ "${1:-}" = shellenv ]; then printf 'export PATH="%s:$PATH"\n' "$FAKE_BIN"; fi
EOF
chmod +x "$fake_brew"

# Exercise the actual helper's CLT gate and command exec mode, without install/network.
FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" PATH="$bin:/usr/bin:/bin" \
  NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 bash "$helper" true
FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" PATH="$bin:/usr/bin:/bin" \
  NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 bash "$helper" bash -c 'printf "%s\n" helper-command >>"$FAKE_LOG"'
grep -q '^helper-command$' "$log"
if FAKE_CLT="$clt" FAKE_CLANG="$work/missing-clang" PATH="$bin:/usr/bin:/bin" \
  NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$work/missing-brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 NATIVE_HOMEBREW_XCODE_SELECT="$bin/xcode-select" NATIVE_HOMEBREW_XCRUN="$bin/xcrun" \
  bash "$helper" true 2>"$work/helper-error"; then
  exit 1
fi
grep -q 'Usable Xcode Command Line Tools' "$work/helper-error"

make_checkout() {
  local path="$1" origin="${2:-https://github.com/erzz/dotfiles.git}"
  mkdir -p "$path/bootstrap"; : >"$path/.git-marker"
  printf '%s\n' "$origin" >"$path/.fake-origin"
  cp "$helper" "$path/bootstrap/ensure-native-homebrew.sh"
}

cat >"$bin/git" <<'EOF'
#!/usr/bin/env bash
set -e
if [ "${1:-}" = clone ]; then
  dest="${@: -1}"; mkdir -p "$dest/bootstrap"; : >"$dest/.git-marker"
  printf '%s\n' 'https://github.com/erzz/dotfiles.git' >"$dest/.fake-origin"
  cp "$FAKE_HELPER" "$dest/bootstrap/ensure-native-homebrew.sh"
  printf '%s\n' clone >>"$FAKE_LOG"; exit 0
fi
path="${2:-}"
case "${3:-}" in
  rev-parse) [ -f "$path/.git-marker" ] && printf '%s\n' "$path" || exit 1 ;;
  remote) cat "$path/.fake-origin" ;;
  status) [ -f "$path/.dirty" ] && printf '%s\n' ' M file' || true ;;
  *) exit 1 ;;
esac
EOF
chmod +x "$bin/git"
export FAKE_HELPER="$work/helper"; cp "$helper" "$FAKE_HELPER"

run_wrapper() {
  : >"$log"
  HOME="$home" PATH="$bin:/usr/bin:/bin" FAKE_BIN="$bin" FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" \
    FAKE_LOG="$log" NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 \
    BOOTSTRAP_TEST_MODE=1 BOOTSTRAP_TEST_MISE_PATH="$bin/mise" bash "$wrapper"
}

# Fresh checkout invokes the actual helper and prepare, but never syncs.
run_wrapper
grep -q '^clone$' "$log"
grep -q 'mise .*run prepare' "$log"
if grep -q 'run sync' "$log"; then
  exit 1
fi

# Accepted origin forms are table-driven; the wrong origin is rejected.
for origin in 'https://github.com/erzz/dotfiles.git' 'git@github.com:erzz/dotfiles.git' 'ssh://git@github.com/erzz/dotfiles.git'; do
  rm -rf "$home/dotfiles"; make_checkout "$home/dotfiles" "$origin"; run_wrapper
done
rm -rf "$home/dotfiles"; make_checkout "$home/dotfiles" 'https://example.invalid/wrong.git'
if run_wrapper 2>"$work/error"; then
  exit 1
fi
grep -q 'Unexpected origin' "$work/error"

# Existing non-Git paths, symlink paths, and dirty checkouts are protected.
rm -rf "$home/dotfiles"; mkdir -p "$home/dotfiles"
if run_wrapper 2>"$work/error"; then
  exit 1
fi
grep -q 'not a Git checkout' "$work/error"
rm -rf "$home/dotfiles"; mkdir -p "$work/real"; ln -s "$work/real" "$home/dotfiles"
if run_wrapper 2>"$work/error"; then
  exit 1
fi
grep -q 'is a symlink' "$work/error"
rm -f "$home/dotfiles"; make_checkout "$home/dotfiles"; touch "$home/dotfiles/.dirty"
if run_wrapper 2>"$work/error"; then
  exit 1
fi
grep -q 'uncommitted changes' "$work/error"
ALLOW_DIRTY_DOTFILES=1 run_wrapper
if grep -q 'run sync' "$log"; then
  exit 1
fi

# A test mode without an executable mise path must fail closed.
rm -rf "$home/dotfiles"; make_checkout "$home/dotfiles"
if HOME="$home" PATH="$bin:/usr/bin:/bin" FAKE_BIN="$bin" FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" \
  NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 \
  BOOTSTRAP_TEST_MODE=1 BOOTSTRAP_TEST_MISE_PATH='' bash "$wrapper" 2>"$work/error"; then exit 1; fi
grep -q 'requires an executable' "$work/error"

# Real Git covers checkout root, origin, branch, detached HEAD, and dirty behavior.
real_home="$work/real-home"; real_repo="$real_home/dotfiles"
real_bin="$work/real-bin"; mkdir -p "$real_bin"
for command_name in uname xcode-select xcrun; do cp "$bin/$command_name" "$real_bin/$command_name"; done
mkdir -p "$real_repo/bootstrap"; git -C "$real_repo" init -q
git -C "$real_repo" config user.email test@example.invalid; git -C "$real_repo" config user.name test
printf '%s\n' content >"$real_repo/file"; git -C "$real_repo" add file; git -C "$real_repo" commit -qm initial
git -C "$real_repo" remote add origin https://github.com/erzz/dotfiles.git
cp "$helper" "$real_repo/bootstrap/ensure-native-homebrew.sh"; git -C "$real_repo" add bootstrap; git -C "$real_repo" commit -qm helper
git -C "$real_repo" branch feature; git -C "$real_repo" checkout -q feature
HOME="$real_home" PATH="$real_bin:/usr/bin:/bin" FAKE_BIN="$bin" FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" \
  NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 \
  BOOTSTRAP_TEST_MODE=1 BOOTSTRAP_TEST_MISE_PATH="$bin/mise" BOOTSTRAP_BRANCH=feature bash "$wrapper"
if HOME="$real_home" PATH="$real_bin:/usr/bin:/bin" FAKE_BIN="$bin" FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" \
  NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 \
  BOOTSTRAP_TEST_MODE=1 BOOTSTRAP_TEST_MISE_PATH="$bin/mise" BOOTSTRAP_BRANCH=other bash "$wrapper" 2>"$work/error"; then
  exit 1
fi
grep -q 'does not match existing checkout branch feature' "$work/error"
touch "$real_repo/dirty"; if HOME="$real_home" PATH="$real_bin:/usr/bin:/bin" FAKE_BIN="$bin" FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 BOOTSTRAP_TEST_MODE=1 BOOTSTRAP_TEST_MISE_PATH="$bin/mise" bash "$wrapper" 2>"$work/error"; then exit 1; fi
git -C "$real_repo" reset -q --hard; git -C "$real_repo" checkout -q --detach
if HOME="$real_home" PATH="$real_bin:/usr/bin:/bin" FAKE_BIN="$bin" FAKE_CLT="$clt" FAKE_CLANG="$bin/clang" FAKE_LOG="$log" NATIVE_HOMEBREW_TEST_MODE=1 NATIVE_HOMEBREW_BREW_PATH="$fake_brew" NATIVE_HOMEBREW_SKIP_SYSTEM_PATHS=1 BOOTSTRAP_TEST_MODE=1 BOOTSTRAP_TEST_MISE_PATH="$bin/mise" BOOTSTRAP_BRANCH=feature bash "$wrapper" 2>"$work/error"; then exit 1; fi
grep -q 'detached HEAD' "$work/error"

# Static safety checks and explicit absence of Python and broad mise override.
grep -q 'BOOTSTRAP_BRANCH' "$wrapper"; grep -q 'remote get-url origin' "$wrapper"
grep -q 'ALLOW_DIRTY_DOTFILES' "$wrapper"; grep -q 'xcrun --find clang' "$wrapper"
if grep -q 'MISE_COMMAND' "$wrapper"; then
  exit 1
fi
if grep -qE 'chezmoi|old checkout|macos-defaults|Brewfile' "$wrapper"; then
  exit 1
fi
printf '%s\n' 'Validated hermetic bootstrap and real native helper behavior.'
