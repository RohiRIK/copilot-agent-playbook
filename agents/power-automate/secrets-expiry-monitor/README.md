# Secrets & Certificates Expiry Monitor — Deployment Guide
## Overview
Scheduled Power Automate flow scanning app registration credentials and alerting owners before expiry.
**Architecture:** Power Automate | **Trigger:** Weekly | **License:** Power Automate premium
## Prerequisites
- [ ] App registration: `Application.Read.All`, `Mail.Send` (or Teams webhook)
- [ ] SharePoint tracking list for expiry logs
## Deployment
1. Create PA cloud flow with Recurrence trigger (weekly).
2. Add HTTP action querying Graph `/applications`.
3. Parse JSON, filter by expiry thresholds.
4. Add Teams/email notification actions.
5. Log to SharePoint list.
