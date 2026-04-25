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
