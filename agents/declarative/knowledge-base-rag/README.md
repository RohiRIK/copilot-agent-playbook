# IT Knowledge Base RAG Agent — Deployment Guide

## Overview

Declarative agent grounded in the organization's IT knowledge base on SharePoint. Enables employees and helpdesk staff to get accurate, sourced answers to IT questions in natural language. The simplest agent in the playbook — no Graph API plugin, no app permissions, just SharePoint knowledge source.

**Maturity:** Concept → ready to build
**Time to deploy:** ~15 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license for deploying users
- [ ] SharePoint IT Knowledge Base site with well-organized, current documentation
- [ ] Teams admin to publish the agent

> **No app registration required** — this agent uses delegated permissions through the user's existing SharePoint access. Users only see content they already have permission to read.

---

## Step 1: Prepare SharePoint Knowledge Base

Before deploying the agent, ensure the knowledge base is ready:
- [ ] Archive outdated or conflicting documents
- [ ] Verify articles have descriptive titles (these appear in citations)
- [ ] Ensure the site URL is correct: `https://yourtenant.sharepoint.com/sites/IT-KnowledgeBase`

---

## Step 2: Configure the Agent

Edit `manifest.json`:
- Update the `OneDriveAndSharePoint` capability URL to point to your organization's IT Knowledge Base SharePoint site
- No `actions` are needed — this agent uses SharePoint as its sole knowledge source

```json
"capabilities": [
  {
    "name": "OneDriveAndSharePoint",
    "items_by_url": [
      {
        "url": "https://yourtenant.sharepoint.com/sites/IT-KnowledgeBase"
      }
    ]
  }
]
```

---

## Step 3: Package and Upload

```powershell
# Zip the agent package
Compress-Archive -Path manifest.json, instructions.md -DestinationPath knowledge-base-rag.zip

# Upload via Teams Admin Center > Manage apps > Upload
# Or use the deployment script:
..\..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Set Access

In Teams Admin Center > Manage apps > IT Knowledge Base:
- Set availability to **all employees** (this agent is designed for broad access)
- No admin permissions required — the agent only surfaces content the user already has access to

---

## Step 5: Test

In Teams, open Copilot and ask:
> "How do I set up MFA on my new phone?"

Expected output: Step-by-step instructions extracted from the knowledge base, with source document link and last modified date.

---

## Step 6: Maintain

Establish a monthly review cadence:
- Review Copilot analytics to see the most-queried topics
- Update or create documentation for the top unanswered queries
- Archive outdated content to prevent stale answers

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| Agent says "I couldn't find..." for documented topics | Verify the SharePoint site URL in manifest.json matches the actual KB site |
| User can't see agent responses | The user needs a Microsoft 365 Copilot license |
| Answers cite wrong documents | Ensure document titles are descriptive and content is well-structured |
| Outdated answers | Archive old documents and update the knowledge base |
