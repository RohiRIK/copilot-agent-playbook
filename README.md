# Copilot Agent Playbook

> **35 Production-Ready Microsoft 365 Copilot Agent Ideas for Enterprise Environments**

[![GitHub Pages](https://img.shields.io/badge/docs-GitHub%20Pages-blue?logo=github)](https://your-org.github.io/copilot-agent-playbook)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Agents](https://img.shields.io/badge/agents-35-brightgreen)](docs/catalog/index.md)
[![Domains](https://img.shields.io/badge/domains-5-blueviolet)](docs/catalog/by-domain.md)

---

## Quick Navigation

| Section | Description |
|---|---|
| [What is This?](#what-is-this) | Overview and purpose |
| [Quick Start](#quick-start) | Clone → Browse → Deploy |
| [Agent Catalog](#agent-catalog) | All 35 agents at a glance |
| [Architecture](#architecture-overview) | 4-tier design model |
| [Contributing](#contributing) | Add your own agents |

---

## What is This?

The **Copilot Agent Playbook** is a curated, enterprise-grade reference library of 35 Microsoft 365 Copilot agent ideas spanning identity, endpoint, security operations, compliance, and collaboration. Each idea is documented with:

- A clear **problem statement** grounded in real enterprise pain points
- A recommended **architecture pattern** (Declarative Agent, Copilot Studio, Power Automate, or Hybrid)
- **Implementation steps** a senior engineer can follow in a day
- **Required permissions** scoped to least-privilege principles
- **Security and compliance controls** for enterprise governance
- **Business value metrics** to justify investment to leadership

This playbook is designed for:
- **IT architects** evaluating where Copilot extensibility adds the most value
- **Security teams** looking to accelerate analyst workflows
- **Governance leads** who need AI guardrails built in from day one
- **Platform engineers** who want production-ready patterns, not demos

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/copilot-agent-playbook.git
cd copilot-agent-playbook

# 2. Browse agent ideas
ls ideas/

# 3. Deploy the docs site locally
pip install mkdocs-material
mkdocs serve

# 4. Deploy a declarative agent (example)
cd agents/declarative/break-glass-validator
# Follow README.md in that directory
```

---

## Agent Catalog

All 35 agents grouped by domain. Impact, effort, and risk are rated Low / Medium / High.

### Identity Agents (10)

| Agent | Impact | Effort | Risk | Architecture |
|---|---|---|---|---|
| [Break-Glass Account Validator](ideas/identity/break-glass-account-validator.md) | High | Low | Low | Declarative |
| [Secrets & Certificates Expiry Monitor](ideas/identity/secrets-certificates-expiry.md) | Medium | Low | Low | Power Automate |
| [Conditional Access Change Companion](ideas/identity/conditional-access-change-companion.md) | High | Medium | Medium | Copilot Studio |
| [Entra Sign-In Risk Explainer](ideas/identity/entra-signin-risk-explainer.md) | Medium | Low | Low | Declarative |
| [MFA Registration Gap Finder](ideas/identity/mfa-registration-gap-finder.md) | High | Low | Low | Declarative |
| [Least Privilege Builder (PIM)](ideas/identity/least-privilege-builder-pim.md) | High | Low | Low | Declarative |
| [App Registration Governance](ideas/identity/azure-app-registration-governance.md) | High | Medium | Medium | Copilot Studio |
| [Onboarding Access Assistant](ideas/identity/onboarding-access-assistant.md) | Medium | Medium | Medium | Copilot Studio |
| [Privileged Access Review](ideas/identity/privileged-access-review.md) | High | Medium | Medium | Copilot Studio |
| [Passwordless Rollout Coach](ideas/identity/passwordless-rollout-coach.md) | High | High | Medium | Hybrid |

### Endpoint Agents (5)

| Agent | Impact | Effort | Risk | Architecture |
|---|---|---|---|---|
| [Device Compliance Drift](ideas/endpoint/device-compliance-drift.md) | High | Medium | Low | Declarative |
| [Autopilot Readiness](ideas/endpoint/autopilot-readiness.md) | Medium | Medium | Low | Declarative |
| [Intune Troubleshooting](ideas/endpoint/intune-troubleshooting.md) | Medium | Medium | Low | Copilot Studio |
| [App Packaging Advisor](ideas/endpoint/app-packaging-advisor.md) | Medium | Low | Low | Declarative |
| [Stale Device Cleanup Planner](ideas/endpoint/stale-device-cleanup-planner.md) | Medium | Medium | Medium | Copilot Studio |

### SecOps Agents (8)

| Agent | Impact | Effort | Risk | Architecture |
|---|---|---|---|---|
| [Phishing Response](ideas/secops/phishing-response.md) | High | Medium | High | Copilot Studio |
| [Offboarding Orchestrator](ideas/secops/offboarding-orchestrator.md) | High | High | High | Hybrid |
| [SOC Triage Summarizer](ideas/secops/soc-triage-summarizer.md) | High | Medium | Medium | Copilot Studio |
| [Incident Postmortem Generator](ideas/secops/incident-postmortem-generator.md) | Medium | Medium | Low | Copilot Studio |
| [Sentinel Workbook Builder](ideas/secops/sentinel-workbook-builder.md) | Medium | Medium | Low | Declarative |
| [Exchange Mail Flow Diagnostic](ideas/secops/exchange-mail-flow-diagnostic.md) | Medium | Medium | Low | Copilot Studio |
| [Alert Noise Reduction](ideas/secops/alert-noise-reduction.md) | High | Medium | Medium | Copilot Studio |
| [SharePoint Oversharing Finder](ideas/secops/sharepoint-oversharing-finder.md) | High | Medium | Low | Declarative |

### Compliance Agents (5)

| Agent | Impact | Effort | Risk | Architecture |
|---|---|---|---|---|
| [Copilot Readiness & Governance](ideas/compliance/copilot-readiness-governance.md) | High | High | Medium | Hybrid |
| [Policy-to-Enforcement Mapper](ideas/compliance/policy-to-enforcement-mapper.md) | Medium | Medium | Medium | Copilot Studio |
| [Data Classification Assistant](ideas/compliance/data-classification-assistant.md) | Medium | Medium | Medium | Declarative |
| [External Sharing Exception Workflow](ideas/compliance/external-sharing-exception-workflow.md) | Medium | Low | Medium | Power Automate |
| [DLP Policy Tuning](ideas/compliance/dlp-policy-tuning.md) | High | Medium | Medium | Copilot Studio |

### Collaboration Agents (6)

| Agent | Impact | Effort | Risk | Architecture |
|---|---|---|---|---|
| [Tenant Health Dashboard](ideas/collaboration/tenant-health-dashboard.md) | High | Medium | Low | Power Automate |
| [Knowledge Base RAG](ideas/collaboration/knowledge-base-rag.md) | High | Low | Low | Declarative |
| [Teams Meeting Notes](ideas/collaboration/teams-meeting-notes.md) | Medium | Low | Low | Declarative |
| [License Optimization](ideas/collaboration/license-optimization.md) | Medium | Medium | Low | Power Automate |
| [Guest Access Policy](ideas/collaboration/guest-access-policy.md) | High | Medium | Medium | Copilot Studio |
| [Change Advisory Board Prep](ideas/collaboration/change-advisory-board-prep.md) | Medium | Low | Low | Declarative |

---

## Architecture Overview

The playbook uses a four-tier architecture model that balances capability against governance risk:

```
Tier 1: Declarative Agents
  Read-only, no approval required
  Grounded in Graph API / SharePoint knowledge
  Deploy in minutes via Teams Admin Center

Tier 2: Power Automate Agents
  Scheduled or event-triggered automation
  Adaptive card notifications
  Power Platform governance applies

Tier 3: Copilot Studio Agents
  Multi-turn conversation, approval flows
  Custom actions via connectors
  Requires Copilot Studio licensing

Tier 4: Hybrid Agents
  Combines Copilot Studio + Power Automate + Logic Apps
  Write capabilities with mandatory human-in-the-loop
  Full audit trail required
```

See [Architecture docs](docs/architecture/agent-patterns.md) for detailed decision guidance.

---

## Contributing

We welcome new agent ideas. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting.

1. Copy `ideas/_template.md` to the appropriate domain folder
2. Fill in all frontmatter fields and all required sections
3. Open a PR — the CI pipeline validates frontmatter automatically
4. A maintainer will review within 5 business days

---

## License

MIT — see [LICENSE](LICENSE) for details.
