---
title: Secure Configuration Drift Reporter
slug: secure-config-drift-reporter
domain: compliance
agent_type: copilot-studio
effort: medium
impact: high
status: idea
tags: [purview, m365, configuration, baseline, drift, compliance]
---

# Secure Configuration Drift Reporter

## Problem Statement

Microsoft 365 tenants drift from security baselines over time as admins make ad-hoc changes, new services are enabled, or default settings change with product updates. Security teams lack continuous visibility into configuration gaps versus Microsoft's recommended baselines (CIS, MISA, Microsoft Secure Score).

## Agent Overview

A Copilot Studio agent that compares the current tenant configuration against Microsoft 365 security baselines (CIS Benchmark, Microsoft Secure Score recommendations, and internal policy baselines). It generates drift reports, prioritises remediation, and tracks progress over time.

## Key Capabilities

- **Baseline comparison** — maps current tenant settings against CIS M365 Benchmark and Microsoft Secure Score controls
- **Drift detection** — identifies controls that have regressed since the last scan
- **Risk prioritisation** — ranks drift items by severity (Critical/High/Medium/Low)
- **Remediation guidance** — provides step-by-step fix instructions per control
- **Change attribution** — links configuration changes to admin activity logs
- **Trend tracking** — tracks Secure Score over time and surfaces regressions

## Example Prompts

- "What M365 settings have drifted from our security baseline this week?"
- "Show me all Critical configuration gaps versus the CIS M365 Benchmark."
- "Which Secure Score controls have regressed since last month?"
- "Give me remediation steps for the legacy authentication drift item."

## Data Sources

- Microsoft Secure Score API (Graph API)
- Microsoft 365 Defender configuration assessment
- Azure Policy compliance reports
- Entra ID audit logs (for change attribution)
- CIS Microsoft 365 Foundations Benchmark

## Implementation Notes

**Agent type:** Copilot Studio (with Power Automate flows for scheduled scans)

**Connectors required:**
- Microsoft Graph (Secure Score, tenant settings)
- Microsoft 365 Defender
- SharePoint (baseline policy documents)

**Triggers:** Scheduled daily scan + on-demand via chat

**Output:** Drift report card in Teams adaptive card format + SharePoint document for audit trail

## Governance & Safety

- Read-only access to configuration APIs — no remediation actions taken automatically
- All drift reports stored in SharePoint with retention policy
- Remediation requires admin approval via Power Automate approval flow
- Alerts routed to Security Operations team via Teams channel

## Business Value

| Metric | Impact |
|--------|--------|
| Time to detect configuration drift | Days → Minutes |
| Audit preparation effort | Reduced by ~60% |
| Secure Score improvement | Continuous tracking drives 10-20 point gains |
| Compliance posture | Automated evidence for ISO 27001, SOC 2, NIST |

## Related Agents

- [DLP Policy Tuning Agent](dlp-policy-tuning.md) — Purview DLP optimisation
- [Copilot Readiness Assessor](copilot-readiness-assessor.md) — tenant readiness assessment
- [Data Classification Assistant](data-classification-assistant.md) — Purview labelling
