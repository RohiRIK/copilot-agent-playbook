# Entra Sign-In Risk Explainer — Deployment Guide

## Overview
Declarative agent that translates Entra ID Protection risk events into plain-English explanations for helpdesk and junior analysts.

**Time to deploy:** ~30 minutes | **License:** M365 Copilot + Entra ID P2

## Prerequisites
- [ ] M365 Copilot license | Entra ID P2 (for risk detection data)
- [ ] App registration with `IdentityRiskyUser.Read.All`, `IdentityRiskEvent.Read.All`
- [ ] SharePoint site with investigation runbooks (optional but recommended)

## Deployment
1. **App Registration** — Name: `CopilotAgent-RiskExplainer`. Grant admin consent.
2. **Configure manifest.json** — Update Graph plugin endpoint.
3. **Package & Upload** — `Compress-Archive -Path manifest.json, instructions.md -DestinationPath entra-risk-explainer.zip` → Teams Admin Center.
4. **Restrict Access** — Helpdesk team + Tier-1 security analysts only.
5. **Test** — Ask: *"Why was john@contoso.com flagged as high risk?"*

## Troubleshooting
| Issue | Resolution |
|-------|-----------|
| No risk data | Requires Entra ID P2 and `IdentityRiskEvent.Read.All` |
| Empty risk history | User may have no recent risk detections |
