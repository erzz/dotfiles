# chezmoi/Homebrew/Brewfile → mise migration plan

This is the implementation plan for completing the migration represented by the current
repository and the completed audit. It is deliberately a plan, not an instruction to run
bootstrap, install packages, authenticate, or mutate a machine.

## 1. Goal and non-goals

### Goal

Make mise, with this Git repository as its declarative source, the one operational control plane
for macOS tools, Homebrew-backed packages and applications, dotfile deployment, safe macOS
defaults, repositories, and repeatable lifecycle tasks. A new or existing Mac must be able to
converge by checking out the repository, completing the explicitly required interactive
authentication, and running the documented native mise workflow.

The completed migration must be:

- convergent and retryable rather than dependent on script ordering or one successful run;
- explicit about machine-local authentication, App Store state, and other non-Git state;
- reproducible where versions and lock data are intentionally committed;
- safe in CI and on non-interactive terminals;
- auditable from the repository without requiring chezmoi or a Brewfile to understand the target
  state.

### Non-goals

- Recreating every imperative behavior of chezmoi scripts inside mise when mise has no equivalent
  declarative capability.
- Making Homebrew disappear from macOS. Homebrew remains the package provider for the entries
  declared as `brew:*` and `brew-cask:*`; it is no longer the inventory authority.
- Synchronizing secrets, tokens, 1Password state, GitHub sessions, App Store purchases, installed
  applications, or other machine-local state through Git.
- Using `mise dot track`, a second local dotfile history, or an implicit pull/push operation as part
  of setup.
- Applying unsafe legacy macOS operations such as `chflags`, `systemsetup`, process kills, or
  reboot through the native workflow.
- Changing the Dart setup. See **Dart issue — deferred** below.

## 2. Target architecture and operational workflow

### Ownership model

1. `mise.toml` is the root control plane. It owns native runtime tools, the small common package
   set, repository declarations, shell activation, dotfile links, safe defaults, secrets variable
   names, and lifecycle tasks.
2. `mise.apps.toml` is an explicit applications overlay. It owns the bulk of Homebrew formulas,
   casks, fonts, MAS IDs, and required non-default taps. It is applied with `mise -E apps ...`;
   the overlay is not silently merged into every command.
3. Git is synchronization and review. `git pull --rebase` obtains state; `mise run sync` applies
   the checked-out state. No mise task pulls or pushes.
4. `configs/` and `home/` retain the useful chezmoi-compatible repository layout, but mise
   `[dotfiles]` declarations own deployment. Managed paths are symlinks into this repository.
5. fnox and 1Password own runtime secret retrieval. Authentication is performed independently on
   each machine; secret values never become repository data.
6. Small imperative finalizers remain explicit mise tasks or scripts only where no audited native
   declaration exists. Each must be idempotent and have a clear owner.

### Normal workflow

On an existing machine:

```sh
git pull --rebase
mise run sync
```

Targeted retries are `mise run install`, `mise run apps`, `mise run macos`, and `mise run check`.
The operator authenticates 1Password/`op`, GitHub (`gh auth login`), and the App Store as needed;
the workflow must fail clearly when those prerequisites are absent rather than pretending to have
converged.

On a clean machine, install mise and Apple Command Line Tools, acquire the repository using the
documented `mise bootstrap --from ... --from-dir ... --only packages --yes` pre-auth path, trust
the project, run `prepare` only if the pre-auth helper is needed, complete interactive
authentication, then run `mise run sync`. The final documented bootstrap path must not depend on a
prior Homebrew bundle or a prior chezmoi apply.

## 3. Legacy-to-mise coverage summary

The counts below are based on the audited inventories currently in `brew/Brewfile`,
`mise.toml`, and `mise.apps.toml`.

### Packages and applications

