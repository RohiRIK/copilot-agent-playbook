# License Optimizer — Deployment Guide
## Overview
Monthly Power Automate flow analyzing license utilization and generating cost savings recommendations.
**Architecture:** Power Automate | **Trigger:** Monthly | **License:** Power Automate premium
## Deployment
1. App registration: `Reports.Read.All`, `User.Read.All`, `Directory.Read.All`.
2. Create PA flow with monthly Recurrence trigger.
3. Add Graph HTTP actions for SKU and usage reports.
4. Post report to IT Finance Teams channel + email to licensing admin.
