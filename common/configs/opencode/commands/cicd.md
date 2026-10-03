---
description: CI/CD pipeline design and reusable workflow generation.
---

Handle the CI/CD task the user has described. If a `workflows` MCP server is available, use it to
look up reusable workflow interfaces before generating YAML; otherwise state that the integration is
unavailable and work from the repository's existing workflow conventions. Return complete pipeline
configuration with inline comments and a brief explanation of jobs and dependencies.
