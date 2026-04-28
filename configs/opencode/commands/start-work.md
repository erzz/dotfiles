---
description: Run the native orchestration flow for a task.
argument-hint: <task>
agent: orchestrator
subtask: true
---

Drive this task from framing to implementation and verification:

{{$ARGUMENTS}}

Follow the canonical routing in `AGENTS.md` § "Delegation Rules". That file is the source of truth — do not invent a parallel decision flow here.

Keep all handoffs compact: summary, files, steps, risks, verification.

If you hit a true blocking question that requires user input, return your result prefixed with
`BLOCKED: <question>` on its own line so the calling agent surfaces it immediately. Do not guess on
irreversible choices; do not silently stop. For minor ambiguities, pick the most reasonable option,
note the assumption, and continue.
