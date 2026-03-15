# Smart Scheduling & Focus Time Agent — Deployment Guide

## Overview

Declarative agent that analyzes the user's Microsoft 365 calendar, blocks focus time, and finds optimal meeting slots across team members. Read-write on calendar, no approval required, deploys in Teams in under 45 minutes.

**Maturity:** Concept → ready to build
**Time to deploy:** ~45 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] Graph API permissions: `Calendars.ReadWrite`, `User.Read.All`, `Presence.Read.All`
- [ ] Global Administrator or Application Administrator to create the app registration
- [ ] Teams admin to publish the agent

---

## Step 1: Create App Registration

1. Go to [Entra ID > App registrations > New registration](https://entra.microsoft.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Name: `CopilotAgent-SmartScheduling`
3. Supported account types: Single tenant
4. Add API permissions (Delegated):
   - `Calendars.ReadWrite`
   - `User.Read.All`
   - `Presence.Read.All`
5. Grant admin consent
6. Create a client secret (store in Key Vault)

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `actions` section with your Graph Calendar API plugin endpoint
- Configure the working hours boundary (default: 9am–6pm local time)

---

## Step 3: Package and Upload

```powershell
Compress-Archive -Path manifest.json, instructions.md -DestinationPath smart-scheduling-focus-time.zip
# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Test

In Teams, open Copilot and ask:
> "Block 2 hours of focus time every morning this week"

Expected output: Confirmation of created focus blocks with calendar event links.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "Cannot find available slots" | Verify `Calendars.ReadWrite` delegated permission and admin consent |
| Focus blocks not appearing | Confirm the user's working hours are set in Outlook |
| Attendee calendar not readable | Confirm `User.Read.All` permission and that attendees have not blocked free/busy sharing |
