<#
.SYNOPSIS
    Validates and packages a declarative agent manifest for deployment.

.DESCRIPTION
    Validates the manifest.json against the declarative agent schema,
    packages agent files into a .zip ready for upload to Teams Admin Center,
    and optionally validates the instructions file for required sections.

.PARAMETER AgentDir
    Path to the agent directory containing manifest.json and instructions.md.

.PARAMETER OutputDir
    Directory to write the packaged .zip file (default: current directory).

.PARAMETER ValidateOnly
    If specified, only validates without packaging.

.EXAMPLE
    .\Deploy-DeclarativeAgent.ps1 -AgentDir ".\agents\declarative\break-glass-validator"

.EXAMPLE
    .\Deploy-DeclarativeAgent.ps1 -AgentDir ".\agents\declarative\break-glass-validator" -ValidateOnly

.NOTES
    Requires: PowerShell 7+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$AgentDir,

    [string]$OutputDir = '.',

    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$agentDir = Resolve-Path $AgentDir
$manifestPath = Join-Path $agentDir 'manifest.json'
$instructionsPath = Join-Path $agentDir 'instructions.md'

Write-Host "Declarative Agent Packager" -ForegroundColor Cyan
Write-Host "Agent directory: $agentDir`n"

#region Validate manifest.json
Write-Host "Validating manifest.json..." -NoNewline

if (-not (Test-Path $manifestPath)) {
    Write-Host " FAIL" -ForegroundColor Red
    throw "manifest.json not found at $manifestPath"
}

try {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host " FAIL" -ForegroundColor Red
    throw "manifest.json is not valid JSON: $_"
}

$requiredFields = @('name', 'description', 'version')
$missing = $requiredFields | Where-Object { -not $manifest.$_ }
if ($missing) {
    Write-Host " FAIL" -ForegroundColor Red
    throw "manifest.json missing required fields: $($missing -join ', ')"
}

Write-Host " OK" -ForegroundColor Green
Write-Host "  Name: $($manifest.name)"
Write-Host "  Version: $($manifest.version)"
#endregion

#region Validate instructions.md
if (Test-Path $instructionsPath) {
    Write-Host "Validating instructions.md..." -NoNewline
    $instructions = Get-Content $instructionsPath -Raw
    $requiredSections = @('## Role', '## Constraints', '## Output Format')
    $missingSections = $requiredSections | Where-Object { $instructions -notmatch [regex]::Escape($_) }

    if ($missingSections) {
        Write-Host " WARNING" -ForegroundColor Yellow
        Write-Warning "instructions.md missing recommended sections: $($missingSections -join ', ')"
    }
    else {
        Write-Host " OK" -ForegroundColor Green
    }
}
else {
    Write-Warning "instructions.md not found — agent will use inline instructions from manifest."
}
#endregion

if ($ValidateOnly) {
    Write-Host "`nValidation complete (--ValidateOnly specified, skipping package)." -ForegroundColor Green
    exit 0
}

#region Package
$agentName = $manifest.name -replace '[^a-zA-Z0-9-]', '-'
$zipName = "$agentName-$(Get-Date -Format 'yyyyMMdd').zip"
$zipPath = Join-Path (Resolve-Path $OutputDir) $zipName

Write-Host "`nPackaging agent..." -NoNewline

# Collect files to include
$filesToInclude = Get-ChildItem -Path $agentDir -File | Where-Object {
    $_.Extension -in '.json', '.md', '.png', '.jpg', '.svg'
}

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Compress-Archive -Path $filesToInclude.FullName -DestinationPath $zipPath
Write-Host " OK" -ForegroundColor Green
Write-Host "Package: $zipPath"
Write-Host "Files included: $($filesToInclude.Count)"
$filesToInclude | ForEach-Object { Write-Host "  - $($_.Name)" }

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Go to Teams Admin Center > Manage apps > Upload"
Write-Host "2. Upload: $zipPath"
Write-Host "3. Set availability to your target group"
Write-Host "4. Test in Teams: @$($manifest.name)"
#endregion
