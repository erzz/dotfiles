# Dotfiles Simplification Proposal

> Research and recommendations only. No code changes are made by this document.
> Goal: identify concrete pain points, evaluate alternatives, and chart an
> incremental path toward a more **testable**, **reliable**, and **understandable**
> dotfiles repo.

---

## TL;DR

- **Stow itself is not the real problem** in this repo. It is doing exactly one
  job — symlinking — and doing it well. The friction comes from **everything
  built around it**: hidden coupling between `bootstrap.sh` and `Makefile`, the
  CI conflict-removal hack, the lack of a dry-run mode, and limited
  idempotency assertions.
- **Highest ROI quick wins** (no migration): collapse the duplicated stow
  loop into a single source of truth, add a dry-run/diff mode, expand `test.sh`
  into a real test harness, and run the full bootstrap in a Linux container
  on every PR.
- **If you migrate**, the strongest candidate is **chezmoi**. It folds the roles
  of stow, parts of bootstrap, and the drift script into one tool with
  first-class templating, dry-run, diff, and 1Password integration that fits
  your fnox-adjacent workflow. **dotbot** is the lighter alternative if you
  want to keep most of the current shape.
- Recommended path: do the quick wins first (1–2 evenings of work), live with
  them for a few weeks, then decide whether the residual friction justifies a
  chezmoi migration.

---

## 1. Concrete pain points in the current setup

These are observations grounded in the actual files in this repo, not
generic stow complaints.

### 1.1 Two parallel sources of truth for "what to stow"

`bootstrap.sh` defines `STOW_PACKAGES` as a hardcoded array (lines 97–116),
and `Makefile` defines a separate `.PHONY` list and one target per package
(lines 1, 32–113). Adding a new package means editing **both**, and the lists
can silently drift out of sync. `colima` is in `bootstrap.sh` but is also a
make target — easy to miss when adding the next one.

### 1.2 Stow's failure mode is hostile in CI

`bootstrap.sh` lines 119–130 contain a workaround that scans every file in
every package and deletes any non-symlink at the same path in `$HOME` before
running stow. This exists because GitHub runners ship a default `.gitconfig`
that collides with `git/.gitconfig`. The workaround is correct but:

- It is **destructive** (`rm -f`) and only safe because it is gated by
  `--ci`. A typo in the gate would wipe real user files.
- It papers over stow's biggest UX problem: `stow` aborts with an opaque
  "existing target is neither a link nor a directory" message and offers no
  `--adopt` or `--force` that is safe on real machines.

### 1.3 No dry-run / diff path

There is no way to ask "what would change if I ran bootstrap right now?"
without actually running it. `stow -n` exists but is never surfaced through
`make` or `bootstrap.sh`, and `brew bundle` changes, mise installs, and TPM
plugin installs have no preview at all.

### 1.4 `test.sh` validates **state**, not **transitions**

`test.sh` is good at answering "is the machine currently configured?" but
cannot answer:

- Is `bootstrap.sh` idempotent? (Run it twice — does anything change on the
  second run? Right now nothing checks.)
- Does removing one symlink and re-running `make <pkg>` restore it
  cleanly?
- Does `stow --restow` actually converge from a partially-broken state?

There is also no negative testing — e.g., "if a config file disappears,
does the right tool fail loudly or silently fall back to defaults?".

### 1.5 Hidden coupling between stages

Several things in `bootstrap.sh` are silently order-dependent:

- Stage 2 stows `mise/` so Stage 4 can run `mise install`.
- Stage 2 stows `npm/` so Stage 4 can install `@ingka` packages later.
- Stage 4 assumes `gh` is on PATH because Stage 1 installed it via
  `brew bundle`.

The Makefile partially encodes this with prerequisites
(`mise-install: mise npm`), but `bootstrap.sh` does not — it relies on
the linear order of stages. A reader has to mentally diff the two.

### 1.6 The `colima` migration block lives in two places

Lines 86–94 of `bootstrap.sh` and lines 35–41 of the Makefile both contain
the same legacy-`~/.colima` migration logic. Any future migration block
will likely repeat the pattern.

### 1.7 Drift detection is shallow

`drift/detect.sh` only checks the **git** state of `~/dotfiles` (uncommitted
changes, behind remote). It does not detect:

- A symlink that has been replaced by a real file (e.g., an app
  rewrote its own config).
