# Backlog

Cross-platform follow-up for convergence policy, mise adoption, and validation. Platform-specific work is tracked in [macos/TODO.md](macos/TODO.md) and [omarchy/TODO.md](omarchy/TODO.md).

## P0

- [ ] Define package convergence and operating-system update semantics across macOS and Omarchy (`mise.toml`, `macos/scripts/sync.sh`, `omarchy/scripts/sync-omarchy.sh`; see [Omarchy update investigation](omarchy/TODO.md)). **Accept when:** documentation clearly distinguishes package installation from OS upgrades on each platform, defines what normal sync may update, and records safe repeatable behavior without relying on unsupported partial upgrades.

## P1

- [ ] Move ordered shell orchestration into mise TOML tasks where that makes dependencies and ownership clearer (`mise.toml`, `macos/scripts/apps.sh`, platform sync scripts). Respect serial task `run` execution versus parallel `depends`. **Accept when:** migrated task order, failure propagation, and side effects match the existing flow and task behavior has safe validation.

## P2

- [ ] Verify OpenCode MCP nesting compatibility against the supported OpenCode version (`common/configs/opencode/opencode.json`). The checked-in config uses `mcp.servers`, while public schema/docs show direct `mcp.<server>` entries; installed `opencode v2.0.22 mcp list` reports mise connected, so treat this as compatibility drift to verify before changing config. **Accept when:** the supported-version schema and runtime connection are tested, and any config change is justified by those results.
- [ ] Expand CI to exercise convergence contracts and host-safe behavior beyond syntax and declaration checks (`.github/workflows/ci.yml` and relevant test scripts). **Accept when:** representative sequencing, idempotence, and failure/conflict behavior are covered without mutating the CI host.
