# Break-Glass Account Validator — Deployment Guide

## Overview

Declarative agent that validates emergency access accounts against CIS and Microsoft security benchmarks. Read-only, no approval required, deploys in Teams in under 30 minutes.

**Maturity:** Concept → ready to build
**Time to deploy:** ~30 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] Entra ID P1 or P2 (for Conditional Access policy read)
- [ ] Global Administrator or Application Administrator to create the app registration
- [ ] Teams admin to publish the agent

---

## Step 1: Create App Registration

1. Go to [Entra ID > App registrations > New registration](https://entra.microsoft.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Name: `CopilotAgent-BreakGlassValidator`
3. Supported account types: Single tenant
4. Add API permissions (Application, not Delegated):
   - `User.Read.All`
   - `AuditLog.Read.All`
   - `Policy.Read.All`
   - `Directory.Read.All`
5. Grant admin consent
6. Create a client secret (store in Key Vault, not in this repo)

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `actions` section with your Graph API plugin endpoint
- Or use Power Platform custom connector pointed at Graph

---

## Step 3: Package and Upload

```powershell
# Zip the agent package
Compress-Archive -Path manifest.json, instructions.md -DestinationPath break-glass-validator.zip

# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Restrict Access

In Teams Admin Center > Manage apps > Break-Glass Account Validator:
- Set availability to specific users/groups
- Assign only to: Identity Admins, Security Operations

---

## Step 5: Test

In Teams, open Copilot and ask:
> "Check if our break-glass accounts are compliant"

Expected output: Structured compliance table with PASS/WARNING/CRITICAL per control.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "I don't have permission to query" | Verify admin consent granted on app registration |
| No accounts found | Confirm break-glass accounts match naming convention (e.g., contain "BreakGlass" or "Emergency") |
| Missing CA policy data | Requires Entra ID P1+ and `Policy.Read.All` |
