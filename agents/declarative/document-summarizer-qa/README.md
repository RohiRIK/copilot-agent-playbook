# Document Summarizer & Q&A Agent — Deployment Guide

## Overview

Declarative agent that summarizes SharePoint and OneDrive documents, answers content questions with section citations, compares document versions, and surfaces related documents. Read-only — no document modifications.

**Maturity:** Concept → ready to build
**Time to deploy:** ~20 minutes
**License required:** Microsoft 365 Copilot (per-user)

---

## Prerequisites

- [ ] Microsoft 365 Copilot license
- [ ] Graph API permissions: `Files.Read.All`, `Sites.Read.All`
- [ ] Application Administrator for app registration

---

## Step 1: Create App Registration

1. Name: `CopilotAgent-DocQA`
2. Add delegated permissions: `Files.Read.All`, `Sites.Read.All`
3. Grant admin consent

> No write permissions required. This is a read-only agent.

---

## Step 2: Sensitivity Label Configuration

Configure the agent to check Microsoft Purview sensitivity labels before processing:
- **Public / General / Confidential:** Process normally
- **Highly Confidential:** Acknowledge label and warn user; process only if user confirms they have authorization

---

## Step 3: Package and Upload

```powershell
Compress-Archive -Path manifest.json, instructions.md -DestinationPath document-summarizer-qa.zip
..\..\..\scripts\deployment\Deploy-DeclarativeAgent.ps1 -ManifestPath manifest.json
```

---

## Step 4: Test

In Teams or SharePoint Copilot:
> "Summarize the vendor agreement at [SharePoint URL] in 5 bullet points"

Expected: Structured summary with document type, purpose, key points, and actions.

---

## Troubleshooting

| Issue | Resolution |
|-------|-----------|
| "Cannot access this document" | Verify the user has at least read permission on the SharePoint site |
| Summary incomplete for large files | Large documents (>50 pages) are chunked — ask for specific sections if the summary seems thin |
| "Sensitivity label detected" | User must confirm authorization before the agent processes Highly Confidential documents |
