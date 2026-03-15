# SharePoint Oversharing Finder — Deployment Guide

## Overview

Declarative agent that identifies SharePoint sites and files shared too broadly — "Everyone" sharing, anonymous links, unrestricted external sharing — and ranks findings by risk. Essential for pre-Copilot deployment oversharing remediation.

**Maturity:** Concept → ready to build
**Time to deploy:** ~45 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] SharePoint Administrator or Global Reader to scope the analysis
- [ ] Global Administrator or Application Administrator to create the app registration
- [ ] Teams admin to publish the agent
- [ ] (Optional) Microsoft Purview sensitivity labels deployed for risk-enriched analysis

---

## Step 1: Create App Registration

1. Go to [Entra ID > App registrations > New registration](https://entra.microsoft.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Name: `CopilotAgent-OverharingFinder`
3. Supported account types: Single tenant
4. Add API permissions (Application, not Delegated):
   - `Sites.Read.All`
   - `Files.Read.All`
   - `InformationProtectionPolicy.Read`
5. Grant admin consent
6. Create a client secret (store in Key Vault, not in this repo)

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `actions` section with your Graph API plugin endpoint
- The plugin should wrap:
  - `GET /sites` (with sharing configuration select)
  - `GET /sites/{siteId}/permissions`
  - `GET /drives/{driveId}/items/{itemId}/permissions`

---

## Step 3: Package and Upload

```powershell
# Zip the agent package
Compress-Archive -Path manifest.json, instructions.md -DestinationPath sharepoint-oversharing-finder.zip

# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Restrict Access

In Teams Admin Center > Manage apps > SharePoint Oversharing Finder:
- Set availability to specific users/groups
- Assign only to: Security Operations, Compliance Admins, SharePoint Admins

---

## Step 5: Test

In Teams, open Copilot and ask:
> "Show me the top 20 SharePoint sites with the broadest sharing configurations"

Expected output: Risk-ranked list of sites with sharing patterns, creation dates, and remediation actions.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "I don't have permission to query" | Verify admin consent granted for `Sites.Read.All` |
| No sharing data returned | `Files.Read.All` is required for file-level sharing link analysis |
| Sensitivity labels not showing | Requires `InformationProtectionPolicy.Read` and Purview sensitivity labels deployed |
| Large tenant — slow responses | Filter by specific sites or departments rather than querying the entire tenant |
