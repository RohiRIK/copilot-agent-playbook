# Internal Comms & Announcement Drafter — Deployment Guide

## Overview

Declarative agent that drafts professional internal communications for Teams, email, and SharePoint News. Supports all-hands announcements, policy updates, change notifications, and newsletters. Draft-first — never publishes without user confirmation.

**Maturity:** Concept → ready to build
**Time to deploy:** ~25 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license
- [ ] Graph API permissions: `Sites.Read.All`, `Sites.ReadWrite.All`, `Mail.Send`, `Files.ReadWrite.All`
- [ ] SharePoint site for past announcement style library (optional but recommended)

---

## Step 1: Create App Registration

1. Name: `CopilotAgent-CommsDrafter`
2. Add delegated permissions: `Sites.Read.All`, `Sites.ReadWrite.All`, `Mail.Send`, `Files.ReadWrite.All`
3. Grant admin consent

---

## Step 2: Index Style Library (Optional)

Upload 10-20 past approved announcements to a SharePoint library called `Comms-StyleLibrary`. Configure the agent's SharePoint knowledge source to index this library for style-matching during drafting.

---

## Step 3: Package and Upload

```powershell
Compress-Archive -Path manifest.json, instructions.md -DestinationPath internal-comms-announcement-drafter.zip
..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Restrict Access

Deploy only to: HR Business Partners, Internal Communications team, Department Managers. Use Teams Admin Center app targeting to restrict by security group.

---

## Step 5: Test

> "Draft a Teams announcement for all staff about the office closure on March 20th. Keep it brief and friendly."

Expected: Draft with subject line variants and formatted body for Teams channel posting.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| Style library not matched | Verify the SharePoint site URL in the agent knowledge configuration |
| Cannot post to SharePoint News | Verify `Sites.ReadWrite.All` permission on the target site |
| Email send fails | Confirm `Mail.Send` delegated permission with user consent |
