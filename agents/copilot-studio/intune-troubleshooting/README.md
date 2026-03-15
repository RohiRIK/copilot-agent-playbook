# Intune Troubleshooting — Deployment Guide
## Overview
Copilot Studio agent for guided Intune troubleshooting with live device data and internal runbooks.
**Architecture:** Copilot Studio | **Approval:** No | **License:** M365 Copilot + Intune
## Prerequisites
- [ ] App registration: `DeviceManagementManagedDevices.Read.All`, `DeviceManagementApps.Read.All`, `DeviceManagementConfiguration.Read.All`
- [ ] SharePoint site with device management runbooks
## Deployment
1. Create bot with per-category topics. 2. Add PA actions for Graph device queries.
3. Add SharePoint knowledge source. 4. Publish to Teams — helpdesk and endpoint team.
