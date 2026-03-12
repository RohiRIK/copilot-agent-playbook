# Microsoft Graph API Patterns

*Last reviewed: March 2026*

Practical Graph API patterns for building agents in this playbook. Covers authentication, common query patterns, pagination, throttling, and batching.

---

## Authentication Patterns

### Application Permissions (Server-to-Server)
Used by all agent service principals in this playbook. The service principal authenticates with its own credentials, not a user's credentials.

```powershell
# PowerShell - acquire token for Microsoft Graph
$tenantId = "your-tenant-id"
$clientId = "your-app-id"
$clientSecret = (Get-AzKeyVaultSecret -VaultName "your-vault" -Name "secret-name").SecretValue | ConvertFrom-SecureString -AsPlainText

$body = @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://graph.microsoft.com/.default"
}

$response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"

$accessToken = $response.access_token
```

### Delegated Permissions (User Context)
Some agents should act in the context of the signed-in user. For Teams-embedded agents, the user's token can be passed to the backend via the On-Behalf-Of flow. For SharePoint knowledge source access in declarative agents, this happens automatically.

---

## Common Query Patterns

### Identity and Entra

```powershell
# Get all users with specific properties
GET /users?$select=id,displayName,userPrincipalName,accountEnabled,signInActivity&$top=999

# Get break-glass accounts (by group membership)
GET /groups/{breakGlassGroupId}/members?$select=id,displayName,userPrincipalName

# Get user authentication methods
GET /users/{userId}/authentication/methods

# Get user's MFA registration details
GET /reports/authenticationMethods/userRegistrationDetails/{userId}

# Get risky users
GET /identityProtection/riskyUsers?$filter=riskState eq 'atRisk'&$select=id,userPrincipalName,riskLevel,riskState

# Get risk detections for a user
GET /identityProtection/riskDetections?$filter=userId eq '{userId}'&$orderby=detectedDateTime desc
```

### Conditional Access

```powershell
# Get all CA policies
GET /identity/conditionalAccessPolicies?$select=id,displayName,state,conditions,grantControls

# Get a specific policy
GET /identity/conditionalAccessPolicies/{policyId}
```

### Privileged Identity Management

```powershell
# Get all role assignments (permanent)
GET /roleManagement/directory/roleAssignments?$expand=principal,roleDefinition

# Get PIM eligible assignments
GET /roleManagement/directory/roleEligibilitySchedules?$expand=principal,roleDefinition

# Get role definitions
GET /roleManagement/directory/roleDefinitions
```

### Intune / Endpoint

```powershell
# Get all managed devices
GET /deviceManagement/managedDevices?$select=id,deviceName,complianceState,lastSyncDateTime,userPrincipalName,operatingSystem&$top=999

# Get device compliance policy states for a device
GET /deviceManagement/managedDevices/{deviceId}/deviceCompliancePolicyStates

# Get Autopilot devices
GET /deviceManagement/windowsAutopilotDeviceIdentities

# Get app installation status
GET /deviceManagement/managedDevices/{deviceId}/deviceActionResults
```

### Security / Defender / Sentinel

```powershell
# Get security incidents
GET /security/incidents?$orderby=createdDateTime desc&$top=50

# Get specific incident
GET /security/incidents/{incidentId}?$expand=alerts

# Get risky sign-ins
GET /auditLogs/signIns?$filter=riskLevelDuringSignIn eq 'high'&$top=100

# Get alert evidence
GET /security/alerts_v2/{alertId}
```

### SharePoint and Content

```powershell
# Get all sites
GET /sites?search=*&$select=id,displayName,webUrl

# Get site permissions
GET /sites/{siteId}/permissions

# Get sharing links
GET /drives/{driveId}/items/{itemId}/permissions

# Get sensitivity label for a file
GET /drives/{driveId}/items/{itemId}?$select=id,sensitivityLabel
```

---

## Pagination

Graph API limits responses to `$top` records (maximum varies by endpoint, typically 100-1000). Always implement pagination for queries that may return more than the maximum.

```powershell
function Get-AllGraphResults {
    param(
        [string]$Uri,
        [string]$AccessToken
    )
    
    $results = @()
    $nextLink = $Uri
    
    do {
        $response = Invoke-RestMethod -Uri $nextLink `
            -Headers @{ Authorization = "Bearer $AccessToken" } `
            -Method GET
        
        $results += $response.value
        $nextLink = $response.'@odata.nextLink'
        
    } while ($nextLink)
    
    return $results
}
```

---

## Throttling

Graph API enforces throttling limits. Key limits:
- **Per app per tenant**: 10,000 requests per 10 minutes
- **Per service per tenant**: Varies by service (Intune is more restrictive than Entra)

Handle throttling with exponential backoff:

```powershell
function Invoke-GraphWithRetry {
    param(
        [string]$Uri,
        [string]$AccessToken,
        [int]$MaxRetries = 3
    )
    
    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            $response = Invoke-RestMethod -Uri $Uri `
                -Headers @{ Authorization = "Bearer $AccessToken" } `
                -Method GET
            return $response
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 429) {
                $retryAfter = $_.Exception.Response.Headers['Retry-After']
                $waitSeconds = if ($retryAfter) { [int]$retryAfter } else { [math]::Pow(2, $i) * 5 }
                Start-Sleep -Seconds $waitSeconds
            } else {
                throw
            }
        }
    }
}
```

---

## Batch Requests

For agents that need to query multiple endpoints, use Graph batch requests to reduce latency and request count:

```json
POST https://graph.microsoft.com/v1.0/$batch
Content-Type: application/json

{
  "requests": [
    {
      "id": "1",
      "method": "GET",
      "url": "/users/{userId}/authentication/methods"
    },
    {
      "id": "2",
      "method": "GET",
      "url": "/identityProtection/riskyUsers/{userId}"
    },
    {
      "id": "3",
      "method": "GET",
      "url": "/auditLogs/signIns?$filter=userId eq '{userId}'&$top=5"
    }
  ]
}
```

Maximum 20 requests per batch. Responses may arrive out of order; use the `id` field to correlate.

---

## Graph Connectors for Custom Knowledge

For indexing non-M365 data sources into M365 Search (so Copilot can surface them):

```
External System (ServiceNow, Jira, etc.)
    → Custom Graph Connector
        → Microsoft Search Index
            → M365 Copilot Knowledge Source
```

Graph Connectors require:
- A registered connection in the Microsoft 365 Admin Center
- A schema definition for the external content type
- A crawler/sync mechanism to push content updates to the index

Pre-built connectors are available for common systems including ServiceNow, Jira, Confluence, and Salesforce in the Microsoft connector gallery. Custom connectors use the `externalConnections` Graph API.

---

## Useful Graph Explorer Queries for This Playbook

Test these at [graph.microsoft.com/graph-explorer](https://developer.microsoft.com/graph/graph-explorer):

```
GET https://graph.microsoft.com/v1.0/reports/authenticationMethods/userRegistrationDetails
GET https://graph.microsoft.com/v1.0/identity/conditionalAccessPolicies
GET https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$top=5
GET https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/healthOverviews
GET https://graph.microsoft.com/v1.0/identityProtection/riskyUsers
```
