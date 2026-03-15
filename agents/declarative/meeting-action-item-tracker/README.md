# Meeting Action Item Tracker — Deployment Guide

## Overview

Declarative agent that reads Teams meeting transcripts after meetings conclude, extracts action items with owners and due dates, creates Planner tasks, and sends 24-hour reminder notifications. All task creation requires organizer review.

**Maturity:** Concept → ready to build
**Time to deploy:** ~30 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license
- [ ] Teams meeting transcription enabled in the tenant
- [ ] Graph API permissions: `OnlineMeetings.Read.All`, `Tasks.ReadWrite`, `TeamMember.Read.All`, `Chat.Read`
- [ ] Application Administrator for app registration

---

## Step 1: Create App Registration

1. Name: `CopilotAgent-ActionTracker`
2. Add delegated permissions: `OnlineMeetings.Read.All`, `Tasks.ReadWrite`, `TeamMember.Read.All`, `Chat.Read`
3. Grant admin consent
4. Ensure meeting transcription is enabled: Teams Admin Center > Meetings > Meeting policies > Allow transcription: On

---

## Step 2: Planner Plan Configuration

Each team using this agent should configure their Planner plan ID in the agent settings. The agent will create tasks in that plan. Store plan IDs in a SharePoint configuration list keyed by Teams channel or M365 Group.

---

## Step 3: Package and Upload

```powershell
Compress-Archive -Path manifest.json, instructions.md -DestinationPath meeting-action-item-tracker.zip
..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Test

After a Teams meeting with transcription enabled, ask:
> "Extract action items from my 2pm standup meeting and create Planner tasks"

Expected: Action item table presented for review, followed by Planner task creation on confirmation.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "Transcript not found" | Verify transcription was enabled for the meeting and it has finished processing (allow 5-10 min post-meeting) |
| Owner not resolved | Ensure attendee names match their Azure AD display names exactly |
| Tasks created in wrong plan | Update the Planner plan ID in the configuration list for that team |
