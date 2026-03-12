# Contributing to the Copilot Agent Playbook

Thank you for helping grow this library. Contributions can take several forms: new agent ideas, improvements to existing ideas, architecture docs, scripts, or bug fixes.

---

## How to Add a New Agent

### 1. Use the Template

Copy the standard template to the appropriate domain folder:

```bash
cp ideas/_template.md ideas/<domain>/<your-agent-slug>.md
```

Domains: `identity`, `endpoint`, `secops`, `compliance`, `collaboration`

### 2. Fill in All Frontmatter Fields

The CI pipeline validates that all required YAML frontmatter fields are present. Required fields:

```yaml
title:             # Human-readable title
emoji:             # Single emoji representing the agent
domain:            # identity | endpoint | secops | compliance | collaboration
tags:              # List of relevant tags
impact:            # low | medium | high
effort:            # low | medium | high
risk:              # low | medium | high
approval_required: # true | false
data_sources:      # List of data sources
architecture:      # declarative | copilot-studio | power-automate | hybrid
maturity:          # concept | pilot | production
last_updated:      # YYYY-MM-DD
```

### 3. Write Substantive Content

Each agent file must include all required sections with real content — not placeholders:

- **Problem Statement** — What breaks without this agent?
- **Agent Concept** — What does the agent do in plain English?
- **Architecture** — Which tier and why?
- **Implementation Steps** — Numbered, actionable steps
- **Required Permissions** — Least-privilege Graph API permissions
- **Security & Compliance Controls** — Guardrails built in
- **Business Value & Success Metrics** — Quantifiable outcomes
- **Example Use Cases** — 3+ realistic prompts or triggers
- **Alternative Approaches** — What exists today without this agent?
- **Related Agents** — Cross-links to related ideas in this playbook

Minimum 400 words of content (excluding frontmatter).

### 4. Update the Nav in mkdocs.yml

Add your new file to the appropriate section in `mkdocs.yml` under the `nav:` key.

### 5. Run Local Validation

```bash
python scripts/build/generate-catalog.py --validate-only
mkdocs serve
```

---

## Pull Request Process

1. Fork the repository and create a feature branch: `feat/agent-<slug>`
2. Write your agent file following the template
3. Update `mkdocs.yml` nav
4. Open a PR with the title: `feat: add <Agent Name> agent`
5. The CI pipeline will:
   - Lint markdown with `markdownlint`
   - Validate YAML frontmatter with the Python validation script
   - Run `yamllint` on all YAML files
   - Run `mkdocs build --strict` to ensure no broken links
6. A maintainer will review within 5 business days
7. After approval, the catalog is regenerated automatically on merge

---

## Improving Existing Agents

- Open an issue first describing the gap
- Reference the specific section that needs improvement
- PRs for existing agents should use the title: `fix: improve <Agent Name> <section>`

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating you agree to uphold this standard.

---

## What We Are Looking For

**High-value contributions:**
- Agents targeting real enterprise pain points
- Agents with clear least-privilege permission models
- Agents that include working Graph API queries or Power Automate flow outlines
- Agents with approval flows built in for write operations

**What we will not merge:**
- Agents that require Global Administrator for read-only operations
- Agents without a clear business value statement
- Template copies with placeholder content
- Agents that duplicate existing catalog entries without meaningful differentiation
