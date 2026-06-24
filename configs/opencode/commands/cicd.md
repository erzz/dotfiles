---
description: CI/CD pipeline design and reusable workflow generation via cicd agent.
agent: cicd
---

Handle the CI/CD task the user has described. Use the workflows MCP to look up reusable workflow
interfaces before generating YAML. Return complete pipeline configuration with inline comments and
a brief explanation of jobs and dependencies.
