# External Sharing Monitor — Deployment Guide
## Overview
Power Automate flow for external sharing surveillance with real-time alerts and weekly digests.
**Architecture:** Power Automate | **Trigger:** Daily + event-driven | **License:** Power Automate premium
## Deployment
1. App registration: `Sites.Read.All`, `AuditLog.Read.All`, `InformationProtectionPolicy.Read`.
2. Create two PA flows: (a) Recurrence for weekly digest, (b) Audit log trigger for real-time alerts on sensitive label shares.
3. Teams channel for alerts + email digest to governance team.
