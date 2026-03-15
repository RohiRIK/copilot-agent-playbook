# Weekly Status Report Generator — Deployment Guide

## Overview

Declarative agent that synthesizes a professional weekly status report from the user's calendar events, completed Planner/To Do tasks, and recent SharePoint file activity. Draft-first workflow — never posts without user confirmation.

**Maturity:** Concept → ready to build
**Time to deploy:** ~30 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license
- [ ] Graph API permissions: `Calendars.Read`, `Tasks.Read`, `Files.Read.All`, `Sites.ReadWrite.All`, `Mail.Send`
- [ ] Application Administrator to create app registration
- [ ] Teams admin to publish the agent

---

## Step 1: Create App Registration

1. Go to Entra ID > App registrations > New registration
2. Name: `CopilotAgent-StatusReporter`
3. Add delegated permissions: `Calendars.Read`, `Tasks.Read`, `Files.Read.All`, `Sites.ReadWrite.All`, `Mail.Send`
4. Grant admin consent

---

## Step 2: Configure Delivery Settings

Each user configures their delivery preferences in a one-time setup conversation:
- Manager email address
- SharePoint team page URL (optional)
- Preferred report day/time (default: Friday 3pm)

Store settings in a SharePoint list or user profile extension attribute.

---

## Step 3: Package and Upload

```powershell
Compress-Archive -Path manifest.json, instructions.md -DestinationPath weekly-status-report-generator.zip
..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Test

In Teams Copilot:
> "Generate my status report for this week"

Expected: Structured draft with Accomplishments, In Progress, Blockers, Next Week sections.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| No tasks found | Verify `Tasks.Read` permission and that user uses Planner or To Do |
| Calendar events missing | Confirm `Calendars.Read` delegated permission with admin consent |
| Cannot post to SharePoint | Verify `Sites.ReadWrite.All` and the target SharePoint URL is accessible |
