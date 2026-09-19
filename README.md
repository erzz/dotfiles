# dotfiles

macOS dotfiles with **mise as the target canonical control plane** and **Git as the source of
truth**. The repository is migrating from a chezmoi/Homebrew/Brewfile workflow. The legacy files
remain available during the parallel migration, but the native mise lifecycle below is the target
workflow.

## Design principles

1. **One convergent control plane** — the canonical common state lives in `mise.toml`; explicit
   overlays handle applications and optional macOS defaults.
2. **Git is synchronization** — laptops converge by pulling and pushing this repository. A mise
   task does not pull or push for you.
3. **Idempotent retries** — rerun mise tasks as needed; only missing or changed state is applied.
4. **Edit live** — managed configs are symlinked from `$HOME` into the repository, so changes are
   visible to Git without a separate add step.
5. **No secrets in Git** — sensitive values come from 1Password/fnox or runtime authentication;
   credentials and machine-local state do not sync through Git.

## First-machine bootstrap

On a clean Mac, use the native mise project bootstrap before trying to resolve the complete private
inventory:

1. Install mise and temporarily put its default install directory on `PATH`:

   ```sh
   curl https://mise.run | sh
   export PATH="$HOME/.local/bin:$PATH"
   mise --version
   ```

   The export affects only the current shell. The managed zsh configuration adds
   `$HOME/.local/bin` persistently after synchronization.

2. Install Apple's Command Line Tools and complete the graphical installer:

   ```sh
   xcode-select --install
   ```

   This installs **only the Apple Command Line Tools, not the full Xcode application**. It provides
   the initial Git and other command-line tools needed to acquire the project. macOS opens a GUI
   installer; accept it and wait for it to finish before continuing. If the tools are already
   installed, `xcode-select --install` reports that instead.

3. Acquire and use the project through native `mise bootstrap`:

   ```sh
   mise bootstrap --from "https://github.com/erzz/dotfiles.git" --from-dir "$HOME/dotfiles" --only packages --yes
   cd "$HOME/dotfiles"
   mise trust
   ```

   Use the repository's preferred checkout path in place of `$HOME/dotfiles` when necessary. The
   `--only packages` flag installs only the small root control-plane package set before
   authentication. Do not use `--adopt` here, and do not use `mise dot track`; those are different
   workflows and would introduce another local ownership/history model for paths managed by this
   project.

4. Native bootstrap cannot finish private or authenticated resolution before 1Password and GitHub
   authentication. If the current configuration requires the repository's pre-auth helper, run:

   ```sh
   mise run --skip-tools prepare
   ```

   `prepare` installs the small pre-auth control-plane set (`git`, `gh`, 1Password, and the
   1Password CLI) and deploys the static fnox configuration. It deliberately does not install the
   root `[tools]` table or resolve private packages. It is a first-machine helper, not part of
   normal day-to-day sync.

5. Open 1Password, sign in, and enable its CLI integration. Then authenticate GitHub:

   ```sh
   # `prepare` cannot change the PATH of this parent shell.
   export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
   gh auth login
   ```

   The PATH export is a temporary parent-shell handoff for the Homebrew-installed `gh`; it is not a
   second persistent shell configuration. Authenticate each laptop independently. The `sync`,
   `install`, and `apps` task bridges export `MISE_GITHUB_TOKEN` from `gh auth token` before
   GitHub-backed mise resolution. `mise token github` is an optional diagnostic, not a configuration
   command. The token used by mise is separate from fnox-injected 1Password/npm registry secrets.
   The managed `.gitconfig` uses `gh auth git-credential`, so `gh auth setup-git` is normally
   unnecessary; use it only as a recovery command if that managed configuration or helper is missing.

6. Run the canonical authenticated convergence command:

   ```sh
   mise run sync
   ```

   `sync` ensures fnox is available, replaces existing managed dotfile targets with the repository
   versions, and invokes authenticated
   native `mise -E apps bootstrap` through fnox. This is the complete convergence path for declared
   tools, repositories, dotfiles, packages, casks, fonts, Mac App Store apps, OpenCode, and the
   safe root macOS defaults. It still requires the authentication steps above; native bootstrap
   does not bypass an interactive login or private registry credentials. Once it completes, start a
   new login shell so the managed shell configuration is loaded:

   ```sh
   exec zsh -l
   ```

## Canonical and targeted commands

During `sync`, concise phase markers show fnox installation, configuration deployment, and
convergence progress. Its nested app bootstrap uses a temporary empty global mise config, so the
checked-out project configuration remains the source of truth instead of stale user/global config.
If mise panics during the isolated tool phase, that is a mise/runtime issue, not a Homebrew Dart
declaration.

`mise run sync` is the canonical complete convergence command. Application casks are owned by
`brew/Brewfile.casks` and installed by `mise run casks`; fonts remain the separate
`brew/Brewfile.fonts` manifest installed by `mise run fonts`, both via native Homebrew. These tasks remain useful targeted
convenience or retry commands:

```bash
mise run sync       # authenticated complete convergence
mise run casks      # retry native application casks
mise run apps       # retry the applications/packages/casks/fonts/MAS overlay
mise run install    # retry tools declared in the root mise.toml
mise run macos      # apply the safe macOS defaults declared in mise.toml
mise run check      # show pending mise bootstrap changes
```

Both `sync` and `apps` use native Homebrew for the application casks in `brew/Brewfile.casks` and
for fonts. This includes Office and Teams, whose Homebrew cask installers are not represented by
the mise package overlay.

DisplayLink is intentionally excluded from automatic sync because its privileged pkg requires
interactive administrator authorization, manual macOS Screen Recording approval, and a reboot. If
needed, install it explicitly with `brew install --cask displaylink`, then complete those steps.