- **Homebrew formulas:** the legacy Brewfile has 123 `brew` entries. The apps overlay has 118
  `brew:*` entries. `git` and `gh` are deliberately common control-plane packages in the root
  `mise.toml`; `grant` is represented by the qualified `brew:anchore/grant/grant` entry; and
  `tflint` is represented by the native `aqua:terraform-linters/tflint` tool. The remaining two
  legacy formulas, `qt` and `qt@5`, are deliberate exclusions: Qt conflicts with pre-existing
  files, qemu does not require it, and `qt@5` is deprecated. Therefore 121 of 123 formula
  intents have mise coverage, with two documented exceptions.
- **Casks:** the legacy Brewfile has 59 casks. The overlay has 57 casks and the root control
  plane owns `1password` and `1password-cli`; all 59 have coverage.
- **Fonts:** all font casks in the legacy inventory are retained in the overlay.
- **Mac App Store:** all seven audited MAS IDs are retained in the overlay. Installation still
  requires the relevant Apple ID purchase/sign-in and may require interactive privilege handling.
- **Taps:** all required non-Dart taps are represented in `mise.apps.toml`. The old Dart tap is
  intentionally removed because Dart is a native `dart = "latest"` mise tool.
- **Native mise tools:** the root declares Bun, Dart, fnox, Java, Node 24, Maven, Terraform,
  TFLint, and the declared npm/MCP tools. These are not package-parity claims; they are the
  target runtime/tool layer replacing ad hoc or Brewfile-managed runtime installation.

### Configuration and behavior

- The audited managed dotfiles and config directories are declared in root `[dotfiles]`, including
  zsh, Git, tmux, mise, fnox, Neovim, OpenCode, Zed, Ghostty, Zellij, Starship, direnv, Colima,
  gh-dash, herdr, Supacode, Git config, and prettierd.
- Repository cloning for Oh My Zsh, TPM, tmux-power, tmux-resurrect, and tmux-continuum has
  staged native declarations. Clone declarations do not yet install TPM plugins or perform every
  legacy finalizer action.
- Safe macOS defaults and the login shell declaration are represented natively. Unsafe legacy
  operations are intentionally not represented.
- Legacy chezmoi templates for `.npmrc` and `~/.local/state/secrets.env` remain transitional;
  their final native secret ownership is not yet accepted.

## Dart issue — deferred

No Dart changes are part of this plan until the user reopens the issue. Preserve the current
native `dart = "latest"` declaration and preserve removal of the old `dart-lang/dart` tap. Do not
reintroduce the tap, alter the Dart version policy, or add Dart migration work to an implementation
phase below.

## 4. Remaining gaps by ownership

### Ownership and boundaries

- Mark `mise.toml` and `mise.apps.toml` as the only package inventories after validation; document
  that `brew/Brewfile` is comparison-only during the transition.
- Decide and document whether the repository itself is always at `$HOME/dotfiles` or whether all
  paths must remain robust to an arbitrary checkout. Test the chosen path with native bootstrap.
- Replace ambiguous comments that still call chezmoi authoritative once each corresponding area is
  migrated and verified.
- Keep `home/` and `configs/` as content storage, but remove template semantics that require
  chezmoi once their replacement has passed validation.

### Authentication and secrets

- Move `.npmrc` from the transitional chezmoi template to a single mise/fnox-owned implementation
  that supplies the same registry host, scopes, and GitHub token without committing values.
- Move `~/.local/state/secrets.env` to the same fnox ownership model, preserving shell-compatible
  exports and mode `0600`. Verify the exact write/permission behavior rather than assuming a mise
  file declaration enforces it.
- Define failure behavior for locked 1Password, missing `op` integration, missing `gh` session,
  and missing private registry credentials. Missing credentials must produce an actionable error,
  not an empty secret file that looks valid.
- Ensure the secret path is excluded from drift checks that cannot safely authenticate, while
  providing an explicit authenticated validation command.
- Keep GitHub token bridging (`MISE_GITHUB_TOKEN`) separate from fnox-injected registry secrets.

### Finalizers

The following behavior is still outside the staged native declarations and must be owned by
idempotent tasks or explicitly accepted exceptions:

