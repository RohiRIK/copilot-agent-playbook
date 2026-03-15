# SOC Triage Summarizer — Deployment Guide
## Overview
Copilot Studio agent that produces structured incident triage summaries from Sentinel/Defender data.
**Architecture:** Copilot Studio | **Approval:** Yes (for response routing) | **License:** M365 Copilot + Sentinel
## Prerequisites
- [ ] App registration: `SecurityEvents.Read.All`, `SecurityIncident.Read.All`, `IdentityRiskyUser.Read.All`, `DeviceManagementManagedDevices.Read.All`
- [ ] SharePoint MITRE ATT&CK knowledge source
## Deployment
1. Create bot with topics: Triage incident, Entity lookup, MITRE explain.
2. Build PA flows for Security Graph, Entra risk, Intune device queries.
3. Publish — SOC team.
