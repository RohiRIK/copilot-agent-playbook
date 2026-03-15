# Device Compliance Drift — Deployment Guide

## Overview

Declarative agent that queries Intune device compliance state on demand, surfaces non-compliant devices by policy, department, or user, and explains what specific compliance checks are failing with remediation guidance.

**Maturity:** Concept → ready to build
**Time to deploy:** ~45 minutes
**License required:** Microsoft 365 Copilot (per-user), Microsoft Intune

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] Microsoft Intune (devices must be enrolled and compliance policies assigned)
- [ ] Global Administrator or Intune Administrator to create the app registration
- [ ] Teams admin to publish the agent

---

## Step 1: Create App Registration

1. Go to [Entra ID > App registrations > New registration](https://entra.microsoft.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Name: `CopilotAgent-DeviceComplianceDrift`
3. Supported account types: Single tenant
4. Add API permissions (Application, not Delegated):
   - `DeviceManagementManagedDevices.Read.All`
   - `DeviceManagementConfiguration.Read.All`
5. Grant admin consent
6. Create a client secret (store in Key Vault, not in this repo)

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `actions` section with your Graph API plugin endpoint
- The plugin should wrap:
  - `GET /deviceManagement/managedDevices`
  - `GET /deviceManagement/deviceCompliancePolicies`
  - `GET /deviceManagement/managedDevices/{id}/deviceCompliancePolicyStates`

---

## Step 3: Package and Upload

```powershell
# Zip the agent package
Compress-Archive -Path manifest.json, instructions.md -DestinationPath device-compliance-drift.zip

# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Restrict Access

In Teams Admin Center > Manage apps > Device Compliance Drift:
- Set availability to specific users/groups
- Assign only to: Endpoint Management team, Helpdesk Tier 2, Security Operations

---

## Step 5: Test

In Teams, open Copilot and ask:
> "How many devices are currently non-compliant and what are the top failure reasons?"

Expected output: Compliance state summary table with counts, top failure reasons ranked by device count, and remediation guidance.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "I don't have permission to query" | Verify admin consent granted for `DeviceManagementManagedDevices.Read.All` |
| No devices returned | Confirm devices are enrolled in Intune and compliance policies are assigned |
| "Not evaluated" for all devices | Compliance policies may not have been deployed yet — check Intune policy assignments |
| Missing department data | User profile attributes must be populated in Entra ID for department-based filtering |
