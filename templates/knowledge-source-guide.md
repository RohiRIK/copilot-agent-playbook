# Knowledge Source Configuration Guide

How to configure SharePoint, web connectors, and Graph connectors as knowledge sources for declarative agents in this playbook.

---

## Option 1: SharePoint Knowledge Source

Best for: Internal policies, runbooks, procedures, team wikis.

### Configuration in manifest.json

```json
{
  "capabilities": [
    {
      "name": "OneDriveAndSharePoint",
      "items_by_url": [
        {
          "url": "https://yourtenant.sharepoint.com/sites/ITSecurity/SitePages/BreakGlassRunbook.aspx"
        },
        {
          "url": "https://yourtenant.sharepoint.com/sites/ITSecurity/Shared%20Documents/Policies"
        }
      ]
    }
  ]
}
```

### Tips
- Use specific document URLs for targeted grounding (better accuracy than whole-site)
- Agent can read Word docs, PDFs, and SharePoint pages
- Content must be accessible to the agent's identity (use app permissions or service account)
- Index freshness: SharePoint content is re-indexed approximately every 24 hours

---

## Option 2: Public Web Connector

Best for: Microsoft Learn docs, public compliance standards, vendor documentation.

### Configuration in manifest.json

```json
{
  "capabilities": [
    {
      "name": "WebSearch",
      "enabled": true
    }
  ]
}
```

### Tips
- Web search is scoped to Bing — suitable for publicly available documentation
- Not suitable for internal policies or sensitive data
- Combine with SharePoint for mixed internal/external knowledge

---

## Option 3: Microsoft Graph Connector (Custom Knowledge)

Best for: Structured data from non-Microsoft sources (ServiceNow, Jira, custom databases).

### Overview
Graph connectors index external content into Microsoft Search. Once indexed, declarative agents can query this content as a knowledge source.

### Steps
1. Create a Graph connector in Microsoft 365 Admin Center > Search > Data sources
2. Define the schema (properties, searchable fields)
3. Ingest content via the Graph Connector API
4. Reference in agent via the connection ID

### Configuration
```json
{
  "capabilities": [
    {
      "name": "GraphConnectors",
      "connections": [
        {
          "connection_id": "yourConnectionId"
        }
      ]
    }
  ]
}
```

---

## Option 4: Uploaded Files (Static Knowledge)

Best for: Reference documents you want to embed directly in the agent package.

Upload files alongside `manifest.json`. Reference in instructions:
> "You have access to the attached `compliance-checklist.pdf`. Use it to answer questions about our policy requirements."

Supported file types: `.pdf`, `.docx`, `.txt`, `.md`
Size limit: 512 MB per file, 20 files per agent

---

## Choosing the Right Source

| Use Case | Recommended Source |
|----------|--------------------|
| Internal runbooks and policies | SharePoint |
| Microsoft Learn documentation | Web search or uploaded PDF |
| Live tenant data (users, devices, alerts) | Graph API plugin (action) |
| ServiceNow / Jira tickets | Graph connector |
| Static reference material | Uploaded files |
| Compliance frameworks (CIS, NIST) | Uploaded PDF or SharePoint |
