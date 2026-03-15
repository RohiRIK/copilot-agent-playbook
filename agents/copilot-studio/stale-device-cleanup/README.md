# Stale Device Cleanup — Deployment Guide
## Overview
Copilot Studio agent for safe stale device identification and batched cleanup with approval.
**Architecture:** Copilot Studio | **Approval:** Yes | **License:** M365 Copilot + Intune + Entra ID P2
## Prerequisites
- [ ] App registration: `DeviceManagementManagedDevices.Read.All`, `User.Read.All`, `AuditLog.Read.All`, `BitlockerKey.Read.All`
## Deployment
1. Create bot with cleanup topics. 2. Build PA enrichment flows (user status, BitLocker).
3. Build approval flow for cleanup batches. 4. Publish — endpoint team + IAM.
