# dotfiles

macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [Homebrew](https://brew.sh/).

## Design principles

1. **One command** to set up a new machine from scratch
2. **Idempotent** -- run `chezmoi apply` at any time to converge back to the desired state
3. **Edit live** -- configs are symlinked from `$HOME` straight into the repo, so changes are captured by `git` (no `chezmoi add` ceremony)
4. **No secrets** -- credentials managed by [fnox](https://github.com/jdx/fnox) + 1Password

## Quick start

On a brand new Mac, run:

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply erzz
```

That single command:

1. Downloads the chezmoi binary into `./bin/chezmoi`.
2. Clones this repo to `~/.local/share/chezmoi`.
3. Generates `~/.config/chezmoi/chezmoi.toml` from the template.
4. Runs every bootstrap script — including installing Xcode CLT and Homebrew.

You'll be prompted twice during the run:

- **Xcode CLT installer** (GUI dialog) — accept it; the script polls until it finishes.
- **sudo password** — needed by the Homebrew installer and `chsh`.

For full setup including macOS preferences (requires reboot):

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply erzz --promptBool macos=true
```

After bootstrap, open a new terminal so `~/.zshrc` is sourced (puts brew, mise, fnox on PATH). Then sign into:

- **App Store** — required for `mas` to install the apps in `Brewfile.mas`. Run `chezmoi apply` again afterwards to pick them up.
- **1Password.app** + enable "Integrate with 1Password CLI" in Settings → Developer — required for fnox to inject secrets (`GH_TOKEN`, etc.) into your shell.
- **GitHub CLI** (`gh auth login`) — required for the `gh-dash` extension. Run `chezmoi apply` again afterwards.

## How it works

Configs are deployed as **whole-directory symlinks** from `$HOME` into the repo's `configs/` directory. Edit a file in `~/.config/nvim/` and it shows up in `git status` immediately -- no resync step.

```
~/.zshrc                  ->  ~/.local/share/chezmoi/configs/... (single-file)
~/.config/nvim            ->  ~/.local/share/chezmoi/configs/nvim (whole-dir)
~/.config/opencode        ->  ~/.local/share/chezmoi/configs/opencode (whole-dir)
```

Bootstrap stages live as scripts under `home/.chezmoiscripts/` and run automatically on `chezmoi apply`:

| Stage | What it does |
|-------|-------------|
| Prerequisites | Xcode CLT, Homebrew, `brew bundle` |
| Shell setup | Oh My Zsh (if missing), set default shell to zsh |
| Tool activation | `mise install`, gh-dash extension, TPM + tmux plugins |
| macOS prefs | Skipped by default -- pass `--promptBool macos=true` to `chezmoi init` |

**Tool installation** is handled by the Brewfile (single source of truth for Homebrew-managed packages). Mac App Store apps live in `brew/Brewfile.mas` and are installed by a separate script that only runs interactively (sign into App Store first). **Runtime tools** (Node, Java, Terraform, etc.) are managed by [mise](https://mise.jdx.dev/). **Secrets** are injected at runtime by fnox via 1Password.

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

The repo's `configs/<name>/` dir holds the *real* content; `home/dot_config/symlink_<name>.tmpl` points `~/.config/<name>` at it. To bring a new tool's config into management:

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
# 1. Move into source dir with the dot_ prefix chezmoi expects.
mv ~/.foorc ~/.local/share/chezmoi/home/dot_foorc

# 2. Apply and commit.
chezmoi apply
cd ~/.local/share/chezmoi && git add -A && git commit -m "feat: add foorc"
```

**Single file under `~/.config/`** (e.g. `~/.config/bar.toml`):

```bash
mv ~/.config/bar.toml ~/.local/share/chezmoi/home/dot_config/bar.toml
chezmoi apply
cd ~/.local/share/chezmoi && git add -A && git commit -m "feat: add bar.toml"
```

After the symlink exists, you edit the live file (`~/.config/newtool/foo.lua`) directly and `git status` in the repo picks up the change — no resync.

### Adding a brew package

Edit `brew/Brewfile`, then:

```bash
chezmoi apply  # script 03's run_onchange_ detects the Brewfile hash change and re-runs brew bundle
```

(Or `brew bundle --file ~/.local/share/chezmoi/brew/Brewfile` directly — same result.)

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

Plus single-file configs: `.zshrc`, `.gitconfig`, `.tmux.conf`, `.npmrc`, and `~/.config/starship.toml`.

## Acknowledgements

- Original inspiration from [pkissling](https://github.com/pkissling/dotfiles/)
