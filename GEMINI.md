# GEMINI - Copilot Agent Playbook Context

This project is an enterprise-grade reference library of 35+ Microsoft 365 Copilot agent ideas and implementations. It serves as a playbook for IT architects, security teams, and platform engineers to build and deploy governed AI agents.

## Project Overview

- **Purpose:** Provide production-ready patterns for Microsoft 365 Copilot extensibility across Identity, Endpoint, SecOps, Compliance, and Collaboration domains.
- **Core Architecture:** Follows a 4-tier model:
    - **Tier 1 (Declarative):** Read-only, Graph/SharePoint grounded, fast deployment.
    - **Tier 2 (Power Automate):** Scheduled/event-triggered automation.
    - **Tier 3 (Copilot Studio):** Multi-turn conversations with custom actions and connectors.
    - **Tier 4 (Hybrid):** Complex workflows with mandatory human-in-the-loop approvals.
- **Tech Stack:**
    - **Documentation:** MkDocs (Material theme), Markdown with YAML frontmatter.
    - **Automation:** Python (for catalog generation and frontmatter validation).
    - **Deployment:** PowerShell (for declarative agent deployment to Teams/M365).
    - **Dependencies:** `mkdocs-material`, `python-frontmatter`.

## Directory Structure

- `agents/`: Specific implementations of agents (manifests, instruction files).
- `docs/`: Project documentation, including the auto-generated agent catalog and architecture guides.
- `ideas/`: The source-of-truth for agent concepts. Each `.md` file represents an agent idea with detailed metadata.
- `scripts/`:
    - `build/`: Python scripts for generating catalogs and validating contributions.
    - `deployment/`: PowerShell scripts for deploying agents to M365 environments.
- `templates/`: Standardized templates for agent ideas, manifests, and system prompts.

## Key Commands

### Documentation & Catalog
- **Install Dependencies:** `pip install -r requirements.txt`
- **Run Local Docs:** `mkdocs serve`
- **Generate Catalog:** `python scripts/build/generate-catalog.py` (Updates `docs/catalog/index.md` and `docs/catalog/by-domain.md`)
- **Validate Agents:** `python scripts/build/generate-catalog.py --validate-only`

### Deployment (PowerShell)
- **Deploy Declarative Agent:** `pwsh scripts/deployment/Deploy-DeclarativeAgent.ps1`

## Development Conventions

### Creating a New Agent
1.  **Template:** Copy `ideas/_template.md` to the relevant domain folder in `ideas/`.
2.  **Metadata:** Fill in all required YAML frontmatter fields (see `CONTRIBUTING.md`).
3.  **Content:** Write at least 400 words covering the problem statement, architecture, implementation steps, and business value.
4.  **Instructions:** When creating an implementation in `agents/`, use `templates/agent-system-prompt-template.md` for the `instructions.md` file.
5.  **Navigation:** Update `mkdocs.yml` to include the new agent in the navigation.

### Coding Standards
- **Python:** Use `python-frontmatter` for parsing agent files. Ensure scripts are compatible with Python 3.9+.
- **PowerShell:** Deployment scripts should use the Microsoft Graph PowerShell SDK where applicable.
- **Markdown:** Use standard GitHub-flavored Markdown. Ensure all links are relative to support MkDocs building.

## Operational Protocol
- **Catalog Integrity:** Never manually edit `docs/catalog/index.md` or `docs/catalog/by-domain.md`; they are overwritten by the build script.
- **Validation:** Always run the `--validate-only` script before committing new agent ideas to ensure CI passes.
- **Least Privilege:** When defining `graph_permissions` in manifests or ideas, always prefer the narrowest possible scope (e.g., `User.Read.All` instead of `Directory.Read.All`).
