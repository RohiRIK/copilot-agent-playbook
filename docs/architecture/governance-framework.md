# Governance Framework

This document defines the governance model for Copilot agent deployment in enterprise Microsoft 365 environments. All agents in this playbook are classified according to this framework.

---

## The Three-Tier Governance Model

Enterprise Copilot agents are classified into three governance tiers based on their capability to modify data, their blast radius if misconfigured, and the approval requirements for deployment and operation.

### Tier 0: Read-Only Informational Agents

**Definition:** Agents that only read data and return information to the requesting user. No write operations, no approval workflows, no modification of any M365 configuration.

**Characteristics:**
- All operations are read-only
- No data is written to any system other than conversation history
- The user receives only information they already have permission to access (permissions are respected, not elevated)
- Deployed without CISO sign-off required; IT architect approval sufficient

**Examples:** Break-Glass Account Validator, MFA Registration Gap Finder, Knowledge Base RAG, Sentinel Workbook Builder

**Deployment requirements:**
- App registration with read-only permissions only
- Teams Admin Center deployment to appropriate user group
- Quarterly permission review
- No change control board approval required

**Identity guardrails:**
- Service principal created with Certificate-based authentication (not client secret where possible)
- `UserType: ServicePrincipal` in Entra — not a user account
- No assignment to any privileged role
- Permission scope documented in app registration description

---

### Tier 1: Recommendation and Preparation Agents

**Definition:** Agents that prepare recommendations, draft configurations, or orchestrate approval workflows — but do not execute write operations directly. Humans execute all changes after reviewing agent output.

**Characteristics:**
- Agent output may include configuration commands or scripts for human execution
- Approval workflows are present but for routing guidance, not for granting write access to the agent
- The agent cannot modify any M365 resource directly
- Deployed with IT security team review required

**Examples:** Conditional Access Change Companion, Least Privilege Builder (PIM), DLP Policy Tuning Advisor, App Registration Governance

**Deployment requirements:**
- Security review of all permissions requested
- IT security team sign-off on deployment
- Semi-annual permission review
- Change control entry for initial deployment

**Identity guardrails:**
- Service principal with minimum permissions documented
- No `Write` permissions unless the agent uses them only to write to a SharePoint tracking list (not M365 administrative resources)
- Client secret stored in Azure Key Vault — never hardcoded
- Monitoring alert on any unusual activity by the service principal

---

### Tier 2: Write-Capable Agents (Human-in-the-Loop Mandatory)

**Definition:** Agents that can execute write operations against M365 resources — disable accounts, purge emails, wipe devices, modify permissions. Human approval is mandatory for every write operation.

**Characteristics:**
- All write operations gated by an explicit human approval step
- No automated write operations without human confirmation
- Full audit trail of every write operation: who approved, when, justification
- CISO sign-off required for deployment
- Regular security review (quarterly minimum)

**Examples:** Offboarding Orchestrator, Phishing Response Orchestrator, Stale Device Cleanup Planner, Guest Access Policy Enforcer

**Deployment requirements:**
- Full security review by security architect
- CISO sign-off on permissions and approval flow design
- Change control board approval
- Quarterly security review post-deployment
- Penetration test of the agent's authentication and approval mechanisms recommended

**Identity guardrails:**
- Service principal with write permissions must be: (a) excluded from all user-facing Conditional Access policies, (b) assigned the minimum role or permission scope required for each specific write operation, (c) monitored with a Sentinel alert rule that fires on any use outside approved workflow run contexts
- All write permissions explicitly listed and justified in the deployment documentation
- Dual approval required for irreversible operations (device wipe, account deletion)
- Write permissions reviewed and re-consented quarterly

---

## App Registration Governance

All agents require an app registration (service principal) in Entra ID. Governance requirements for agent app registrations:

### Naming Convention
`copilot-<agent-slug>` — e.g., `copilot-break-glass-validator`, `copilot-offboarding`

### Required App Registration Properties
- **Display name:** `[Copilot] <Agent Name>` for easy identification in audit logs
- **Description:** One paragraph explaining the agent's purpose and listing all permissions with justification
- **Owner:** The IAM team member responsible for the agent
- **Notes field:** Link to this playbook's documentation for the agent

### Credential Management
- Client secrets: stored in Azure Key Vault; 90-day rotation enforced
- Certificates preferred over secrets for Tier 1 and Tier 2 agents
- Secret expiry monitored by the Secrets & Certificates Expiry Monitor agent

### Permission Review Cadence
- Tier 0 agents: Annual review
- Tier 1 agents: Semi-annual review
- Tier 2 agents: Quarterly review

---

## DLP Guardrails

Agents that process potentially sensitive data (user PII, security event data, compliance information) must comply with the following:

1. **Data stays in tenant** — All Graph API queries process data within the M365 tenant boundary. No data is sent to external services unless explicitly documented and approved.

2. **Conversation history retention** — Agent conversation history follows the organization's M365 Copilot retention policy. Do not configure exceptions for agent conversations.

3. **Sensitive content in responses** — Agent instructions must include explicit guidance on what sensitive data should not be included verbatim in responses (e.g., full UPNs in shared channels, detailed security event data in public channels).

4. **Prompt injection protection** — Declarative agent instructions should include explicit guidance that the agent should not follow instructions embedded in SharePoint documents or Graph API responses that attempt to override the agent's configured behavior.

---

## Licensing Requirements

| Agent Architecture | Minimum License Required |
|---|---|
| Declarative Agent | Microsoft 365 Copilot (E3/E5 + Copilot add-on) |
| Power Automate flow only | Power Automate per-user or per-flow |
| Copilot Studio bot | Microsoft Copilot Studio (per-session or per-user) |
| Hybrid (Copilot Studio + Power Automate) | Microsoft Copilot Studio + Power Automate |

> **Note:** Licensing models change. Verify current licensing requirements at [Microsoft licensing documentation](https://www.microsoft.com/en-us/microsoft-365/business/compare-all-plans) before deployment.
