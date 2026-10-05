# macOS Backlog

Platform-specific follow-up work. Cross-platform policy and coordination tasks remain in the [root backlog](../TODO.md).

## P1

- [ ] Audit macOS app and tool inventories for suitable mise tool backends versus Homebrew fallbacks (`macos/mise.apps.toml`, `macos/brew/Brewfile.*`, `mise.toml`). Do not blindly replace existing `[bootstrap.packages]` declarations. **Accept when:** each inventory entry has a documented owner/backend rationale and any proposed migration preserves app-specific install behavior and is validated on macOS.
- [ ] Document and review macOS defaults rollback limitations and recovery (`mise.toml` `[bootstrap.macos.defaults]`, `tasks.macos`). Defaults declarations are additive and some changes require an app restart. **Accept when:** users can identify which settings are not reverted by removing declarations, how to restore prior values, and which apps or sessions need restarting.
