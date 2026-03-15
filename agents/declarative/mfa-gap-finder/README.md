# MFA Registration Gap Finder — Deployment Guide

## Overview

Declarative agent that identifies users lacking compliant MFA registration, filtered by department, role, or risk profile. Enables targeted remediation campaigns rather than bulk communications.

**Maturity:** Concept → ready to build
**Time to deploy:** ~30 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] Entra ID P1 or P2
- [ ] Global Administrator or Application Administrator to create the app registration
- [ ] Teams admin to publish the agent

---

## Step 1: Create App Registration

1. Go to [Entra ID > App registrations > New registration](https://entra.microsoft.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Name: `CopilotAgent-MFAGapFinder`
3. Supported account types: Single tenant
4. Add API permissions (Application, not Delegated):
   - `UserAuthenticationMethod.Read.All`
   - `User.Read.All`
   - `Reports.Read.All`
5. Grant admin consent
6. Create a client secret (store in Key Vault, not in this repo)

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `actions` section with your Graph API plugin endpoint
- The plugin should wrap:
  - `GET /reports/authenticationMethods/userRegistrationDetails`
  - `GET /users/{id}/authentication/methods`
  - `GET /users?$select=id,displayName,department,jobTitle,userPrincipalName`

---

## Step 3: Package and Upload

```powershell
# Zip the agent package
Compress-Archive -Path manifest.json, instructions.md -DestinationPath mfa-gap-finder.zip

# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Restrict Access

In Teams Admin Center > Manage apps > MFA Registration Gap Finder:
- Set availability to specific users/groups
- Assign only to: Identity Admins, Security Operations, Helpdesk Managers

---

## Step 5: Test

In Teams, open Copilot and ask:
> "Show me all users in Finance with no MFA registered"

Expected output: Structured MFA gap report with compliance levels (0-4), counts, and remediation links.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "I don't have permission to query" | Verify admin consent granted for `UserAuthenticationMethod.Read.All` |
| No registration data returned | Ensure `Reports.Read.All` is granted and the authentication methods activity report is populated |
| Missing department data | Confirm user profile attributes are populated in Entra ID |
