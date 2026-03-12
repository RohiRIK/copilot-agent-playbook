<#
.SYNOPSIS
    Identifies Intune-managed devices that haven't checked in within a specified number of days.

.DESCRIPTION
    Queries Microsoft Graph (Intune) for all managed devices and returns those
    with a lastSyncDateTime older than the threshold. Useful for stale device
    cleanup planning and compliance reporting.

.PARAMETER TenantId
    Entra ID tenant ID.

.PARAMETER ClientId
    App registration client ID with DeviceManagementManagedDevices.Read.All.

.PARAMETER ClientSecret
    App registration client secret.

.PARAMETER StaleDays
    Number of days since last sync to consider stale (default: 90).

.PARAMETER ExportPath
    Path for CSV export (default: current directory with timestamp).

.EXAMPLE
    .\Get-StaleDevices.ps1 -TenantId "tid" -ClientId "cid" -ClientSecret "secret" -StaleDays 90

.NOTES
    Permissions: DeviceManagementManagedDevices.Read.All
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TenantId,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [Parameter(Mandatory)]
    [string]$ClientSecret,

    [int]$StaleDays = 90,

    [string]$ExportPath = ".\StaleDevices-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
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
    $response = Invoke-RestMethod -Method Post `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Body $body -ContentType 'application/x-www-form-urlencoded'
    return $response.access_token
}

function Get-AllPages {
    param([string]$Token, [string]$Uri)
    $headers = @{ Authorization = "Bearer $Token" }
    $allItems = [System.Collections.Generic.List[object]]::new()

    do {
        $response = Invoke-RestMethod -Uri $Uri -Headers $headers -Method Get
        $allItems.AddRange($response.value)
        $Uri = $response.'@odata.nextLink'
    } while ($Uri)

    return $allItems
}

try {
    Write-Host "Stale Device Finder" -ForegroundColor Cyan
    Write-Host "Threshold: $StaleDays days" -ForegroundColor Cyan
    Write-Host "====================`n"

    Write-Host "Authenticating..." -NoNewline
    $token = Get-GraphToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
    Write-Host " OK" -ForegroundColor Green

    Write-Host "Fetching all managed devices..." -NoNewline
    $uri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$select=deviceName,userDisplayName,userPrincipalName,operatingSystem,osVersion,lastSyncDateTime,complianceState,managedDeviceOwnerType,serialNumber"
    $allDevices = Get-AllPages -Token $token -Uri $uri
    Write-Host " Found $($allDevices.Count) total devices" -ForegroundColor Green

    $thresholdDate = (Get-Date).AddDays(-$StaleDays)
    $staleDevices = $allDevices | Where-Object {
        [datetime]$_.lastSyncDateTime -lt $thresholdDate
    }

    Write-Host "Stale devices (>$StaleDays days): $($staleDevices.Count)" -ForegroundColor $(if ($staleDevices.Count -gt 0) { 'Yellow' } else { 'Green' })

    if ($staleDevices.Count -eq 0) {
        Write-Host "No stale devices found." -ForegroundColor Green
        exit 0
    }

    $report = $staleDevices | ForEach-Object {
        $daysSince = [int]((Get-Date) - [datetime]$_.lastSyncDateTime).TotalDays
        [PSCustomObject]@{
            DeviceName      = $_.deviceName
            User            = $_.userPrincipalName
            UserDisplayName = $_.userDisplayName
            OS              = "$($_.operatingSystem) $($_.osVersion)"
            LastSync        = ([datetime]$_.lastSyncDateTime).ToString('yyyy-MM-dd')
            DaysSinceSync   = $daysSince
            Compliance      = $_.complianceState
            OwnerType       = $_.managedDeviceOwnerType
            SerialNumber    = $_.serialNumber
        }
    } | Sort-Object DaysSinceSync -Descending

    # Summary by OS
    Write-Host "`n=== SUMMARY BY OS ===" -ForegroundColor Cyan
    $report | Group-Object OS | Sort-Object Count -Descending | Format-Table Name, Count -AutoSize

    # Top 10 stalest
    Write-Host "=== TOP 10 STALEST DEVICES ===" -ForegroundColor Cyan
    $report | Select-Object -First 10 | Format-Table DeviceName, User, OS, LastSync, DaysSinceSync, Compliance -AutoSize

    # Export
    $report | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "Full report exported to: $ExportPath" -ForegroundColor Green
    Write-Host "`nTotal stale devices: $($staleDevices.Count) / $($allDevices.Count) total ($([math]::Round($staleDevices.Count / $allDevices.Count * 100, 1))%)"
}
catch {
    Write-Error "Script failed: $_"
    exit 1
}