- A package that exists in the repo but was never stowed.
- Brewfile drift (`brew bundle check` is not invoked).
- mise tools missing or at wrong versions.

### 1.8 Per-package READMEs do not exist

When something breaks in `nvim/`, `tmux/`, or `opencode/`, there is no
package-local note explaining what extra setup that package needs (TPM,
Oh My Zsh, gh extensions, mise-managed runtimes). All of that lives only
in `bootstrap.sh`.

---

## 2. Comparison of alternatives

Evaluated against five criteria that matter in **this** repo:

| Tool | Symlink mgmt | Templating / per-host | Secrets story | Dry-run / diff | Migration cost from stow |
|---|---|---|---|---|---|
| **GNU Stow (current)** | Yes (symlinks) | None | External (fnox) | `stow -n` only | n/a |
| **chezmoi** | Yes (copies or symlinks) | Go templates, OS/arch/host conditions | Built-in 1Password, age, gpg | First-class (`chezmoi diff`, `apply -n`) | Medium — file layout changes |
| **yadm** | Bare git repo over `$HOME` | Jinja templates, alt files | Built-in gpg/transcrypt | `yadm status` (git-based) | High — different mental model |
| **dotbot** | Yes (symlinks) | None (YAML config) | External | None native | Low — keep layout, swap orchestrator |
| **rcm** (`rcup`) | Yes (symlinks) | Tag-based per-host | External | `lsrc` lists planned actions | Low-medium |
| **Nix home-manager** | Declarative, generated | Full Nix language | sops-nix, agenix | `home-manager build` | Very high — paradigm shift |
| **Plain `make` + `ln`** | Manual | Whatever you write | External | Whatever you write | Low, but you reinvent stow |
| **Custom shell script** | Manual | Manual | External | Manual | Low, but unmaintainable at scale |

### Verdict per option

- **chezmoi** is the only tool that **collapses multiple current concerns**
  (symlinking + templating + secrets + diffing + drift) into one tool with a
  good UX. The cost is restructuring directories from
  `pkg/.config/foo/bar` to `dot_config/foo/bar` and learning the template
  language. Worth it if you want one tool instead of three.
- **dotbot** is the lowest-disruption swap: keep your current directory
  layout, replace `bootstrap.sh`'s stow loop with a `dotbot` config, and
  gain a declarative manifest. You still need fnox separately.
- **yadm** has a clever idea (bare repo over `$HOME`) but is the worst fit
  here because it makes "what is and isn't tracked" implicit, and you
  already have a clear repo structure you like.
- **home-manager** is a category error for this codebase unless you are
  ready to adopt Nix on macOS (nix-darwin) — that is a much bigger
  decision than "stow is confusing".
- **Plain make + ln** or **custom script** would just rebuild stow,
  badly. Skip.

---

## 3. Testability improvements (orthogonal to any migration)

These apply whether you stay on stow or move to chezmoi/dotbot.

### 3.1 Idempotency assertion in CI

Add a job that runs:

```bash
./bootstrap.sh --ci
./bootstrap.sh --ci   # second run must produce no diff in $HOME
git -C $HOME diff --no-index <snapshot1> <snapshot2>
```

Concretely: snapshot `find $HOME -type l -printf '%p -> %l\n'` after each
run and assert equality. This catches regressions where a step
accidentally re-creates files instead of being convergent.

### 3.2 Linux container test, not just macOS runner

The current `macos-latest` job is slow (often 10+ min) and cannot run on
PRs from forks easily. Add a faster Linux container job that exercises
the **stow + symlink + idempotency** parts (everything that does not need
macOS). This is where most regressions actually happen.

Suggested image: `archlinux:base-devel` or `debian:stable-slim` plus
`stow git zsh tmux make`. Runs in ~30 seconds.

### 3.3 Dry-run / plan mode

Add `./bootstrap.sh --dry-run` that:

- Runs `stow -n -v` for each package and reports planned link actions.
- Runs `brew bundle check --verbose` instead of `brew bundle`.
- Runs `mise ls --missing` instead of `mise install`.
- Skips all destructive steps.

This becomes both a developer tool ("what would change?") and a CI gate
("dry-run on PR, real run on main").

### 3.4 Negative tests

Add cases to `test.sh` (or a new `tests/` dir):

- Delete `~/.gitconfig` symlink, run `make git`, assert restored.
- Replace `~/.config/starship.toml` with a real file, run `make starship`,
  assert the conflict is reported (not silently overwritten on real
  machines).
