# Email Triage & Smart Reply Agent — Deployment Guide

## Overview

Declarative agent that reads the user's inbox, classifies emails by type and urgency, drafts context-aware replies, and extracts action items into Microsoft To Do. Draft-only — never sends without explicit user confirmation.

**Maturity:** Concept → ready to build
**Time to deploy:** ~30 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license
- [ ] Graph API permissions: `Mail.ReadWrite`, `Tasks.ReadWrite`, `Calendars.Read`
- [ ] Application Administrator to create app registration

---

## Step 1: Create App Registration

1. Name: `CopilotAgent-EmailTriage`
2. Add delegated permissions: `Mail.ReadWrite`, `Tasks.ReadWrite`, `Calendars.Read`
3. Grant admin consent

---

## Step 2: Configure VIP List

Define the VIP email list as a user-configurable setting stored in their M365 profile or a personal SharePoint list. VIP emails are always surfaced first regardless of classification.

Default VIP detection: emails from domains listed in the org's executive directory or from sender titles containing "VP", "SVP", "Chief", "Director".

---

## Step 3: Package and Upload

```powershell
Compress-Archive -Path manifest.json, instructions.md -DestinationPath email-triage-smart-reply.zip
..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Test

In Outlook Copilot or Teams:
> "Triage my inbox for the last 24 hours"

Expected: Categorized inbox summary with Action Required, Reply Needed, FYI counts.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "Cannot access mailbox" | Verify `Mail.ReadWrite` delegated permission with user consent |
| Draft not appearing in Outlook | Confirm the draft is created in the Drafts folder via Graph |
| To Do tasks not created | Verify `Tasks.ReadWrite` permission and user has To Do enabled |
