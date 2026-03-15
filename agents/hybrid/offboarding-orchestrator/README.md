# Offboarding Orchestrator — Deployment Guide
## Overview
Hybrid agent for complete employee offboarding with 12-step checklist, approval gates, and audit trail.
**Architecture:** Hybrid | **Approval:** Yes (multi-level) | **Risk:** High (write operations)
## Prerequisites
- [ ] App registration with WRITE permissions: `User.ReadWrite.All`, `Group.ReadWrite.All`, `Mail.ReadWrite`, `DeviceManagementManagedDevices.ReadWrite.All`
- [ ] Azure Function for bulk offboarding compute
- [ ] SharePoint audit list | Power Automate premium
## Deployment
1. Deploy Azure Function for bulk processing.
2. Create PA flows for each offboarding step with approval gates.
3. Create Copilot Studio bot for initiation and status tracking.
4. Create SharePoint audit list with versioning. 5. Publish — HR + IAM + IT ops.
