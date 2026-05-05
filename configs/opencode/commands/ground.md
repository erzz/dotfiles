---
description: Force a deeper project orientation pass and offer to write a project AGENTS.md.
agent: explore
subtask: true
---

Perform a thorough orientation pass on the current project. Map:

- Stack (languages, frameworks, key libraries)
- Top-level layout and what each directory contains
- How to run, test, and build (exact commands)
- Conventions: linters, formatters, naming, error handling, anything an
  outsider would get wrong on first try
- Entry points for common tasks
- Gotchas — non-obvious behavior or known foot-guns

Return your findings shaped as a draft project `AGENTS.md` matching the
"Project Brief Shape" defined in the global `AGENTS.md`. Keep it under
~120 lines. No prose padding.

The calling agent will offer the user the option to save the draft to
`./AGENTS.md`.
