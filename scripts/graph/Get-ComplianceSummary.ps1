<#
.SYNOPSIS
    Generates an Intune device compliance summary grouped by policy and compliance state.

.DESCRIPTION
    Queries Microsoft Graph for all compliance policies and their device status,
    producing a summary suitable for Teams adaptive cards or dashboard reporting.

.PARAMETER TenantId
    Entra ID tenant ID.

.PARAMETER ClientId
    App registration client ID.

.PARAMETER ClientSecret
    App registration client secret.

.EXAMPLE
    .\Get-ComplianceSummary.ps1 -TenantId "tid" -ClientId "cid" -ClientSecret "secret"

.NOTES
    Permissions: DeviceManagementManagedDevices.Read.All, DeviceManagementConfiguration.Read.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$TenantId,
    [Parameter(Mandatory)][string]$ClientId,
    [Parameter(Mandatory)][string]$ClientSecret
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-GraphToken {
    param([string]$TenantId, [string]$ClientId, [string]$ClientSecret)
    $body = @{
        grant_type    = 'client_credentials'
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = 'https://graph.microsoft.com/.default'
    }
    (Invoke-RestMethod -Method Post `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Body $body -ContentType 'application/x-www-form-urlencoded').access_token
}

function Invoke-GraphGet {
    param([string]$Token, [string]$Uri)
    Invoke-RestMethod -Uri $Uri -Headers @{ Authorization = "Bearer $Token" } -Method Get
}

try {
    Write-Host "Intune Compliance Summary" -ForegroundColor Cyan
    Write-Host "=========================`n"

    $token = Get-GraphToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

    # Overall compliance by device
    Write-Host "Fetching device compliance states..."
    $devicesUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$select=deviceName,complianceState,operatingSystem,userPrincipalName"
    $devices = (Invoke-GraphGet -Token $token -Uri $devicesUri).value

    $complianceSummary = $devices | Group-Object complianceState | Sort-Object Count -Descending | ForEach-Object {
        [PSCustomObject]@{
            State      = $_.Name
            Count      = $_.Count
            Percentage = "$([math]::Round($_.Count / $devices.Count * 100, 1))%"
        }
    }

    Write-Host "`n=== OVERALL COMPLIANCE ===" -ForegroundColor Cyan
    $complianceSummary | Format-Table -AutoSize

    # By OS
    $byOS = $devices | Group-Object operatingSystem | ForEach-Object {
        $osGroup = $_.Group
        $compliant = ($osGroup | Where-Object complianceState -eq 'compliant').Count
        [PSCustomObject]@{
            OS            = $_.Name
            Total         = $_.Count
            Compliant     = $compliant
            NonCompliant  = ($osGroup | Where-Object complianceState -eq 'noncompliant').Count
            ComplianceRate = "$([math]::Round($compliant / $_.Count * 100, 1))%"
        }
    } | Sort-Object Total -Descending

    Write-Host "=== BY OPERATING SYSTEM ===" -ForegroundColor Cyan
    $byOS | Format-Table -AutoSize

    # Non-compliant devices
    $nonCompliant = $devices | Where-Object complianceState -eq 'noncompliant' | Select-Object deviceName, userPrincipalName, operatingSystem
    if ($nonCompliant.Count -gt 0) {
        Write-Host "=== NON-COMPLIANT DEVICES ($($nonCompliant.Count)) ===" -ForegroundColor Yellow
        $nonCompliant | Format-Table -AutoSize
    }

    # Export
    $exportPath = ".\ComplianceSummary-$(Get-Date -Format 'yyyyMMdd').csv"
    $devices | Select-Object deviceName, userPrincipalName, operatingSystem, complianceState |
        Export-Csv -Path $exportPath -NoTypeInformation
    Write-Host "Exported to: $exportPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed: $_"
    exit 1
}
