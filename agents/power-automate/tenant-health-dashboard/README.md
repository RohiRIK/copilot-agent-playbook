# Tenant Health Dashboard — Deployment Guide
## Overview
Weekly Power Automate flow posting an executive tenant health summary to Teams.
**Architecture:** Power Automate | **Trigger:** Weekly | **License:** Power Automate premium
## Deployment
1. App registration: `ServiceHealth.Read.All`, `Reports.Read.All`, `SecurityEvents.Read.All`.
2. Create PA flow with Recurrence trigger.
3. Add Graph HTTP actions for each metric category.
4. Build Adaptive Card template for Teams post.
5. Target: IT Leadership channel.
