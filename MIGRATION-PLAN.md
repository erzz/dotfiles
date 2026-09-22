# chezmoi/Homebrew/Brewfile → mise migration record

This document records the completed migration to a mise-native workflow. It is historical
context and rationale, not an instruction to run the retired bootstrap, chezmoi, or aggregate
Brewfile paths.

## Completed target architecture

Mise, with this Git repository as its declarative source, is the operational control plane for
macOS tools, Homebrew-backed packages and applications, dotfile deployment, safe macOS defaults,
repositories, and repeatable lifecycle tasks. A machine converges by checking out the repository,
completing explicitly required interactive authentication, and running the documented native mise
workflow.

- `mise.toml` owns common tools, repositories, shell activation, dotfile links, safe defaults,
  secrets variable names, and lifecycle tasks.
- `mise.apps.toml` is the explicit applications overlay for Homebrew formulas, casks, fonts, MAS
  IDs, and required non-default taps.
- Git is synchronization and review: `git pull --rebase` obtains state and `mise run sync` applies
  the checked-out state. No task pulls or pushes.
- `configs/` and `home/` are content storage. Mise `[dotfiles]` declarations deploy their content
  as symlinks into the home directory; no chezmoi runtime is involved.
- fnox and 1Password own runtime secret retrieval. Authentication is independent on each machine;
  secret values never become repository data.
- Small imperative operations that have no declarative equivalent are explicit, idempotent mise
  tasks, including post-install integrations.

## Supported workflow

On an existing machine:

```sh
git pull --rebase
mise run sync
```

Useful targeted retries are `mise run prepare`, `mise run install`, `mise run apps`, `mise run
macos`, `mise run casks`, `mise run fonts`, `mise run post-install`, and `mise run check`.
Operators authenticate 1Password/`op`, GitHub (`gh auth login`), and the App Store as needed.

On a clean Mac, use the repository-root `bootstrap.sh` wrapper, complete the required interactive
authentication, and then run `mise run sync`. The wrapper ensures Apple Command Line Tools,
native Homebrew, and mise, then runs the pre-auth `prepare` task. The final convergence path does
not depend on a prior Homebrew bundle or chezmoi apply.

## Package and application audit history

The following counts are retained as audit history from the former aggregate inventory; the
aggregate Brewfile is deleted and is not an available inventory or supported command.

- The former inventory contained 123 Homebrew formulas. The apps overlay owns the supported
  formulas; `git` and `gh` are common control-plane packages, `grant` uses its qualified provider,
  and TFLint is a native aqua tool. `qt` and `qt@5` remain deliberate exclusions.
- The former inventory contained 59 casks. The overlay and root control plane cover the supported
  cask intents, with application casks in `brew/Brewfile.casks` and fonts in
  `brew/Brewfile.fonts`.
- All retained font casks and seven audited Mac App Store IDs are represented in the overlay.
  App Store installation still requires Apple ID sign-in and may require interactive privileges.
- The old Dart tap is intentionally replaced by the native `dart = "latest"` mise tool.

Homebrew remains a provider, not the inventory authority. Normal operation uses the dedicated
`brew/Brewfile.casks` and `brew/Brewfile.fonts` manifests through the mise `casks` and `fonts`
tasks; the deleted aggregate Brewfile is not used.

## Configuration, secrets, and finalizers

Managed dotfiles and config directories are declared in root `[dotfiles]`, including zsh, Git,
tmux, mise, fnox, Neovim, OpenCode, Zed, Ghostty, Zellij, Starship, direnv, Colima, gh-dash,
herdr, Supacode, and prettierd. `mise run render-private-config` owns the runtime `.npmrc` and
`~/.local/state/secrets.env` files, with validation, atomic replacement, and restrictive
permissions; secret content is excluded from drift checks.

Native tasks also own TPM plugin installation, gh-dash, Docker Buildx, agent-browser assets,
repository cloning, and other retained post-install behavior. They detect satisfied state and are
safe to retry.

The supported macOS policy is deliberately limited to safe declarative defaults. Imperative or
disruptive operations such as `chflags`, `systemsetup`, process kills, reboot, privileged package
installation, and required manual approvals are intentionally excluded from the supported native
path. DisplayLink, Disk Inventory X, `chromedriver`, `via`, and `garmin-express` remain documented
manual or compatibility exclusions for their current privilege, Gatekeeper, or compatibility
issues.

## Retired paths

The final cutover removed the aggregate `brew/Brewfile`, `.chezmoiroot`, the numbered legacy
bootstrap phases and shared library, `os/install.sh`, and the chezmoi configuration/templates and
run scripts under `home/`. These files are not rollback commands or alternate ownership paths.
Recovery means restoring a Git backup or machine backup without introducing a second owner.

## Validation and future changes

The repository's current tests validate native mise configuration, dotfile ownership, bootstrap
behavior, and drift detection without requiring the retired workflow. Run:

```sh
make test
make drift
git diff --check
```

Future changes should add common tools to root `mise.toml`, application-only declarations to
`mise.apps.toml`, runtime tools to `[tools]`, whole-directory content under `configs/<name>/`, and
home files under `home/`. Declare every deployed path in `[dotfiles]`, keep secrets out of Git,
then run `mise run sync` and inspect Git changes.

The migration preserved the deliberate Dart deferral, the Homebrew provider boundary, explicit
authentication requirements, and the safe-defaults-only macOS policy while removing the second
chezmoi/Brewfile ownership model.
