# Least Privilege Builder (PIM) — Deployment Guide

## Overview

Declarative agent that analyzes Entra ID role assignments, identifies permanent privileged access, and generates a PIM migration plan with recommended activation policies per role sensitivity tier.

**Maturity:** Concept → ready to build
**Time to deploy:** ~30 minutes
**License required:** Microsoft 365 Copilot (per-user), Entra ID P2 (for PIM data)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] Entra ID P2 (required for PIM eligibility schedule queries)
- [ ] Global Administrator or Application Administrator to create the app registration
- [ ] Teams admin to publish the agent

---

## Step 1: Create App Registration

1. Go to [Entra ID > App registrations > New registration](https://entra.microsoft.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Name: `CopilotAgent-LeastPrivilegeBuilder`
3. Supported account types: Single tenant
4. Add API permissions (Application, not Delegated):
   - `RoleManagement.Read.All`
   - `PrivilegedAccess.Read.AzureAD`
   - `User.Read.All`
5. Grant admin consent
6. Create a client secret (store in Key Vault, not in this repo)

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `actions` section with your Graph API plugin endpoint
- The plugin should wrap:
  - `GET /roleManagement/directory/roleAssignments`
  - `GET /roleManagement/directory/roleEligibilitySchedules`
  - `GET /roleManagement/directory/roleDefinitions`

---

## Step 3: Package and Upload

```powershell
# Zip the agent package
Compress-Archive -Path manifest.json, instructions.md -DestinationPath least-privilege-builder.zip

# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Restrict Access

In Teams Admin Center > Manage apps > Least Privilege Builder (PIM):
- Set availability to specific users/groups
- Assign only to: Identity Admins, Security Operations

---

## Step 5: Test

In Teams, open Copilot and ask:
> "Analyze our current role assignments and recommend a PIM migration plan"

Expected output: Structured migration plan with Tier A/B/C groupings, permanent vs. eligible assignment counts, and recommended activation policies.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "I don't have permission to query" | Verify admin consent granted for `RoleManagement.Read.All` |
| No PIM eligibility data | Requires Entra ID P2. Without P2, only permanent assignments are visible |
| Break-glass accounts flagged for conversion | The agent should exclude these — verify instructions.md constraints |
