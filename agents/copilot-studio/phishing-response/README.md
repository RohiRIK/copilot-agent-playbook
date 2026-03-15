# Phishing Response — Deployment Guide
## Overview
Copilot Studio agent for full phishing incident lifecycle with approval-gated write operations.
**Architecture:** Copilot Studio | **Approval:** Yes (dual for account actions) | **Risk:** High
## Prerequisites
- [ ] App registration: `ThreatAssessment.ReadWrite.All`, `Mail.ReadWrite`, `IdentityRiskyUser.ReadWrite.All`, `SecurityEvents.Read.All`
- [ ] eDiscovery/Purge role for Content Search purge operations
- [ ] Power Automate premium for approval flows
## Deployment
1. Create bot with topics: Report phishing, Campaign status, Affected users.
2. Build PA flows: Defender query, Content Search purge, sender block, account remediation.
3. Add dual-approval for account disable/session revocation.
4. Publish — SOC team only.
