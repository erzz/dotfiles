# dotfiles

Developer tools and config for macOS and Omarchy Linux, managed with [mise](https://mise.jdx.dev/).

- The repository is checked out at `~/dotfiles`
- Git is the source of truth
- mise applies the checked-out state to the machine.

## Everyday use

Pull changes, then run the shared sync command. It selects the native sync script for macOS or
Omarchy Linux automatically:

```bash
cd "$HOME/dotfiles"
git pull --rebase
mise run sync
```

If for some reason you have a local or project-scoped mise target that clashes with `sync`, then use `mise -C "$HOME/dotfiles"` to be specific.

## Bootstrap New Machines

### macOS

The bootstrap checks Apple's Command Line Tools, installs Homebrew and mise, and runs the pre-auth
preparation steps such as making sure mise, fnox, 1password etc are in place:

Bootstrap the machine with:

```bash
curl -fsSL https://raw.githubusercontent.com/erzz/dotfiles/main/bootstrap.sh | bash
```

Before the first sync:

1. Sign in to GitHub with `gh auth login`.
2. Open 1Password and enable its CLI integration.
3. Sign in to the App Store if you want Mac App Store apps installed.
4. Run `mise run sync`.

To test another branch, set `BOOTSTRAP_BRANCH` before running the bootstrap.

### Omarchy

**Note:** The omarchy version is barely tested from an end-to-end, fresh machine perspective due to lack of opportunity at the moment.

Omarchy already provides mise and owns the desktop setup. Clone the Omarchy branch and run the
preflight before syncing:

```bash
git clone --branch omarchy --single-branch \
  https://github.com/erzz/dotfiles.git "$HOME/dotfiles"

mise run omarchy-preflight
mise run omarchy-install-packages
mise run sync
```

The package task is optional, but installs the extra CLI/editor tooling tracked by this repository.
Selected GUI applications are separate:

```bash
mise -C "$HOME/dotfiles" run omarchy-install-apps
```

## 1Password and fnox

Private npm credentials and MCP packages are handled by 1Password and [fnox](https://github.com/jdx/fnox).
fnox resolves the references in `common/configs/fnox/config.toml` and injects the values into the
mise command that needs them. The sync renders these local, mode `0600` files:

- `~/.npmrc`
- `~/.local/state/secrets.env`

Secrets are not committed to Git. On Omarchy, use either an unlocked 1Password desktop CLI integration
or set `OP_SERVICE_ACCOUNT_TOKEN` before running `sync`. The automated flow is non-interactive:
it does not run `op signin` or prompt for a password.

To retry only the private phase on Omarchy:

```bash
mise -C "$HOME/dotfiles" run omarchy-private
```

## Useful tasks

### macOS

```bash
mise -C "$HOME/dotfiles" run check   # show pending mise changes
mise -C "$HOME/dotfiles" run apps    # app overlay and Mac App Store apps
mise -C "$HOME/dotfiles" run casks  # Homebrew applications
mise -C "$HOME/dotfiles" run fonts  # Homebrew fonts
mise -C "$HOME/dotfiles" run office # opt in to Office casks
mise -C "$HOME/dotfiles" run macos  # retry macOS defaults
```

### Omarchy

```bash
mise -C "$HOME/dotfiles" run omarchy-install-packages
mise -C "$HOME/dotfiles" run omarchy-install-apps
mise -C "$HOME/dotfiles" run omarchy-post-install
```

Omarchy package installation is additive. It does not remove packages, and it fails rather than
prompting when passwordless `sudo` or AUR access is unavailable.

## Ownership

- `common/` contains shared developer configuration and templates.
- `macos/` contains Homebrew files, macOS-only configuration, and Mac scripts.
- `omarchy/` contains Arch/AUR inventories, Omarchy scripts, and small user-level additions.
- `mise.toml` at the repository root is the shared control plane.

Omarchy remains responsible for Hyprland, the Omarchy shell, desktop applications, fonts, Docker, and
its global `~/.config/mise/config.toml`. This repository adds a mise fragment under
`~/.config/mise/conf.d/` and does not edit `/usr/share/omarchy`.

Normal Omarchy sync installs and enables the CodeBurn plugin using Omarchy's plugin command.

## Config changes

Edit the repository files directly, run the relevant sync, then inspect `git status`:

```bash
git status
git add common macos omarchy mise.toml
git commit -m "describe the change"
git push
```

Put shared files in `common/`, macOS files in `macos/`, and Omarchy-specific files in `omarchy/`.
Keep secrets out of the repository.

On Omarchy, Neovim and OpenCode are merged with the existing configuration. Repository files win when
the same path is managed by both, while Omarchy-only files are preserved. Conflicts are backed up
before replacement. Set `OMARCHY_DOTFILES_FORCE=1` only when you intentionally want to replace other
conflicting user configuration.