- Run `./bootstrap.sh --ci` from a clean `$HOME`, then a second time, and
  diff the symlink graph.

### 3.5 Per-package smoke commands

Define an optional `tests/<pkg>.sh` for any package that needs it (e.g.
`tests/git.sh` runs `git config --global --get-all` checks; `tests/zsh.sh`
spawns `zsh -ic 'echo $ZSH_THEME'`). `test.sh` becomes a thin runner
that discovers these. This keeps per-tool knowledge near the tool.

### 3.6 Brew + mise drift checks

Extend `drift/detect.sh`:

```bash
brew bundle check --file=brew/Brewfile        || MESSAGES+=("brew drift")
mise ls --missing 2>/dev/null | grep -q .     && MESSAGES+=("mise drift")
# Symlink integrity
find "$HOME" -maxdepth 4 -lname "*dotfiles*" -xtype l -print | head -1 \
  && MESSAGES+=("broken dotfiles symlinks")
```

### 3.7 ShellCheck + shfmt as a pre-commit hook

The CI already runs ShellCheck. Move it to a local pre-commit hook
(`lefthook` or `pre-commit`) so problems are caught before push. Same for
`shfmt -d`.

---

## 4. Recommended migration path (phased, ROI-ordered)

### Phase 0 — Quick wins inside the current stow setup (1–2 evenings)

Lowest risk, biggest immediate clarity. Do these even if you never migrate.

1. **Single source of truth for packages.** Move the package list into
   `packages.txt` (one per line) and have both `bootstrap.sh` and
   `Makefile` read it. Eliminates the current Makefile/bootstrap drift.
2. **Add `--dry-run` to `bootstrap.sh`.** As described in 3.3.
3. **Make `make stow-all` and `make unstow-all` first-class targets.**
   Removes the need to read `bootstrap.sh` to understand how stow is
   invoked.
4. **Move the CI conflict-removal hack into a separate, named function**
   (`prune_conflicts_for_ci`) and add a `--prune-conflicts` flag so the
   behavior is opt-in and reviewable, not silently coupled to `--ci`.
5. **Idempotency CI job.** Run `bootstrap.sh --ci` twice and diff symlinks.
6. **Brewfile + mise drift in `drift/detect.sh`.** As described in 3.6.

Result: same tool stack, much higher confidence and clarity. No user-
visible changes.

### Phase 1 — Test harness restructure (1 weekend)

7. **Split `test.sh` into `tests/` directory** with per-package scripts and
   a discovery runner. Adopt a tiny convention (`tests/<name>.sh` exits 0
   on pass).
8. **Add Linux container job to CI** (3.2). Run on every PR; the macOS job
   stays as a slower nightly / on-merge gate.
9. **Add negative tests** (3.4).

Result: real test pyramid, fast PR feedback, regressions caught before
they ship.

### Phase 2 — Decision point: migrate or stay (1 day of evaluation)

After living with phases 0 and 1 for a few weeks, re-evaluate honestly:

- If the residual friction is **mostly about templating and per-host
  variation** (you start needing different `.gitconfig` for work vs.
  personal, or different `Brewfile` for laptop vs. desktop) → migrate to
  **chezmoi**.
- If the friction is **just about the stow loop being noisy** → adopt
  **dotbot** as a thin replacement.
- If neither is true → **stay on stow**. You've already eliminated the
  worst pain points.

### Phase 3a — chezmoi migration (if chosen, ~1 week elapsed, ~1 day actual)

Migration outline:

1. `chezmoi init` against this repo in a scratch branch.
2. Convert each package directory: `git/.gitconfig` →
   `dot_gitconfig`, `nvim/.config/nvim/` → `dot_config/nvim/`, etc.
   `chezmoi import` can do most of this.
3. Replace `bootstrap.sh` Stage 2 with `chezmoi apply`.
4. Replace `drift/detect.sh` symlink checks with `chezmoi diff`.
5. Move 1Password lookups currently done by fnox at runtime into chezmoi
   templates where appropriate (keep fnox for everything that needs
   runtime injection into shells/processes; chezmoi handles file-time
   secrets).
6. Update `test.sh` to verify chezmoi-managed targets instead of stow
   symlinks.