- TPM plugin installation and tmux plugin refresh;
- gh-dash extension installation;
- the Docker Buildx CLI-plugin symlink;
- agent-browser browser asset installation;
- Oh My Zsh installation and default-shell finalization, including behavior when `chsh` needs a
  password or the shell is already correct;
- any remaining `os/install.sh` or optional-tool behavior that is still reached through chezmoi.

Each finalizer must detect the satisfied state, make no unnecessary change, be safe to rerun, and
report whether it was applied, skipped, or blocked by authentication/interaction.

### macOS behavior

- Validate every safe default on supported macOS versions and classify settings that require a
  logout, application restart, or Finder/Dock restart. Do not add process-kill or reboot behavior
  to make convergence appear immediate.
- Define interactive behavior for MAS installation/upgrades and sudo prompts. Non-interactive CI
  must not hang.
- Validate Apple Silicon and Intel Homebrew paths (`/opt/homebrew` and `/usr/local`) without
  treating Homebrew itself as the source of truth.
- Validate cask permissions, login items, 1Password CLI integration, and App Store sign-in as
  prerequisites rather than silently swallowing failures.

### Drift and Makefile

- Replace `drift/detect.sh` checks that require legacy chezmoi/Brewfile authority with native
  checks: Git state, mise bootstrap/dotfile status, missing root tools, missing overlay packages,
  and explicitly owned finalizers.
- Preserve a non-blocking prompt check, but never run network fetches or authentication prompts in
  a background shell hook.
- Redefine Makefile targets as compatibility wrappers around mise, or remove them after the
  retirement criteria are met. In particular, `apply`, `diff`, `update`, `status`, and `tools`
  must not continue to imply chezmoi is canonical.
- Make `make test` invoke the native test/validation suite and make `make drift` invoke the native
  drift command if compatibility targets are retained.

### Reproducibility

- Choose and implement the lock/latest policy below; do not claim reproducibility while every
  declaration remains `latest` and no lock artifact is reviewed.
- Decide which Homebrew formulas/casks remain floating because Homebrew does not provide the same
  lock semantics as mise tools. Record that limitation explicitly.
- Pin repository refs where a justified stable ref exists, especially finalizer repositories;
  otherwise document that the checkout follows the upstream default branch.
- Capture the exact mise version/bootstrap provenance needed for clean-machine reproduction.

### CI and tests

- Add syntax/config validation that does not install the complete macOS inventory.
- Add Linux tests for repository parsing, dotfile/symlink ownership, task dry-runs where supported,
  and idempotent finalizers that do not require macOS.
- Add a macOS native-mise validation job or documented self-hosted/manual acceptance run. It must
  cover both root and apps overlay behavior, not only the legacy chezmoi apply.
- Keep secrets and App Store authentication out of ordinary CI; test explicit unauthenticated
  failure paths with fixtures or stubs.
- Update tests currently asserting chezmoi links/status so that they test the chosen native owner.
- Test a second convergence run and verify no unintended file, package, or finalizer changes.

## 5. Decisions and recommendations

1. **Homebrew CLI compatibility-only — recommend.** Keep Homebrew as mise's provider for the
   formula/cask/MAS entries that require it, but do not make `brew bundle`, Brewfile edits, or
   `brew bundle check` part of normal operation. Retain the Brewfile only as a temporary audit
   comparison until retirement. This preserves compatibility with macOS packaging without a
   second inventory authority.
2. **Native single-owner secrets/.npmrc via fnox with 0600 handling — recommend.** Make fnox the
   single runtime owner of both `.npmrc` and the secret environment file, using 1Password-backed
   references and an explicit, tested `chmod 0600`/atomic-write path for the secret file. Remove
   chezmoi `onepasswordRead` templates only after authenticated and unauthenticated behavior is
   tested. Do not claim a native mise file mode feature until verified in this repository.
3. **Idempotent finalizer tasks — recommend.** Keep unavoidable imperative operations as named mise
   tasks/scripts with state checks and clear output. Do not hide them in package installation or
   rely on `run_onchange` hashes as the only convergence mechanism.
