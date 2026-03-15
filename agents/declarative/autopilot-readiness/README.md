# Autopilot Readiness — Deployment Guide

## Overview
Declarative agent that validates Autopilot pre-flight readiness by serial number, catching deployment blockers before they become on-site failures.

**Time to deploy:** ~45 minutes | **License:** M365 Copilot + Intune

## Prerequisites
- [ ] M365 Copilot license | Microsoft Intune
- [ ] App registration with `DeviceManagementServiceConfig.Read.All`, `DeviceManagementManagedDevices.Read.All`, `DeviceManagementApps.Read.All`

## Deployment
1. **App Registration** — Name: `CopilotAgent-AutopilotReadiness`. Grant admin consent.
2. **Configure manifest.json** — Update Graph plugin endpoint.
3. **Package & Upload** — Zip and upload to Teams Admin Center.
4. **Restrict Access** — Helpdesk, endpoint team, deployment technicians.
5. **Test** — Ask: *"Check if device serial ABC123 is ready for Autopilot deployment."*

## Troubleshooting
| Issue | Resolution |
|-------|-----------|
| Device not found | Hardware hash may not be registered — upload via Intune |
| No profile data | Verify `DeviceManagementServiceConfig.Read.All` permission |