7. Delete `STOW_PACKAGES`, the CI conflict hack, and the Makefile's
   per-package stow targets. Keep tool-installation targets (`mise`,
   `tmux` plugins, `gh-dash` extension, etc.) — those are independent of
   the symlinking strategy.

Risk: chezmoi defaults to **copies, not symlinks**. Decide explicitly
whether you want copies (safer, no dangling links, but edits in `$HOME`
don't flow back) or symlinks (current behavior; configurable via
`symlink` attribute or `.chezmoiroot`). Recommend **copies** for
configs you don't edit live, **symlinks** for configs you actively iterate
on (`nvim`, `opencode`, `tmux`).

### Phase 3b — dotbot migration (alternative, ~half a day)

1. Add `dotbot` as a submodule.
2. Generate `install.conf.yaml` from `STOW_PACKAGES` + a small script.
3. Replace Stage 2 of `bootstrap.sh` with `./dotbot -c install.conf.yaml`.
4. Keep everything else unchanged.

Risk: minimal. dotbot is a lightweight tool; the gain is mostly
declarative clarity, not capability.

---

## 5. Quick wins shortlist (do these first, regardless)

In strict ROI order:

1. **`packages.txt` as single source of truth** — kills Makefile/bootstrap
   drift in <1 hour.
2. **`bootstrap.sh --dry-run`** — gives you a "plan mode" you currently
   lack, ~2 hours.
3. **Idempotency CI job** — catches a whole class of regressions, ~1 hour.
4. **Linux container PR job** — turns a 10-minute feedback loop into 30
   seconds, ~2 hours.
5. **Drift script: brew + mise + broken-symlink checks** — makes
   `drift/detect.sh` actually useful, ~1 hour.
6. **Move CI conflict-pruning behind a named flag** — removes a footgun,
   <30 min.
7. **Pre-commit hook for ShellCheck + shfmt** — catches issues before
   push, ~30 min.

Total: a single focused day. None of these require choosing a new tool.

---

## 6. Risks and non-goals

### Risks

- **Migration regret.** chezmoi is a real switch; the layout differences
  are non-trivial. Phase 0–1 should reduce the probability that you need
  to migrate at all.
- **Breaking the working setup.** Any change to `bootstrap.sh` should be
  validated by the new idempotency + container CI jobs **before** being
  merged.
- **Over-testing.** Negative tests and per-package smoke tests can balloon
  if you let them. Cap each `tests/<pkg>.sh` at 30 lines and only test
  what would silently break.
- **Secrets coupling.** fnox + 1Password is working well. Do not let any
  migration absorb this responsibility unless the new tool is
  demonstrably better — chezmoi templates + 1Password are good but not
  obviously superior to fnox at runtime injection.

### Non-goals

- This proposal does **not** recommend Nix/home-manager.
- It does **not** propose changing the per-tool configs themselves
  (your nvim, zsh, tmux configurations are out of scope).
- It does **not** propose dropping macOS support or testing.

---

## 7. Decision checklist

Use this to drive the next conversation:

- [ ] Approve / reject Phase 0 quick wins as a batch.
- [ ] Approve / reject Phase 1 test harness restructure.
- [ ] After phases 0–1 land and bake: re-read Section 4 Phase 2 and
      decide on migrate vs. stay.
- [ ] If migrating: chezmoi (heavier, more capability) or dotbot
      (lighter, same shape)?

---

## Appendix A — File references

Specific files that motivated these recommendations:

- `bootstrap.sh:97-116` — hardcoded `STOW_PACKAGES` array
- `bootstrap.sh:119-130` — destructive CI conflict-removal block
- `bootstrap.sh:86-94` and `Makefile:35-41` — duplicated colima migration
- `Makefile:1` and `Makefile:32-113` — parallel per-package targets
- `test.sh` — state-only verification, no transition checks
- `drift/detect.sh` — git-only drift, no symlink/brew/mise checks
- `.github/workflows/main.yml` — single macOS job, no Linux, no
  idempotency assertion

## Appendix B — Further reading

- chezmoi docs: <https://www.chezmoi.io/>
- dotbot: <https://github.com/anishathalye/dotbot>
- yadm: <https://yadm.io/>
- nix-darwin + home-manager: <https://github.com/LnL7/nix-darwin>
- Lars Kappert, "Managing dotfiles with chezmoi": good migration walkthrough
- Anish Athalye, "Managing dotfiles" (the original dotbot rationale)
