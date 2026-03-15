# Guest Access Policy — Deployment Guide
## Overview
Copilot Studio agent for guest user lifecycle: invite, provision, review, cleanup.
**Architecture:** Copilot Studio | **Approval:** Yes | **License:** M365 Copilot + Entra ID
## Deployment
1. App registration: `User.ReadWrite.All`, `AuditLog.Read.All`, `Sites.Read.All`. 2. Create bot with lifecycle topics.
3. Build approval and quarterly review PA flows. 4. Publish — all employees (for invite requests) + IAM (for management).
