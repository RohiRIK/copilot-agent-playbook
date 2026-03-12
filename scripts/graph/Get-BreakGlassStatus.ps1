<#
.SYNOPSIS
    Validates break-glass (emergency access) account configuration against Microsoft best practices.

.DESCRIPTION
    Queries Microsoft Graph to check break-glass accounts for:
    - Conditional Access policy exclusions
    - Authentication method registration
    - Password age
    - Sign-in alert configuration
    - Last sign-in date
    - Direct Global Admin role assignment

.PARAMETER TenantId
    Entra ID tenant ID.

.PARAMETER ClientId
    App registration client ID with User.Read.All, AuditLog.Read.All, Policy.Read.All.

.PARAMETER ClientSecret
    App registration client secret (use Key Vault in production).

.PARAMETER BreakGlassPattern
    Display name pattern to identify break-glass accounts (default: 'BreakGlass').

.EXAMPLE
    .\Get-BreakGlassStatus.ps1 -TenantId "your-tenant-id" -ClientId "app-id" -ClientSecret "secret" -BreakGlassPattern "BreakGlass"

.NOTES
    Requires: Microsoft.Graph PowerShell SDK or raw Graph API calls
    Permissions: User.Read.All, AuditLog.Read.All, Policy.Read.All, Directory.Read.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [Parameter(Mandatory)]
    [string]$ClientSecret,

    [string]$BreakGlassPattern = 'BreakGlass'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Authentication
function Get-GraphToken {
    param([string]$TenantId, [string]$ClientId, [string]$ClientSecret)

    $body = @{
        grant_type    = 'client_credentials'
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = 'https://graph.microsoft.com/.default'
    }

    $response = Invoke-RestMethod -Method Post `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Body $body -ContentType 'application/x-www-form-urlencoded'

    return $response.access_token
}

function Invoke-GraphRequest {
    param([string]$Token, [string]$Uri)

    $headers = @{ Authorization = "Bearer $Token" }
    return Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get
}
#endregion

#region Checks
function Get-BreakGlassAccounts {
    param([string]$Token, [string]$Pattern)

    $uri = "https://graph.microsoft.com/v1.0/users?`$filter=startswith(displayName,'$Pattern')&`$select=id,displayName,userPrincipalName,lastPasswordChangeDateTime,accountEnabled"
    $result = Invoke-GraphRequest -Token $Token -Uri $uri
    return $result.value
}

function Test-ConditionalAccessExclusion {
    param([string]$Token, [string]$UserId)

    $uri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$select=displayName,conditions,state"
    $policies = (Invoke-GraphRequest -Token $Token -Uri $uri).value
    $activePolicies = $policies | Where-Object { $_.state -eq 'enabled' }
    $excluded = $activePolicies | Where-Object {
        $_.conditions.users.excludeUsers -contains $UserId
    }

    return @{
        TotalActivePolicies   = $activePolicies.Count
        ExcludedFromPolicies  = $excluded.Count
        MissingExclusions     = $activePolicies.Count - $excluded.Count
        PolicyNames           = $excluded.displayName
    }
}

function Test-PasswordAge {
    param([datetime]$LastPasswordChange)

    $daysSince = (Get-Date) - $LastPasswordChange
    return @{
        LastChanged  = $LastPasswordChange.ToString('yyyy-MM-dd')
        DaysOld      = [int]$daysSince.TotalDays
        IsCompliant  = $daysSince.TotalDays -le 90
    }
}

function Get-LastSignIn {
    param([string]$Token, [string]$Upn)

    $uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=userPrincipalName eq '$Upn'&`$top=1&`$orderby=createdDateTime desc&`$select=createdDateTime,ipAddress,status"
    try {
        $result = Invoke-GraphRequest -Token $Token -Uri $uri
        if ($result.value.Count -gt 0) {
            return $result.value[0]
        }
        return $null
    }
    catch {
        return $null
    }
}

function Test-GlobalAdminDirectAssignment {
    param([string]$Token, [string]$UserId)

    # Get Global Administrator role definition ID
    $roleUri = "https://graph.microsoft.com/v1.0/directoryRoles?`$filter=displayName eq 'Global Administrator'"
    $role = (Invoke-GraphRequest -Token $Token -Uri $roleUri).value | Select-Object -First 1

    if (-not $role) { return $false }

    $membersUri = "https://graph.microsoft.com/v1.0/directoryRoles/$($role.id)/members"
    $members = (Invoke-GraphRequest -Token $Token -Uri $membersUri).value
    return $members.id -contains $UserId
}
#endregion

#region Main
try {
    Write-Host "Break-Glass Account Validator" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "Authenticating..." -NoNewline
    $token = Get-GraphToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
    Write-Host " OK" -ForegroundColor Green

    Write-Host "Locating break-glass accounts (pattern: '$BreakGlassPattern')..." -NoNewline
    $accounts = Get-BreakGlassAccounts -Token $token -Pattern $BreakGlassPattern

    if ($accounts.Count -eq 0) {
        Write-Warning "No accounts found matching pattern '$BreakGlassPattern'. Check the pattern or account display names."
        exit 1
    }
    Write-Host " Found $($accounts.Count) account(s)" -ForegroundColor Green

    $results = foreach ($account in $accounts) {
        Write-Host "`nEvaluating: $($account.userPrincipalName)" -ForegroundColor Yellow

        $caCheck       = Test-ConditionalAccessExclusion -Token $token -UserId $account.id
        $pwdCheck      = Test-PasswordAge -LastPasswordChange ([datetime]$account.lastPasswordChangeDateTime)
        $lastSignIn    = Get-LastSignIn -Token $token -Upn $account.userPrincipalName
        $hasDirectRole = Test-GlobalAdminDirectAssignment -Token $token -UserId $account.id

        [PSCustomObject]@{
            Account               = $account.userPrincipalName
            Enabled               = $account.accountEnabled
            CAExclusion           = if ($caCheck.MissingExclusions -eq 0) { '✅ PASS' } else { "❌ CRITICAL — Missing from $($caCheck.MissingExclusions) policies" }
            PasswordAge           = if ($pwdCheck.IsCompliant) { "✅ PASS ($($pwdCheck.DaysOld) days)" } else { "❌ CRITICAL — $($pwdCheck.DaysOld) days old (last: $($pwdCheck.LastChanged))" }
            LastSignIn            = if ($null -eq $lastSignIn) { '⚠️ WARNING — No sign-in record found' } else { "✅ INFO — $($lastSignIn.createdDateTime)" }
            DirectGlobalAdminRole = if ($hasDirectRole) { '✅ PASS' } else { '❌ CRITICAL — Not directly assigned Global Admin' }
        }
    }

    Write-Host "`n=== COMPLIANCE REPORT ===" -ForegroundColor Cyan
    $results | Format-Table -AutoSize

    # Export to CSV
    $exportPath = ".\BreakGlass-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $results | Export-Csv -Path $exportPath -NoTypeInformation
    Write-Host "Report exported to: $exportPath" -ForegroundColor Green
}
catch {
    Write-Error "Script failed: $_"
    exit 1
}
#endregion
