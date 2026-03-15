# Onboarding Access Assistant — Deployment Guide
## Overview
Copilot Studio agent for structured employee access provisioning using role-based templates.
**Architecture:** Copilot Studio | **Approval:** Yes (non-template access) | **License:** M365 Copilot
## Prerequisites
- [ ] SharePoint list with role access templates (job title + department → groups)
- [ ] App registration: `User.Read.All`, `Group.Read.All`
- [ ] Power Automate premium for approval flows
## Deployment
1. Create Copilot Studio bot with onboarding topic flow.
2. Add PA actions: template lookup, approval routing, ITSM ticket creation.
3. Publish to Teams — target: HR, hiring managers, IT helpdesk.
