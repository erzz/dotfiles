## Skapa Design System

You work within the INGKA design ecosystem and have access to MCP tools for the Skapa Design System. Use them proactively — never guess component APIs.

### Available Skapa Tools

- **skapa_skapa_help** — Full Skapa Design System documentation prompt.
- **skapa_list_components** — All available components organised by category.
- **skapa_get_component** — Detailed docs for a specific component including props, variants, usage guidelines. Set `includeExamples: true` for code samples.
- **skapa_react_dev_help** — React development guide with Skapa examples. Use `component`, `topic`, and `showExamples` parameters.
- **skapa_styles_dev_help** — SCSS/CSS styles developer guide.
- **skapa_webc_dev_help** — Web Components developer guide for non-React contexts.
- **skapa_list_webc_components** — Available Skapa Web Components by category.

### Skapa Compliance Rules

- Always use Skapa components when one exists for the pattern. Do not build custom components that duplicate Skapa functionality.
- Use Skapa design tokens for spacing, colour, typography, and elevation — never hardcode values.
- Follow Skapa's composition patterns as documented. Use the component's intended API rather than overriding styles.
- Import styles correctly following the Skapa styles guide (use `skapa_styles_dev_help` when unsure).
- When Skapa does not provide a component for a given pattern, build a custom component that follows Skapa's visual language and token system.
- Do not use third-party UI libraries (Material UI, Chakra, etc.) when Skapa provides the equivalent.

### Accessibility Standards

Accessibility is non-negotiable. For every component and page:

- **Semantic HTML** — Use correct elements (`button`, `nav`, `main`, `section`, `h1`–`h6`). Never use `div` or `span` for interactive elements.
- **Keyboard navigation** — All interactive elements must be reachable via keyboard. Ensure logical tab order and visible focus indicators.
- **ARIA attributes** — Apply only when native semantics are insufficient. Prefer native HTML over ARIA.
- **Colour contrast** — WCAG AA ratios (4.5:1 normal text, 3:1 large text). Use Skapa tokens to stay compliant.
- **Screen reader support** — Provide `aria-label`, `aria-labelledby`, or `aria-describedby` where visual context alone is insufficient. Include `alt` on all informative images.
- **Form accessibility** — Associate every input with a `<label>`. Use `aria-required`, `aria-invalid`, `aria-describedby` for validation. Group related fields with `<fieldset>` and `<legend>`.
- **Motion** — Respect `prefers-reduced-motion`. No content flashing more than three times per second.
- **Responsive** — Usable at 200% zoom and across all viewport sizes without loss of information.

Flag any accessibility issues found in existing code and provide the fix.

### Output Conventions

When producing a component, page, or styles:
- Include import statements, the component/markup code (with proper typing), a brief usage example, and notes on accessibility and design-token choices.
- Co-locate styles using Skapa SCSS patterns or CSS modules. Name components PascalCase, files to match.
