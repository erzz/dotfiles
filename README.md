# dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [Homebrew](https://brew.sh/), orchestrated by a single `bootstrap.sh`.

## Design principles

1. **One command** to set up a new machine from scratch
2. **Idempotent** — re-run anything at any time, only missing work is done
3. **Edit live** — configs are symlinked from `$HOME` straight into the repo, so changes are captured by `git` (no `chezmoi add` ceremony)
4. **No secrets in git** — sensitive registry details pulled from 1Password at apply time; runtime credentials injected by [fnox](https://github.com/jdx/fnox)

## Quick start

On a brand new Mac:

```bash
xcode-select --install   # if missing
curl -fsSL https://raw.githubusercontent.com/erzz/dotfiles/main/bootstrap.sh | bash
```

That's it. `bootstrap.sh` orchestrates everything and pauses at the small handful of moments that genuinely need a human (signing in to 1Password, toggling the CLI integration, signing in to App Store, authorising `gh`). Total time: ~15-20 minutes, mostly waiting for `brew bundle` to download apps.

To enable macOS preferences too (Finder, Dock, screenshots, etc. — requires reboot):

```bash
chezmoi apply --data='{"macos":true}'
```

To test an unmerged branch on a fresh machine (chezmoi defaults to the repo's default branch otherwise):

```bash
BOOTSTRAP_BRANCH=my-branch ./bootstrap.sh
```

## Architecture

The setup is layered. Each layer can be re-run independently and is idempotent.

| Layer | What | Driven by |
|-------|------|-----------|
| 1. Prerequisites | Xcode CLT, Homebrew, bootstrap brew packages (1password, op, gh, chezmoi) | `bootstrap.sh` Phase 1 |
| 2. Identity | 1Password sign-in + CLI integration, gh auth, App Store sign-in | `bootstrap.sh` Phase 2 (interactive pauses) |
| 3. Configs | Symlinks from `$HOME` to `configs/`, templated dotfiles, brew bundle, mise install, tmux plugins, optional macOS prefs | `chezmoi apply` (invoked from `bootstrap.sh` Phase 3, or run directly thereafter) |
| 4. Finalisers | Oh My Zsh, chsh, gh-dash extension, docker-buildx symlink, TPM, tmux plugin install | `bootstrap.sh` Phase 4 |

After bootstrap, day-to-day you only ever touch Layer 3:

- **Edit a config**: change the file in-place (it's a symlink into the repo). Commit when ready.
- **Add a brew package**: edit `brew/Brewfile` → `chezmoi apply` (script 03 detects the hash change, re-runs `brew bundle`).
- **Add a mise tool**: edit `~/.config/mise/config.toml` → `chezmoi apply` re-runs `mise install --yes`.
- **Pull from another machine**: `make update` (= `chezmoi update`).

### How configs are deployed

```
~/.zshrc                  ->  ~/.local/share/chezmoi/configs/zsh/zshrc (single-file symlink)
~/.config/nvim            ->  ~/.local/share/chezmoi/configs/nvim     (whole-dir symlink)
~/.config/opencode        ->  ~/.local/share/chezmoi/configs/opencode (whole-dir symlink)
```

`home/dot_config/symlink_<name>.tmpl` files describe the symlink target; `configs/<name>/` holds the real content. Edit a file in `~/.config/nvim/` and `git status` in the repo picks it up immediately — no resync.

### Why a `bootstrap.sh` and not just chezmoi?

chezmoi is excellent at config files but its `run_*` scripts have ordering and credential constraints that don't fit the **prerequisites → identity → configs** flow naturally:

- chezmoi clones the repo *before* any script runs, so it can't bootstrap GitHub auth itself.
- 1Password CLI integration (needed for templated `dot_npmrc.tmpl` to use `onepasswordRead`) requires a manual UI toggle.
- App Store sign-in is inherently human.

`bootstrap.sh` makes those interactive moments explicit and visible (one readable shell script vs. a dozen `run_once` scripts in execution order). chezmoi then handles what it's best at: declarative config state.

## Common operations

```bash
make apply      # chezmoi apply (idempotent re-converge)
make diff       # show pending changes
make status     # chezmoi status
make update     # git pull + apply
make test       # run the test suite
make drift      # check for drift vs declared state
```

### Adding a new config

The repo's `configs/<name>/` directory holds the *real* content; `home/dot_config/symlink_<name>.tmpl` points `~/.config/<name>` at it. To bring a new tool's config into management:

**Whole directory** (e.g. `~/.config/newtool/`):

```bash
# 1. Move the live config into the repo.
mv ~/.config/newtool ~/.local/share/chezmoi/configs/newtool

# 2. Create the symlink template.
cat > ~/.local/share/chezmoi/home/dot_config/symlink_newtool.tmpl <<'EOF'
{{ .chezmoi.workingTree }}/configs/newtool
EOF

# 3. Apply (creates ~/.config/newtool -> configs/newtool symlink).
chezmoi apply

# 4. Verify it's symlinked, then commit.
ls -la ~/.config/newtool
cd ~/.local/share/chezmoi && git add -A && git commit -m "feat: add newtool config"
```

**Single file in `$HOME`** (e.g. `~/.foorc`):

```bash
mv ~/.foorc ~/.local/share/chezmoi/home/dot_foorc
chezmoi apply
cd ~/.local/share/chezmoi && git add -A && git commit -m "feat: add foorc"
```

**Single file under `~/.config/`** (e.g. `~/.config/bar.toml`):

```bash
mv ~/.config/bar.toml ~/.local/share/chezmoi/home/dot_config/bar.toml
chezmoi apply
cd ~/.local/share/chezmoi && git add -A && git commit -m "feat: add bar.toml"
```

### Templated configs (1Password-backed)

For configs that contain sensitive bits, give the file a `.tmpl` suffix and use `onepasswordRead`:

```gotmpl
{{ onepasswordRead "op://Employee/myitem/myfield" }}
```

`bootstrap.sh` Phase 2 guarantees the 1Password CLI is integrated before `chezmoi apply` runs, so these reads work on first apply. See `home/dot_npmrc.tmpl` for a real example.

### Adding a brew package

Edit `brew/Brewfile`, then `chezmoi apply` (script 03 detects the hash change and re-runs `brew bundle`).

### Adding a mise tool

Edit `~/.config/mise/config.toml` (which is symlinked into the repo at `configs/mise/config.toml`), then `chezmoi apply` re-runs `mise install --yes`. No script edit needed.

## What's included

| Config | Description |
|--------|-------------|
| `colima` | Colima container runtime |
| `direnv` | Per-directory environment variables |
| `fnox` | 1Password-backed credential injection |
| `gh-dash` | GitHub CLI dashboard |
| `ghostty` | Ghostty terminal config |
| `git` | Git config with delta, aliases, osxkeychain credential helper |
| `mise` | Runtime version manager (node, java, terraform, maven, fnox, MCP tools) |
| `nvim` | Neovim 0.12 with native `vim.pack` (no framework) |
| `opencode` | OpenCode AI assistant config |
| `prettierd` | Global prettier daemon config |
| `zed` | Zed editor config with MCP servers |
| `zellij` | Zellij terminal multiplexer config |

Plus single-file configs: `.zshrc`, `.gitconfig`, `.tmux.conf`, `.npmrc` (templated), and `~/.config/starship.toml`.

## Acknowledgements

- Original inspiration from [pkissling](https://github.com/pkissling/dotfiles/)
