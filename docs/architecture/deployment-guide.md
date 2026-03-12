# Deployment Guide

This step-by-step guide walks through deploying your first Copilot agent in a Microsoft 365 enterprise environment. We use the Break-Glass Account Validator as the example — the simplest production-ready agent in this playbook.

---

## Prerequisites Checklist

Before beginning, verify the following:

- [ ] Microsoft 365 tenant with Entra ID P1 or P2
- [ ] Microsoft 365 Copilot licenses assigned to the target users
- [ ] Global Administrator or Application Administrator role for app registration setup
- [ ] Teams Administrator role for Teams app deployment
- [ ] Azure subscription with Key Vault (recommended for secret storage)
- [ ] Access to Teams Admin Center
- [ ] PowerShell 7+ with Microsoft.Graph module installed

---

## License Requirements

| Component | Required License |
|---|---|
| Deploying declarative agents | Microsoft 365 Copilot (E3+Copilot or E5+Copilot) |
| Copilot Studio bots | Microsoft Copilot Studio (standalone or M365 Copilot) |
| Power Automate flows | Power Automate per-user plan or Power Platform premium |
| Azure Key Vault | Azure subscription (basic usage is low cost) |

> Use the [Microsoft licensing configurator](https://www.microsoft.com/en-us/microsoft-365/business/compare-all-plans) to verify current requirements.

---

## Step 1: App Registration Setup

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

# Create the app registration
$app = New-MgApplication -DisplayName "[Copilot] Break-Glass Validator" `
    -Description "Read-only agent for break-glass account compliance validation. See: https://github.com/your-org/copilot-agent-playbook/ideas/identity/break-glass-account-validator.md"

# Create the service principal
$sp = New-MgServicePrincipal -AppId $app.AppId

Write-Output "App ID: $($app.AppId)"
Write-Output "Service Principal ID: $($sp.Id)"
```

### Grant Required Permissions

In the Azure portal or via the Entra Admin Center:

1. Navigate to **App registrations** → find `[Copilot] Break-Glass Validator`
2. Click **API permissions** → **Add a permission** → **Microsoft Graph**
3. Select **Application permissions**
4. Add: `User.Read.All`, `AuditLog.Read.All`, `Policy.Read.All`, `UserAuthenticationMethod.Read.All`
5. Click **Grant admin consent** — requires Global Administrator

### Create and Store Client Secret

```powershell
# Create a client secret (90-day expiry)
$secret = Add-MgApplicationPassword -ApplicationId $app.Id `
    -PasswordCredential @{ DisplayName = "copilot-agent-secret"; EndDateTime = (Get-Date).AddDays(90) }

# Store in Azure Key Vault (replace with your Key Vault name)
$vaultName = "your-keyvault-name"
az keyvault secret set --vault-name $vaultName `
    --name "copilot-break-glass-validator-secret" `
    --value $secret.SecretText

Write-Output "Secret stored in Key Vault. Do not log the secret value."
```

---

## Step 2: Build the OpenAPI Plugin

The declarative agent needs an OpenAPI plugin spec that wraps the Graph API queries. Save this as `graph-plugin.json`:

```json
{
  "openapi": "3.0.1",
  "info": {
    "title": "Break-Glass Validator Plugin",
    "description": "Queries Entra ID for break-glass account compliance",
    "version": "1.0"
  },
  "servers": [
    { "url": "https://graph.microsoft.com/v1.0" }
  ],
  "paths": {
    "/users": {
      "get": {
        "operationId": "GetBreakGlassUsers",
        "summary": "Get break-glass user accounts",
        "parameters": [
          {
            "name": "$filter",
            "in": "query",
            "schema": { "type": "string" }
          },
          {
            "name": "$select",
            "in": "query",
            "schema": { "type": "string" }
          }
        ]
      }
    }
  }
}
```

Host this spec on an Azure Static Web App, Azure Functions, or any HTTPS endpoint accessible to the M365 Copilot infrastructure.

---

## Step 3: Create the Declarative Agent Manifest

See the full implementation in `/agents/declarative/break-glass-validator/manifest.json`. The manifest structure:

```json
{
  "schema_version": "v2.1",
  "name_for_human": "Break-Glass Account Validator",
  "name_for_model": "break_glass_validator",
  "description_for_human": "Validates break-glass account configuration against CIS and NIST benchmarks",
  "description_for_model": "...",
  "instructions": "...",
  "capabilities": {
    "localization": {},
    "plugins": ["graph-plugin.json"],
    "knowledge_sources": []
  }
}
```

---

## Step 4: Package and Deploy to Teams

### Create the Teams App Package

A Teams app package is a `.zip` file containing:
- `manifest.json` (Teams app manifest, not the agent manifest)
- `color.png` (192x192 icon)
- `outline.png` (32x32 icon)
- The declarative agent manifest and plugin files

Use the validation script:
```powershell
./scripts/deployment/Deploy-DeclarativeAgent.ps1 -AgentPath ./agents/declarative/break-glass-validator -Validate
```

### Deploy via Teams Admin Center

1. Navigate to Teams Admin Center → **Teams apps** → **Manage apps**
2. Click **Upload new app** → upload the `.zip` package
3. After upload, click **Add** → **Add to specific users** → search for your IAM security group
4. The agent will appear in the targeted users' Teams app catalog

---

## Step 5: Rollout Checklist

Before moving from pilot to production:

- [ ] Pilot with 5-10 users in the IAM team for 2 weeks
- [ ] Validate all Graph API queries return expected results
- [ ] Test edge cases: tenant with no break-glass accounts, accounts with no sign-in history
- [ ] Confirm no sensitive data appears in shared channel responses
- [ ] Verify client secret is stored in Key Vault (not in manifest or code)
- [ ] Set up Azure Monitor alert for unusual service principal activity
- [ ] Document the agent in your organization's app registration inventory
- [ ] Schedule 90-day secret rotation reminder

---

## Step 6: Monitoring and Success Metrics

### Azure Monitor Alerts

Set up an alert for unusual service principal sign-in activity:

```kusto
// Sentinel KQL — alert if service principal used outside expected hours
SigninLogs
| where AppId == "<your-app-id>"
| where TimeGenerated between (datetime(00:00) .. datetime(07:00)) or TimeGenerated > datetime(20:00)
| where ResultType == 0
| summarize count() by bin(TimeGenerated, 1h)
| where count_ > 0
```

### Success Metrics to Track

After 30 days:
- Number of break-glass account queries per week (indicates adoption)
- Any compliance gaps surfaced that were previously unknown
- Time saved vs. manual audit (survey the IAM team)

---

## Troubleshooting Common Issues

| Issue | Likely Cause | Resolution |
|---|---|---|
| Agent returns "I couldn't find that information" | App registration permissions not consented | Re-run admin consent in Entra portal |
| Graph API returns 403 | Missing permission or permission not admin-consented | Verify permissions list and re-consent |
| Agent not appearing in Teams | Deployment targeting misconfigured | Check Teams Admin Center targeted deployment settings |
| Client secret expired | 90-day rotation not performed | Rotate secret in Entra → update Key Vault |
