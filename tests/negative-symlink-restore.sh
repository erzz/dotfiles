#!/usr/bin/env bash
# Negative test: removing a managed symlink must be restored by chezmoi apply.
set -euo pipefail

target="${HOME}/.gitconfig"

# Save the link target so we can verify restoration
[ -L "$target" ] || { echo "$target is not a symlink — skipping"; exit 0; }
original="$(readlink "$target")"

# Remove the symlink
rm "$target"

# Apply
chezmoi apply --force "$target" >/dev/null 2>&1

# Must exist as a symlink with the same target
if [ ! -L "$target" ]; then
	echo "$target was not restored as a symlink"
	exit 1
fi

restored="$(readlink "$target")"
if [ "$restored" != "$original" ]; then
	echo "Restored symlink target differs:"
	echo "  before: $original"
	echo "  after:  $restored"
	exit 1
fi
