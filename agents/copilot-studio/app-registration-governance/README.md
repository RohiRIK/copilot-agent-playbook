# App Registration Governance — Deployment Guide

## Overview
Copilot Studio agent that audits app registrations and routes remediation through approval. Includes monthly scheduled sweep.

**Architecture:** Copilot Studio (Tier 3) | **Approval:** Yes | **License:** M365 Copilot + Entra ID

## Prerequisites
- [ ] Copilot Studio license | App registration: `Application.Read.All`, `AuditLog.Read.All`, `Directory.Read.All`
- [ ] Power Automate premium for approval flows and scheduled sweep

## Deployment
1. **Create bot** in Copilot Studio. Add topics: Governance audit, Review app, Over-permissioned apps.
2. **Build Power Automate actions:** Graph queries for app/SP inventory + sign-in activity.
3. **Build approval flow:** Adaptive Card approval for deletion/permission reduction routed to IAM lead.
4. **Schedule monthly sweep:** PA flow runs monthly, posts summary to IAM Teams channel.
5. **Restrict access** to IAM team.
