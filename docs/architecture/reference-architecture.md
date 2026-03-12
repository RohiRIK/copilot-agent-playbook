# Reference Architecture

This document describes the end-to-end reference architecture for Microsoft 365 Copilot agents in an enterprise environment.

---

## High-Level Architecture

```mermaid
flowchart TD
    subgraph Users["User Layer"]
        U1[IT Administrators]
        U2[Security Analysts]
        U3[Helpdesk Staff]
        U4[End Users]
    end

    subgraph Interface["Interface Layer"]
        T[Microsoft Teams]
        W[Teams Web Client]
    end

    subgraph Agents["Agent Layer"]
        DA[Declarative Agents\nTier 1]
        CS[Copilot Studio Bots\nTier 3]
        PA[Power Automate Flows\nTier 2]
        HY[Hybrid Orchestration\nTier 4]
    end

    subgraph Platform["M365 Platform"]
        G[Microsoft Graph API]
        SP[SharePoint Online]
        EX[Exchange Online]
        TE[Microsoft Teams API]
    end

    subgraph Security["Security & Identity"]
        EN[Entra ID]
        DE[Microsoft Defender XDR]
        SE[Microsoft Sentinel]
        PU[Microsoft Purview]
        IN[Microsoft Intune]
    end

    subgraph Auth["Authentication"]
        AP[App Registration\nService Principal]
        KV[Azure Key Vault\nSecrets]
    end

    U1 & U2 & U3 & U4 --> T & W
    T & W --> DA & CS
    PA --> T
    HY --> CS
    HY --> PA

    DA --> G
    CS --> G
    CS --> PA
    PA --> G

    G --> EN & DE & SE & PU & IN & SP & EX & TE

    AP --> G
    KV --> AP
```

---

## Component Descriptions

### User Layer
Users interact with agents exclusively through Microsoft Teams (desktop, web, or mobile). Agents are surfaced as Teams apps — either in the Teams app store (for broadly deployed agents) or via targeted deployment to specific security groups.

### Interface Layer
Microsoft Teams is the single pane of glass for all agent interactions. Teams provides:
- Chat interface for conversational agents
- Adaptive Cards for structured notifications and approvals
- Channel posts for scheduled reports (from Power Automate flows)
- Approval cards via the Teams Approval app

### Agent Layer

**Declarative Agents** are the simplest deployment: a JSON manifest + instructions file + optional OpenAPI plugin spec. They are processed by the M365 Copilot infrastructure and grounded in configured knowledge sources. No custom hosting required.

**Copilot Studio Bots** are hosted by Microsoft in the Power Platform environment. They communicate with external APIs via Power Automate cloud flows used as actions. Published to Teams as a bot app.

**Power Automate Flows** run in the Power Platform cloud. They use the Microsoft 365 connectors and HTTP connectors to call Graph API. Their outputs are Teams notifications (Adaptive Cards), SharePoint records, or email notifications.

**Hybrid Orchestration** combines the above: a Copilot Studio bot as the user-facing interface, Power Automate flows as the automation backend, and SharePoint lists as the state store and audit log.

### Platform Layer
Microsoft Graph is the unified API surface for all M365 data. All agents interact with M365 services through Graph — there is no direct API access to Exchange, Teams, or SharePoint that bypasses Graph (except for some legacy Exchange Online PowerShell operations).

### Security & Identity Layer
The five primary data sources for security and governance agents:
- **Entra ID** — Identity, authentication, Conditional Access, PIM
- **Microsoft Defender XDR** — Endpoint, email, identity, and cloud app security
- **Microsoft Sentinel** — SIEM, SOAR, threat intelligence
- **Microsoft Purview** — DLP, sensitivity labels, compliance, data governance
- **Microsoft Intune** — Endpoint management, device compliance, app management

### Authentication Layer
All agents authenticate to Graph using a service principal (app registration). Client secrets or certificates are stored in Azure Key Vault. The service principal is granted only the minimum permissions required for the agent's specific function.

---

## Data Flow: Declarative Agent

```mermaid
sequenceDiagram
    participant User as User (Teams)
    participant Copilot as M365 Copilot Runtime
    participant Agent as Declarative Agent
    participant Plugin as Graph API Plugin
    participant Graph as Microsoft Graph
    participant Entra as Entra ID

    User->>Copilot: "Check our break-glass accounts"
    Copilot->>Agent: Route to Break-Glass Validator
    Agent->>Plugin: Invoke GetBreakGlassStatus action
    Plugin->>Graph: GET /users?$filter=...
    Graph->>Entra: Query user properties
    Entra-->>Graph: User data
    Graph-->>Plugin: Response
    Plugin-->>Agent: Structured data
    Agent-->>Copilot: Synthesized compliance report
    Copilot-->>User: Formatted response with citations
```

---

## Data Flow: Copilot Studio Agent with Approval

```mermaid
sequenceDiagram
    participant Admin as Admin (Teams)
    participant Bot as Copilot Studio Bot
    participant PA as Power Automate Flow
    participant Graph as Microsoft Graph
    participant Approver as Approver (Teams)

    Admin->>Bot: "Start phishing response for INC-001"
    Bot->>Graph: GET incident details
    Graph-->>Bot: Incident + affected users
    Bot-->>Admin: Impact summary + approval request
    Admin->>Bot: "Approve purge"
    Bot->>PA: Trigger purge flow with incident ID
    PA->>Approver: Send approval card (confirmation)
    Approver->>PA: Approve
    PA->>Graph: POST content search + purge
    Graph-->>PA: Purge confirmation
    PA-->>Bot: Action complete
    Bot-->>Admin: Purge confirmed + audit log entry
```

---

## Security Boundaries

1. **Tenant isolation** — All agents operate within a single M365 tenant. Cross-tenant operations are not supported and not in scope.

2. **Permission boundary** — Each agent's service principal can only access data covered by its explicitly granted permissions. Graph enforces permission boundaries server-side.

3. **User context vs. app context** — Declarative agents operate in the user's context for knowledge sources (SharePoint) — the user sees only what they have permission to see. Graph API plugin calls use the service principal's application context — the agent can read data the user may not individually have access to. This distinction must be understood and documented for each agent.

4. **Network boundary** — All traffic between agents and Microsoft services uses HTTPS with TLS 1.2+. No data leaves the Microsoft network boundary.

5. **Approval boundary** — For Tier 2 agents, the approval is a hard gate in the Power Automate flow. Bypassing the approval requires modifying the flow — which requires Power Platform admin access and generates an audit log entry.