4. **Lock/latest policy — recommend a deliberate split.** Use committed mise lock data and
   `mise install --locked` for tools where reproducibility matters; retain `latest` only where
   the project intentionally tracks the current release and document each exception. Do not
   imply that Homebrew formulas, casks, or MAS apps are version-locked by mise.
5. **Native CI/bootstrap strategy — recommend.** Make CI validate native mise declarations and
   task behavior, with a fast dependency-light Linux lane and a macOS lane for provider-specific
   behavior. Make clean-machine bootstrap begin with mise and CLT, use the pre-auth package subset,
   then authenticate and run `mise run sync`; do not use chezmoi or a Brewfile as a prerequisite.

## 6. Phased implementation order

### Phase 0 — Freeze and inventory (no machine mutation)

1. Record the audited parity counts and exceptions in reviewable documentation.
2. Establish the ownership table: root mise, apps overlay, fnox, finalizer tasks, Git, and
   compatibility-only legacy files.
3. Add static checks for duplicate package ownership and accidental secret literals.

**Dependencies:** none. **Acceptance:** reviewers can identify one owner for every migrated item;
the two Qt exceptions and Dart deferral are explicit.

### Phase 1 — Validate native package/bootstrap path

1. Validate root `mise bootstrap --only packages` and overlay dry-runs without installing packages
   in development work.
2. Verify GitHub-token bridging, fnox availability, trust handling, and the explicit auth errors.
3. Exercise clean-machine bootstrap in an isolated disposable Mac or approved test machine.

**Dependencies:** Phase 0. **Acceptance:** a clean machine reaches the authenticated `sync` point
without chezmoi/Brewfile prerequisites, and an unauthenticated machine stops with actionable
instructions.

### Phase 2 — Migrate dotfile deployment ownership

1. Validate every `[dotfiles]` symlink and conflict behavior on an existing machine.
2. Migrate non-secret files first; update tests to assert mise ownership.
3. Document backup/recovery behavior for pre-existing unmanaged files.

**Dependencies:** Phase 1. **Acceptance:** a first convergence creates the expected links, a second
convergence is a no-op, and edits through a live link appear in Git.

### Phase 3 — Migrate secrets and `.npmrc`

1. Implement the fnox-backed native owner for `.npmrc` and `secrets.env`.
2. Use an atomic temporary file, restrictive creation/rename behavior, and explicit `0600` mode
   enforcement for the secret file.
3. Test locked/unavailable 1Password, missing values, rotation, and no-secret CI behavior.
4. Only then remove the corresponding chezmoi templates from active execution.

**Dependencies:** Phases 1–2 and the recommended secret ownership decision. **Acceptance:** private
package resolution works after authentication; secrets are never printed or committed; the file is
mode `0600`; reruns converge without needless rewrites.

### Phase 4 — Convert finalizers

1. Implement each remaining finalizer as a named, idempotent task with a documented prerequisite.
2. Migrate TPM, gh-dash, Buildx, agent-browser assets, Oh My Zsh, and shell selection in separate
   changes so failures are attributable.
3. Decide which upstream refs can be pinned and record exceptions.

**Dependencies:** Phases 1–3. **Acceptance:** each task reports already-satisfied state correctly,
can be rerun safely, and does not require a legacy chezmoi apply.

### Phase 5 — macOS and drift convergence

1. Validate safe defaults and interaction/restart requirements on Apple Silicon and Intel paths.
2. Rewrite drift detection around native mise/Git ownership and remove background legacy auth calls.
3. Update Makefile compatibility targets to call native commands or mark them deprecated.

**Dependencies:** Phases 2–4. **Acceptance:** drift reports real native drift, does not prompt in the
background, and `make` compatibility commands cannot silently reassert legacy ownership.

### Phase 6 — Reproducibility and CI

