# Incident Postmortem Generator — Deployment Guide
## Overview
Copilot Studio agent generating structured postmortems from Sentinel data + analyst conversation.
**Architecture:** Copilot Studio | **Approval:** No | **License:** M365 Copilot + Sentinel
## Prerequisites
- [ ] App registration: `SecurityIncident.Read.All`, `Sites.ReadWrite.All`
- [ ] SharePoint postmortem library with metadata columns
## Deployment
1. Create bot with topic: Generate postmortem. 2. Build PA flows: Sentinel incident retrieval, SharePoint draft save.
3. Create SharePoint library. 4. Publish — SOC team.
