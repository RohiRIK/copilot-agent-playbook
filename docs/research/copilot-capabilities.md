# Microsoft 365 Copilot Capabilities

*Last reviewed: March 2026*

This document summarises what Microsoft 365 Copilot can and cannot do as a platform for custom agent development, with specific focus on enterprise extensibility.

---

## What M365 Copilot Can Do

### Built-in (No Customisation Required)
- Summarise Teams meetings, emails, and documents
- Draft documents, emails, and presentations from prompts
- Answer questions about content in the user's OneDrive and SharePoint (respecting permissions)
- Search across M365 content sources (emails, files, meetings, chats) using Microsoft Search
- Generate insights from Power BI reports the user has access to

### With Declarative Agents (Custom)
- Ground responses in organisation-specific SharePoint sites and document libraries
- Call external APIs via OpenAPI plugins (Graph API, custom REST APIs)
- Surface live data from M365 workloads (Entra, Intune, Defender, Exchange) through Graph plugins
- Provide domain-specific expertise grounded in curated documentation
- Operate with custom persona, tone, and output format

### With Copilot Studio
- Full multi-turn conversation flows with entities and variables
- Custom actions calling Power Automate flows or REST APIs
- Integration with Dataverse for structured data storage
- Approval workflows via the Teams Approval app
- Analytics and conversation history

---

## What M365 Copilot Cannot Do (Current Limitations)

As of March 2026, the following limitations apply. Microsoft continues to evolve the platform — verify current capability at [Microsoft Learn](https://learn.microsoft.com/microsoft-365-copilot).

### Grounding Limitations
- **Cannot ground in arbitrary web content in real-time** — Declarative agents can reference specific URLs as knowledge sources, but real-time web search in custom agents has limited availability.
- **SharePoint grounding has scale limits** — Very large SharePoint sites (millions of documents) may have incomplete indexing; curate the knowledge source to the most relevant content.
- **Cannot ground in on-premises data directly** — Data must be in M365 or surfaced via a custom Graph connector/plugin.

### Security and Access
- **Copilot respects existing permissions** — This is a feature, not a limitation, but it means oversharing in SharePoint results in Copilot exposing content to unauthorised users. Remediate oversharing before Copilot deployment.
- **No cross-tenant access** — Agents cannot access data in other M365 tenants.
- **No elevation of privilege** — An agent with application permissions can access data the user cannot see directly; this must be explicitly designed and governed (see Governance Framework).

### Plugin and Extension Limitations
- **OpenAPI plugin complexity limits** — Very large OpenAPI specs may not be fully processed. Keep plugins focused and well-documented.
- **No streaming responses** — Plugin responses are delivered as a complete payload, not streamed. Very large API responses may time out.
- **Plugin authentication** — Graph API plugins currently support OAuth 2.0 and API key authentication. OAuth flow uses the service principal credentials configured at deployment.

### Copilot Studio Limitations
- **Session limits** — Per-session licensing has message count limits. For high-volume scenarios, per-user licensing is more cost-effective.
- **No persistent memory between sessions** — Each conversation session starts fresh. State must be stored externally (SharePoint list, Dataverse) if persistence is required.
- **Trigger limitations** — Copilot Studio bots are triggered by user messages or explicit flows. Unsolicited proactive messages require Power Automate.

---

## Extensibility Model Summary

```
M365 Copilot Extensibility
├── Declarative Agents
│   ├── Knowledge Sources (SharePoint, Web URLs)
│   └── Plugins (OpenAPI specs → REST APIs → Graph API)
├── Copilot Studio (full bot framework)
│   ├── Topics (conversation flows)
│   ├── Actions (Power Automate / REST API calls)
│   ├── Knowledge Sources (same as declarative)
│   └── Analytics (usage, CSAT, topic coverage)
└── Graph Connectors (index external data into M365 Search)
    └── Makes external data searchable by Copilot alongside native M365 content
```

---

## Grounding Approaches

### SharePoint Knowledge Source
Best for: Documentation, policies, runbooks, FAQs, knowledge bases.
- Content must be in a SharePoint site the deploying user has access to
- Indexing is automatic; updates to documents are reflected within hours
- Best results with well-structured documents (headings, clear sections)

### Graph API Plugin
Best for: Live operational data (user states, device status, incident data).
- Requires an app registration with appropriate permissions
- Must be hosted as an OpenAPI 3.0 spec on an HTTPS endpoint
- Agent invokes the plugin when it determines live data is needed based on the user's query

### Graph Connector (External Data)
Best for: Indexing non-M365 data (ServiceNow, Jira, Confluence, custom databases) into M365 Search so Copilot can surface it.
- Requires custom connector development or use of pre-built connectors in the M365 connector gallery
- More complex than SharePoint or plugin approaches
- Most valuable for organisations with significant non-M365 knowledge stores

---

## Known Limitations Relevant to This Playbook

1. **Sentinel/Defender data via Graph** — The Security Graph API has good coverage of Defender and Sentinel data, but some advanced Sentinel analytics workspaces may not expose all data through the standard API. Test thoroughly in your specific environment.

2. **Intune Graph API completeness** — Most Intune data is available via Graph, but some legacy MDM configurations may not be fully represented. The Intune Graph API v1.0 is preferred over beta for production agents.

3. **Large tenant performance** — In tenants with 50,000+ users or 10,000+ devices, some Graph API queries require careful pagination implementation. The `$top` parameter and `@odata.nextLink` pagination must be handled for complete results.

4. **Authentication methods API** — `UserAuthenticationMethod.Read.All` provides registration state but not real-time MFA challenge results. For challenge-time data, use the Entra sign-in logs.
