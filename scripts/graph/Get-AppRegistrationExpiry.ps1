<#
.SYNOPSIS
    Gets all app registrations and service principals with expiring credentials.

.DESCRIPTION
    Queries Microsoft Graph for all app registrations and service principals,
    retrieves their passwordCredentials and keyCredentials, and reports on
    those expiring within the specified number of days.

.PARAMETER DaysUntilExpiry
    Report credentials expiring within this many days. Default: 30.

.PARAMETER ExportPath
    Optional path to export results as CSV. If not specified, outputs to console.

.PARAMETER IncludeExpired
    Include already-expired credentials in the report.

.EXAMPLE
    .\Get-AppRegistrationExpiry.ps1 -DaysUntilExpiry 30

.EXAMPLE
    .\Get-AppRegistrationExpiry.ps1 -DaysUntilExpiry 14 -ExportPath "C:\Reports\expiry-report.csv"

.NOTES
    Required permissions: Application.Read.All
    Requires: Microsoft.Graph PowerShell module
    Install: Install-Module Microsoft.Graph -Scope CurrentUser
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(1, 365)]
    [int]$DaysUntilExpiry = 30,

    [Parameter()]
    [string]$ExportPath,

    [Parameter()]
    [switch]$IncludeExpired
)

#Requires -Modules Microsoft.Graph.Applications

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ExpiringCredentials {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$DaysThreshold,
        [Parameter(Mandatory)]
        [bool]$IncludeAlreadyExpired
    )

    $now = Get-Date
    $thresholdDate = $now.AddDays($DaysThreshold)
    $results = [System.Collections.Generic.List[PSCustomObject]]::new()

    Write-Verbose "Querying app registrations..."
    $apps = Get-MgApplication -All -Property "id,displayName,appId,passwordCredentials,keyCredentials,owners" |
        Select-Object -Property id, displayName, appId, passwordCredentials, keyCredentials

    Write-Verbose "Found $($apps.Count) app registrations"

    foreach ($app in $apps) {
        # Process password credentials (client secrets)
        foreach ($cred in $app.passwordCredentials) {
            if ($null -eq $cred.endDateTime) { continue }

            $daysLeft = ($cred.endDateTime - $now).Days
            $isExpired = $daysLeft -lt 0

            if ($isExpired -and -not $IncludeAlreadyExpired) { continue }
            if (-not $isExpired -and $daysLeft -gt $DaysThreshold) { continue }

            $results.Add([PSCustomObject]@{
                ObjectType      = "AppRegistration"
                DisplayName     = $app.displayName
                AppId           = $app.appId
                ObjectId        = $app.id
                CredentialType  = "ClientSecret"
                CredentialName  = $cred.displayName ?? "(unnamed)"
                CredentialId    = $cred.keyId
                ExpiryDate      = $cred.endDateTime
                DaysUntilExpiry = $daysLeft
                Status          = if ($isExpired) { "EXPIRED" } elseif ($daysLeft -le 7) { "CRITICAL" } elseif ($daysLeft -le 14) { "WARNING" } else { "NOTICE" }
                PortalLink      = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/$($app.appId)"
            })
        }

        # Process key credentials (certificates)
        foreach ($cert in $app.keyCredentials) {
            if ($null -eq $cert.endDateTime) { continue }

            $daysLeft = ($cert.endDateTime - $now).Days
            $isExpired = $daysLeft -lt 0

            if ($isExpired -and -not $IncludeAlreadyExpired) { continue }
            if (-not $isExpired -and $daysLeft -gt $DaysThreshold) { continue }

            $results.Add([PSCustomObject]@{
                ObjectType      = "AppRegistration"
                DisplayName     = $app.displayName
                AppId           = $app.appId
                ObjectId        = $app.id
                CredentialType  = "Certificate"
                CredentialName  = $cert.displayName ?? $cert.customKeyIdentifier ?? "(unnamed)"
                CredentialId    = $cert.keyId
                ExpiryDate      = $cert.endDateTime
                DaysUntilExpiry = $daysLeft
                Status          = if ($isExpired) { "EXPIRED" } elseif ($daysLeft -le 7) { "CRITICAL" } elseif ($daysLeft -le 14) { "WARNING" } else { "NOTICE" }
                PortalLink      = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/$($app.appId)"
            })
        }
    }

    Write-Verbose "Processing service principals..."
    $sps = Get-MgServicePrincipal -All -Property "id,displayName,appId,passwordCredentials,keyCredentials" |
        Where-Object { $_.passwordCredentials.Count -gt 0 -or $_.keyCredentials.Count -gt 0 }

    foreach ($sp in $sps) {
        foreach ($cred in $sp.passwordCredentials) {
            if ($null -eq $cred.endDateTime) { continue }
            $daysLeft = ($cred.endDateTime - $now).Days
            $isExpired = $daysLeft -lt 0
            if ($isExpired -and -not $IncludeAlreadyExpired) { continue }
            if (-not $isExpired -and $daysLeft -gt $DaysThreshold) { continue }

            $results.Add([PSCustomObject]@{
                ObjectType      = "ServicePrincipal"
                DisplayName     = $sp.displayName
                AppId           = $sp.appId
                ObjectId        = $sp.id
                CredentialType  = "ClientSecret"
                CredentialName  = $cred.displayName ?? "(unnamed)"
                CredentialId    = $cred.keyId
                ExpiryDate      = $cred.endDateTime
                DaysUntilExpiry = $daysLeft
                Status          = if ($isExpired) { "EXPIRED" } elseif ($daysLeft -le 7) { "CRITICAL" } elseif ($daysLeft -le 14) { "WARNING" } else { "NOTICE" }
                PortalLink      = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Credentials/objectId/$($sp.id)"
            })
        }
    }

    return $results | Sort-Object DaysUntilExpiry
}

# Main execution
try {
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes "Application.Read.All" -NoWelcome

    Write-Host "Querying credentials expiring within $DaysUntilExpiry days..." -ForegroundColor Cyan
    $expiringCredentials = Get-ExpiringCredentials -DaysThreshold $DaysUntilExpiry -IncludeAlreadyExpired:$IncludeExpired.IsPresent

    if ($expiringCredentials.Count -eq 0) {
        Write-Host "No credentials expiring within $DaysUntilExpiry days found." -ForegroundColor Green
        return
    }

    Write-Host "`nFound $($expiringCredentials.Count) expiring credential(s):" -ForegroundColor Yellow

    # Display summary table
    $expiringCredentials | Format-Table -AutoSize -Property Status, DisplayName, CredentialType, CredentialName, ExpiryDate, DaysUntilExpiry

    # Summary by status
    $statusGroups = $expiringCredentials | Group-Object Status
    Write-Host "`nSummary:" -ForegroundColor Cyan
    foreach ($group in $statusGroups | Sort-Object Name) {
        $color = switch ($group.Name) {
            "EXPIRED"  { "Red" }
            "CRITICAL" { "Red" }
            "WARNING"  { "Yellow" }
            "NOTICE"   { "White" }
            default    { "White" }
        }
        Write-Host "  $($group.Name): $($group.Count)" -ForegroundColor $color
    }

    # Export if requested
    if ($ExportPath) {
        $expiringCredentials | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        Write-Host "`nExported to: $ExportPath" -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to retrieve credential expiry data: $_"
    exit 1
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}
