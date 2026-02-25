# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Homebrew](https://brew.sh/).

## Design principles

1. **One command** to set up a new machine from scratch
2. **Individual targets** to configure a single tool on a temporary machine
3. **Idempotent** -- run at any time to converge back to the desired state
4. **No secrets** -- credentials managed by [fnox](https://github.com/jdx/fnox) + 1Password

## Quick start

On a brand new Mac, `git` isn't installed yet -- but typing `git` in Terminal prompts you to install Xcode CLI tools (which includes git).

```bash
git
# Install Xcode CLI tools when prompted

git clone https://github.com/erzz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap script runs five stages, each idempotent:

| Stage | What it does |
|-------|-------------|
| 1. Prerequisites | Xcode CLT, Homebrew, `brew bundle` (installs everything) |
| 2. Stow configs | `stow --restow` for all packages (convergent symlinks) |
| 3. Shell setup | Oh My Zsh (if missing), set default shell to zsh |
| 4. Tool activation | `mise install`, gh-dash extension, TPM + tmux plugins |
| 5. macOS prefs | Skipped by default -- pass `--macos` to apply (requires reboot) |

```bash
# Full setup including macOS preferences
./bootstrap.sh --macos
```

## Individual targets

Each tool can be set up independently via `make`. Useful for temporary machines where you only need a specific tool configured.

```bash
make git        # Stow git config
make zsh        # Stow zsh config + install Oh My Zsh
make nvim       # Stow neovim config
make tmux       # Stow tmux config + install TPM + plugins
make ghostty    # Stow ghostty config
make zed        # Stow zed config
make starship   # Stow starship config
make mise       # Stow mise config
make fnox       # Stow fnox config
make direnv     # Stow direnv config
make prettierd  # Stow prettierd config
make gh-dash    # Stow gh-dash config + install extension
make opencode   # Stow opencode config
make zellij     # Stow zellij config
make os         # Apply macOS preferences
make brew       # Install Homebrew + run brew bundle
make mise-install  # Stow mise config + install mise-managed tools
```

## How it works

Each top-level directory is a **stow package** that mirrors `$HOME`. For example:

```
git/.gitconfig        ->  ~/.gitconfig
git/.config/git/ignore  ->  ~/.config/git/ignore
zsh/.zshrc            ->  ~/.zshrc
mise/.config/mise/config.toml  ->  ~/.config/mise/config.toml
```

**Tool installation** is handled by the Brewfile (single source of truth for all Homebrew-managed packages). **Runtime tools** (Node, Java, Terraform, etc.) are managed by [mise](https://mise.jdx.dev/). **Secrets** are injected at runtime by fnox via 1Password.

## What's included

| Package | Description |
|---------|-------------|
| `brew` | Brewfile with CLI tools, casks, fonts, MAS apps, VS Code extensions |
| `direnv` | Per-directory environment variables |
| `drift` | Background drift detection for dotfiles |
| `fnox` | 1Password-backed credential injection |
| `gh-dash` | GitHub CLI dashboard |
| `ghostty` | Ghostty terminal config |
| `git` | Git config with delta, aliases, osxkeychain credential helper |
| `mise` | Runtime version manager (node, java, terraform, maven, fnox, MCP tools) |
| `nvim` | Neovim with LazyVim |
| `opencode` | OpenCode AI assistant config |
| `os` | macOS system preferences (Finder, Dock, screenshots, etc.) |
| `prettierd` | Global prettier daemon config |
| `starship` | Starship prompt theme |
| `stow` | Stow global ignore rules |
| `tmux` | tmux config with TPM, sesh, vim-tmux navigation |
| `zed` | Zed editor config with MCP servers |
| `zellij` | Zellij terminal multiplexer config |
| `zsh` | Zsh config with Oh My Zsh, zplug, mise, fnox, direnv, starship, zoxide |

## Acknowledgements

- Original inspiration from [pkissling](https://github.com/pkissling/dotfiles/)
