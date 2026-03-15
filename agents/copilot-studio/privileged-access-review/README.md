# Privileged Access Review — Deployment Guide
## Overview
Copilot Studio agent orchestrating quarterly privileged access reviews with Adaptive Card distribution, tracking, escalation, and attestation.
**Architecture:** Copilot Studio | **Approval:** Yes | **License:** M365 Copilot + Entra ID P2
## Prerequisites
- [ ] App registration: `RoleManagement.Read.All`, `User.Read.All`, `Directory.Read.All`
- [ ] Power Automate premium | SharePoint list for response storage
## Deployment
1. Create bot with review lifecycle topics. 2. Build PA flows: distribution, reminder scheduler, report generator.
3. Create SharePoint response list with versioning enabled.
4. Publish to Teams — restrict to IAM team.
