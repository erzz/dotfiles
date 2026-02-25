---
name: source-control
description: Guidelines for git commits, branching, pushing, and pull requests using conventional commits
---

## Source Control Workflow

Follow these rules whenever performing any source control operations (commits, pushes, branching, pull requests).

### Conventional Commits

All commit messages **must** follow the [Conventional Commits](https://www.conventionalcommits.org/) standard:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Include a scope when it adds clarity (e.g., `feat(auth): add OAuth2 support`). Use `!` after the type/scope for breaking changes (e.g., `feat!: drop Node 14 support`). Add a `BREAKING CHANGE:` footer in the body when needed.

### Before Committing

1. Review all staged and unstaged changes.
2. Draft the commit message following Conventional Commits.
3. body's lines must not be longer than 100 characters [body-max-line-length]
4. **Present the proposed commit to the user and wait for explicit approval before creating the commit.** Do not commit without confirmation.

### Before Pushing

1. **Always ask the user for permission before pushing to any remote.** Never push without explicit approval.
2. **Pushing directly to `main` or `master` is almost never acceptable.** If the user asks to push to `main`/`master`, warn them that this is unusual and confirm they truly intend to do so.
3. The standard workflow is to work on a **short-lived feature branch** that will be merged via a pull request.

### Branching

- When changes are ready to be pushed, check if the current branch is `main` or `master`.
- If it is, **suggest creating a new branch** with a descriptive name following the pattern `<type>-<short-description>` (e.g., `feat-add-user-auth`, `fix-null-pointer-dashboard`).
- Only proceed on `main`/`master` if the user explicitly insists after being warned.

### Pull Requests

After pushing a branch, **ask the user if they would like to create a pull request** and in which state:

- **Draft** -- for work-in-progress that needs further iteration
- **Ready for review** -- for changes that are complete and ready to be reviewed

Do not create a pull request without asking. When creating one, write a clear title and body summarizing the changes.