Disk Inventory X is intentionally excluded: Homebrew marks its cask disabled for a Gatekeeper
failure, and its legacy app bundle causes macOS xattr/ditto installation failures. Install it
manually only if explicitly needed; do not disable quarantine globally.

`mise run setup` is retained only as a compatibility alias for `sync` if it exists in the current
configuration. It is not the primary terminology and is not a separate complete setup phase.

Useful previews and diagnostics are explicit operations; do not use `mise run sync --dry-run`,
because the task body still executes:

```bash
MISE_GITHUB_TOKEN="$(gh auth token)" mise bootstrap --force-dotfiles --dry-run
MISE_GITHUB_TOKEN="$(gh auth token)" mise install --dry-run
MISE_GITHUB_TOKEN="$(gh auth token)" mise -E apps bootstrap --only packages --dry-run
mise bootstrap --only macos-defaults --dry-run
```

Direct GitHub-backed previews need an explicit `MISE_GITHUB_TOKEN`; the task bridges perform this
step automatically. Once the inventory stabilizes, use `mise lock` and then `mise install --locked`
for reproducible tool versions.

### Testing a non-default branch

`mise bootstrap --from` currently accepts a repository URL but has no branch/ref option. To test a
branch such as `switch2mise`, select it with Git first and then run native bootstrap locally:

```bash
git clone --branch switch2mise --single-branch \
  "https://github.com/erzz/dotfiles.git" \
  "$HOME/dotfiles-switch2mise"
cd "$HOME/dotfiles-switch2mise"
mise trust
mise bootstrap --only packages --yes
```

Do not append `#switch2mise` to the `--from` URL; that is not Git branch syntax.

## Keeping laptops in sync

Git is the synchronization mechanism; `mise run sync` applies only the checked-out repository.
Authenticate every laptop separately. On a laptop receiving changes, use:

```bash
git pull --rebase
mise run sync
```

On the authoring laptop, run the relevant targeted task or `mise run sync`, inspect the result,
then commit and push:

```bash
mise run check
mise run sync
git add mise.toml mise.apps.toml configs home
git commit -m "describe the configuration change"
git push
```

Secrets, tokens, installed application state, and other machine-local state do not sync through
Git. `prepare` is only for a first machine before authentication; existing laptops should pull
with `git pull --rebase` and run `mise run sync`.

## Ownership and migration boundaries

The root `mise.toml` owns common tools, repositories, shell activation, dotfiles, essential
packages, safe defaults, and lifecycle tasks. `mise.apps.toml` owns the applications overlay.

Unsafe legacy macOS operations — including `chflags`, `systemsetup`, process kills, and reboot —
remain intentionally excluded from native mise bootstrap. The declarative macOS defaults are the
safe subset only. `bootstrap.sh`, legacy chezmoi commands, and `brew/Brewfile` remain transitional
paths while migration and clean-machine validation continue; they are not the canonical sync flow.

`mise dot track` and its local history are intentionally not used for project-managed paths. They
would create a second local history authority alongside Git and the repository's mise declarations.
Likewise, `mise mcp` is optional experimental AI integration, not part of setup or synchronization.

## How configs are deployed

Managed paths are declared in the root `mise.toml` `[dotfiles]` table and symlinked from the home
directory into the repository. Examples:

```
~/.zshrc                   -> home/dot_zshrc
~/.config/nvim             -> configs/nvim
~/.config/opencode         -> configs/opencode
~/.config/mise/config.toml -> configs/mise/config.toml
```

Edit the live symlinked file or its repository target, then inspect `git status`. The `home/` and
`configs/` paths retain the existing chezmoi-compatible layout while deployment responsibility
moves to mise. The templated `.npmrc` and its 1Password-backed value remain a parallel migration
path until its mise behavior is validated.

## Common legacy commands

These remain available while migration continues, but are not the target synchronization workflow:

```bash
make apply       # legacy chezmoi apply
make diff        # legacy pending-change view
make status      # legacy chezmoi status
make update      # legacy git pull + apply
make test        # legacy test suite
make drift       # legacy drift check
```

## Adding configuration

Keep the existing chezmoi-compatible content layout and declare deployment in the root
`mise.toml` `[dotfiles]` table. Put whole-directory content under `configs/<name>/` and home files
under `home/`. Then converge and commit:

```bash
mise run sync
git add mise.toml configs home
git commit -m "feat: add newtool config"
git push
```

Do not put secrets in the repository. Sensitive templates remain subject to the parallel
chezmoi/1Password migration path.

## Adding packages and tools

Add common essential packages to the root `mise.toml` `[bootstrap.packages]` table. Add app-only
formulas, casks, taps, fonts, or Mac App Store apps to `mise.apps.toml`. Add runtime tools to the
root `[tools]` table. Authenticate first for private inventory, then use the targeted task or
`mise run sync`:

```bash
mise run apps
mise run install
git add mise.toml mise.apps.toml
git commit -m "feat: add package or tool"
git push
```

`brew/Brewfile.casks` is the native application cask owner, used by `mise run casks` from `sync`
and `apps`. `brew/Brewfile` remains a legacy comparison/fallback aggregate and is not called by
the native path. Fonts are owned separately by `brew/Brewfile.fonts` and installed with
`mise run fonts` via native Homebrew.

## What's included

The existing chezmoi-compatible layout includes configuration for Colima, direnv, fnox, gh-dash,
Ghostty, Git, mise, Neovim, OpenCode, prettierd, Supacode, Zed, and Zellij, plus `.zshrc`,
`.gitconfig`, `.tmux.conf`, `.npmrc` (templated), and `~/.config/starship.toml`. Some finalizers
and templates remain under legacy chezmoi control during migration.

## Acknowledgements

- Original inspiration from [pkissling](https://github.com/pkissling/dotfiles/)
