# Power Automate Approval Pattern

Standard pattern used across all Tier 1/2 agents in this playbook that require human approval before taking action.

---

## When to Use This Pattern

Use when an agent needs to:
- Execute a write action (modify a user, policy, device, or group)
- Trigger a cross-system workflow (e.g., offboarding across Entra + Intune + Exchange)
- Take any action flagged as `approval_required: true` in agent frontmatter

---

## Flow Architecture

```
Trigger (scheduled / Teams message / HTTP)
  │
  ▼
Compose action details (who, what, why, risk level)
  │
  ▼
Post Adaptive Card to Teams approval channel
  │
  ├──[Approved]──► Execute action → Log to SharePoint audit list → Notify requester ✅
  │
  └──[Rejected]──► Log rejection reason → Notify requester ❌
```

---

## Adaptive Card Schema (Approval Request)

```json
{
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "TextBlock",
      "text": "⚠️ Approval Required",
      "weight": "Bolder",
      "size": "Large"
    },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Agent", "value": "${agentName}" },
        { "title": "Action", "value": "${actionDescription}" },
        { "title": "Target", "value": "${targetObject}" },
        { "title": "Requested by", "value": "${requester}" },
        { "title": "Risk Level", "value": "${riskLevel}" },
        { "title": "Justification", "value": "${justification}" }
      ]
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "✅ Approve",
      "data": { "decision": "approve" }
    },
    {
      "type": "Action.Submit",
      "title": "❌ Reject",
      "style": "destructive",
      "data": { "decision": "reject" }
    }
  ]
}
```

---

## Power Automate Flow Steps

### 1. Initialize Variables
```
agentName: string
actionDescription: string
targetObject: string
requester: string
riskLevel: Low | Medium | High
justification: string
```

### 2. Post Approval Card
- Action: **Post adaptive card and wait for a response**
- Channel: `#agent-approvals` (dedicated Teams channel)
- Timeout: 24 hours (then auto-reject)

### 3. Condition: Check Response
```
IF response/decision equals "approve"
  THEN → Execute Action branch
  ELSE → Reject branch
```

### 4. Execute Action Branch
1. Run the target action (Graph API call, PowerShell, etc.)
2. Log to SharePoint list: `AgentAuditLog`
   - Columns: Timestamp, Agent, Action, Target, Approver, Status
3. Send Teams notification to requester: "✅ Action completed"

### 5. Reject Branch
1. Log rejection to `AgentAuditLog`
2. Send Teams notification: "❌ Request rejected by [approver]"

---

## Audit List Schema (SharePoint)

| Column | Type | Description |
|--------|------|-------------|
| Timestamp | DateTime | When action was requested |
| AgentName | Text | Which agent triggered this |
| Action | Text | Description of action taken |
| TargetObject | Text | UPN, device ID, policy name |
| Requester | Person | Who asked the agent |
| Approver | Person | Who approved/rejected |
| Decision | Choice | Approved / Rejected / Timeout |
| ExecutionStatus | Choice | Success / Failed / Skipped |
| Notes | MultilineText | Error messages or context |

---

## Timeout Handling

If no response in 24 hours:
- Auto-reject the request
- Log as `Decision: Timeout`
- Notify requester and approver group

---

## Related Agents Using This Pattern

- [Conditional Access Change Companion](../ideas/identity/conditional-access-change-companion.md)
- [Stale Device Cleanup Planner](../ideas/endpoint/stale-device-cleanup-planner.md)
- [Phishing Response Agent](../ideas/secops/phishing-response.md)
- [Offboarding Orchestrator](../ideas/secops/offboarding-orchestrator.md)