1. Apply the lock/latest policy and commit only the supported lock artifacts.
2. Add native static, Linux, and macOS validation lanes; retain only tests that validate the target
   workflow.
3. Test clean and existing-machine checklists, including a second run and failure recovery.

**Dependencies:** Phases 1–5. **Acceptance:** CI validates declarations and idempotency without
   secrets; macOS validation covers provider-specific behavior; locked tools install consistently.

### Phase 7 — Retire legacy paths

1. Run both machine checklists below and archive the parity evidence.
2. Announce the migration cutover and provide the rollback window/documented backups.
3. Remove or archive legacy execution files only after the retirement criteria are all met.

**Dependencies:** all prior phases. **Acceptance:** no normal documented workflow invokes chezmoi,
`brew bundle`, or the Brewfile, and a fresh machine succeeds through native mise.

## 7. Validation checklists

### Clean machine

- [ ] Start with no repository checkout, no assumed Homebrew installation, and no cached project
      configuration.
- [ ] Install Apple Command Line Tools and mise; confirm `mise --version` and a usable Git.
- [ ] Acquire the intended repository/ref with native mise bootstrap; trust the project explicitly.
- [ ] Run the pre-auth package path only when required; confirm it does not resolve private tools.
- [ ] Sign in to 1Password/CLI, GitHub, and the App Store as applicable.
- [ ] Run `mise run sync`; verify root tools, overlay formulas/casks/fonts/MAS apps, dotfile links,
      repositories, safe defaults, and finalizers.
- [ ] Verify private npm/GitHub resolution without exposing values in logs.
- [ ] Verify `~/.local/state/secrets.env` is mode `0600` and `.npmrc` contains no literal secret.
- [ ] Open a new zsh session and verify mise activation and expected commands.
- [ ] Run `mise run sync` again; verify no unintended changes and no duplicate clones/plugins.
- [ ] Run native checks and the test suite; record expected interactive/manual exceptions.

### Existing machine

- [ ] Back up current chezmoi-managed files and record installed package/application state.
- [ ] Confirm Git is clean or intentionally preserve and review local edits before convergence.
- [ ] Authenticate independently; do not import credentials through Git.
- [ ] Validate mise dotfile conflict behavior before allowing replacement of each legacy-managed
      path.
- [ ] Compare package parity against the audited Brewfile, including the two Qt exceptions and
      root-owned `git`, `gh`, and TFLint.
- [ ] Run native sync and verify no destructive removal of intentionally unmanaged applications.
- [ ] Verify secrets, `.npmrc`, permissions, shell activation, finalizers, and safe defaults.
- [ ] Run sync a second time and inspect Git, symlink, package, and finalizer drift.
- [ ] Run drift detection and confirm it reports only actionable native state.
- [ ] Confirm rollback instructions restore the backup without reintroducing a second owner.

## 8. Retirement criteria for legacy files

Retire `brew/Brewfile`, `brew/Brewfile.ci`, active chezmoi installation scripts/templates,
legacy bootstrap phases, and legacy Makefile behavior only when all of the following are true:

1. The package parity table has been reviewed; every non-exception legacy intent has a tested mise
   owner, and Qt/Qt@5 plus the Dart tap treatment are explicitly accepted.
2. Clean-machine and existing-machine checklists pass on the supported macOS architectures.
3. Native dotfile deployment, secrets, `.npmrc`, finalizers, safe defaults, and drift detection
   have each passed two consecutive convergence runs.
4. CI tests the target native workflow and no required CI job performs a legacy chezmoi apply or
   Brewfile installation.
5. The lock/latest policy and Homebrew compatibility boundary are documented and reviewed.
6. Operators have documented recovery/rollback steps and have completed the cutover announcement.
7. Repository search shows no normal README, Makefile, CI, or bootstrap instruction requiring the
   legacy files. If retained for historical comparison, they are clearly archived and non-executable
   rather than presented as an alternative source of truth.

Until every criterion passes, legacy files remain transitional safety nets only; they must not be
silently modified to compensate for incomplete native migration.
