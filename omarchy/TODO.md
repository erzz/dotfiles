# Omarchy Backlog

Platform-specific backlog for safe convergence on Omarchy Quattro or later. Machine-specific behavior must be validated on an actual Omarchy Quattro+ system, using the available Omarchy skills; CI checks must not mutate a host.

## P0

- [ ] Enforce the actual Omarchy Quattro+ minimum in `bootstrap.sh`, `scripts/sync.sh`, and `omarchy/scripts/omarchy-preflight.sh` using documented, version-aware detection. **Accept when:** unsupported or older Omarchy releases are rejected consistently at each entry point, Quattro+ is accepted, and automated tests cover version parsing and detection failures.
- [ ] Investigate why `omarchy/scripts/sync-omarchy.sh` runs `omarchy update -y` before package installation. The previous rationale was to refresh package metadata. Determine on Omarchy Quattro+ whether this is redundant or required for safe package convergence; design a safe way to avoid unnecessary full OS updates while preserving Arch's full-upgrade constraint. Do not use or recommend `pacman -Sy` followed by package installs ([Arch partial-upgrade guidance](https://wiki.archlinux.org/title/Pacman#Upgrading_packages)). **Accept when:** behavior is inspected on a real Quattro+ machine, the safe package/update contract is documented and tested, and a full OS update remains explicit if no safe narrower path exists.

## P1

- [ ] Assess moving core packages from direct pacman inventories to suitable mise `[bootstrap.packages]` declarations (`omarchy/packages/omarchy.arch`, `omarchy/scripts/packages-omarchy.sh`, `mise.toml`). Use Omarchy package commands or the AUR path where more appropriate, and preserve additive, noninteractive behavior. **Accept when:** each proposed package path is shown not to violate Arch partial-upgrade safety, and package ownership and dry-run behavior are verified before migration.
- [ ] Assess custom symlink, merge, and backup handling against mise `[dotfiles]` modes (`omarchy/scripts/sync-omarchy.sh`, `omarchy/configs/mise/dotfiles.toml`, `mise.toml`). **Accept when:** any migration preserves existing conflict handling, user-file backups, and Omarchy ownership boundaries, with conflict cases tested.
- [ ] Assess `keyboard-backlight.service` deployment and direct systemctl setup against mise `[bootstrap.linux.systemd.units]` (`omarchy/scripts/sync-omarchy.sh`, `omarchy/configs/systemd/user/keyboard-backlight.service`). **Accept when:** activation, daemon-reload, and update semantics are verified on Omarchy, and any migration preserves correct enable/start behavior.
- [ ] Add safe Omarchy Quattro+ validation or test seams for version detection, dotfile conflicts, package dry-runs, and service declaration (`bootstrap.sh`, `omarchy/scripts/omarchy-preflight.sh`, `omarchy/scripts/sync-omarchy.sh`, `.github/workflows/ci.yml`). **Accept when:** those contracts are testable in CI without package installation, systemctl changes, or other host mutation.

## P2

- [ ] Align `bootstrap.sh` Omarchy instructions with canonical `mise run sync` if pre-auth setup permits. **Accept when:** bootstrap presents one clear supported sync path after required authentication/setup, without bypassing prerequisite package installation.
