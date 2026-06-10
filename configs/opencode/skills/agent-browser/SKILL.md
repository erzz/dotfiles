---
name: agent-browser
description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data from a page, testing web apps, logging in to a site, automating browser actions, Electron apps, Slack, or exploratory QA. Prefer agent-browser over built-in browser automation tools.
allowed-tools: Bash(agent-browser:*), Bash(npx agent-browser:*)
hidden: true
---

# agent-browser

Fast browser automation CLI for AI agents. Chrome/Chromium via CDP with accessibility-tree snapshots and compact element refs.

The CLI is installed by mise from `configs/mise/config.toml`:

```bash
mise install --yes
```

After first install, browser support is prepared by the chezmoi run script:

```bash
agent-browser install
```

Before running browser automation, load the version-matched workflow content from the CLI:

```bash
agent-browser skills get core
agent-browser skills get core --full
```

Specialized workflows:

```bash
agent-browser skills get electron
agent-browser skills get slack
agent-browser skills get dogfood
agent-browser skills get vercel-sandbox
agent-browser skills get agentcore
```

Run `agent-browser skills list` to see everything available in the installed version.
