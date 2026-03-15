# Exchange Mail Flow Diagnostic — Deployment Guide
## Overview
Copilot Studio agent for conversational email delivery troubleshooting with Message Trace and Defender data.
**Architecture:** Copilot Studio | **Approval:** No | **License:** M365 Copilot + Exchange Online
## Prerequisites
- [ ] App registration: `Reports.Read.All`, `Mail.Read`
- [ ] SharePoint with mail flow rules documentation and status code reference
## Deployment
1. Create bot with topics: Diagnose delivery, Check quarantine, Explain rule.
2. Build PA flows: Message Trace API, Defender quarantine lookup.
3. Publish — helpdesk + Exchange admins.
