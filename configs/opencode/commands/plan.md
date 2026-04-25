---
description: Create a short execution plan using the native planner agent.
argument-hint: <task>
agent: planner
subtask: true
---

Turn this request into a concise execution plan:

{{$ARGUMENTS}}

Load the `planning` skill and return only this compact structure:

1. Summary
2. Files
3. Steps
4. Risks
5. Verification
