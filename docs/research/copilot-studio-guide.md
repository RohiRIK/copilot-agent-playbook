# Copilot Studio Guide

*Last reviewed: March 2026*

A practical reference for building Copilot Studio agents for the patterns in this playbook.

---

## Core Concepts

### Topics
Topics are the fundamental conversation units in Copilot Studio. Each topic defines a conversation flow: trigger phrases, conversation nodes, variables, and actions. Topics can be system topics (built-in: greeting, escalation, fallback) or custom topics.

**Topic types relevant to this playbook:**
- **Trigger topic** — Starts when a user sends a message matching the trigger phrases. Most agent flows use this type.
- **Redirect topic** — Called by another topic. Useful for reusable sub-flows (e.g., a standard "confirmation required" pattern).

### Variables
Variables store information during a conversation session. They reset at session end unless stored externally.

```
Variable types:
- String: text values
- Number: numeric values
- Boolean: true/false
- Table: structured data from API responses
- Record: named fields from API responses
```

Variables can be set from user input, from HTTP response bodies (when calling Graph API via Power Automate actions), or from conditions in the conversation flow.

### Actions
Actions allow Copilot Studio bots to interact with external systems. Two primary action types:

1. **Power Automate flow action** — Triggers a cloud flow and waits for a response. The flow can call Graph API, send notifications, write to SharePoint, and return structured data back to the bot.

2. **HTTP request action** (preview) — Direct HTTP call to a REST API from within the bot. Useful for simple read operations without needing a dedicated flow.

### Knowledge Sources
Copilot Studio bots can use the same knowledge sources as declarative agents: SharePoint sites, web URLs, and file uploads. When a user's message doesn't match any topic trigger, the bot searches the knowledge sources to generate a grounded response (Generative Answers mode).

---

## Publishing to Microsoft Teams

### Publishing Flow

1. In Copilot Studio, navigate to **Channels** → **Microsoft Teams**
2. Click **Turn on Teams** to enable the Teams channel
3. Configure the bot's Teams app settings (name, description, icons)
4. Click **Submit for review** (or publish directly if Teams admin approval is not required in your tenant)
5. In Teams Admin Center, navigate to **Teams apps** → **Manage apps** → find the bot → **Add to specific users or groups**

### Targeted Deployment
Always use targeted deployment for security-sensitive agents rather than making them available to all users. Configure the target group in Teams Admin Center under the app's **Availability** settings.

### Bot Authentication in Teams
For bots that call Graph API actions:
- Create an Entra app registration for the Copilot Studio bot connection
- Configure OAuth 2.0 authentication in Copilot Studio **Authentication** settings
- Use the "Service principal" authentication mode for application permissions (server-to-server)
- Use "User" authentication mode if the agent should call Graph in the context of the signed-in user (delegated permissions)

---

## Licensing

### Copilot Studio Per-Session
- Charged per 25,000 message sessions per month (one session = one conversation)
- Best for: low-volume, high-complexity bots (approval workflows, governance agents)
- Purchased separately from M365 Copilot

### Copilot Studio Per-User (Classic)
- Charged per named user per month
- Best for: agents used daily by a specific team
- Included in some M365 Copilot bundles — verify current entitlements

### M365 Copilot Included Capacity
- M365 Copilot licenses include limited Copilot Studio capacity for building agents within M365 Copilot experiences
- For Teams bot scenarios with Power Automate actions, additional Copilot Studio licensing is typically needed
- Verify current entitlement at [Microsoft licensing docs](https://learn.microsoft.com/microsoft-copilot-studio/requirements-licensing)

---

## Best Practices for Enterprise Agents

### Conversation Design
- **Always provide an escape hatch** — Every topic should have a path to "I'll connect you with a human" or "I'll create a support ticket." Never design a dead-end conversation.
- **Confirm before acting** — For any action with side effects (sending a notification, creating a ticket, triggering an approval), confirm with the user before executing.
- **Summarise before completing** — At the end of a multi-step flow, summarise what was done. This confirms success and serves as the start of the audit record.

### Topic Design
- Keep topics focused on a single intent. If a topic is growing beyond 15-20 nodes, consider splitting into a trigger topic + redirect topics.
- Use **Condition** nodes rather than complex expressions in message text. Conditions are easier to maintain and test.
- Use **Clarifying question** nodes when the trigger phrases are ambiguous. Better to ask one clarifying question than to provide a wrong answer.

### Error Handling
Every Power Automate action in a Copilot Studio flow should have an error path:
```
Call Graph API action
  → On success: continue flow
  → On failure: "I'm having trouble reaching that system right now. 
                 Here's a link to the manual process: [URL]"
```

### Testing
- Use the **Test your bot** pane extensively during development
- Test with: happy path, empty results (no data returned), API error (simulate by passing invalid parameters), long conversation (test session handling)
- Always test the escalation and fallback paths

---

## Common Patterns for This Playbook

### Pattern: Read-Query-Present
Used by: SOC Triage Summarizer, Entra Risk Explainer, Device Compliance Drift

1. User provides an identifier (incident ID, user UPN, device name)
2. Bot calls a Power Automate flow that queries Graph
3. Flow returns structured data
4. Bot formats and presents data to user
5. User may ask follow-up questions (handled by same or related topic)

### Pattern: Confirm-Execute-Report
Used by: Phishing Response, Stale Device Cleanup

1. User requests an action
2. Bot retrieves relevant data to confirm scope
3. Bot presents scope and requests confirmation
4. User confirms
5. Bot triggers execution flow
6. Bot reports outcome

### Pattern: Guided Questionnaire
Used by: CAB Prep Agent, Onboarding Access Assistant

1. Bot asks structured questions in sequence
2. Answers stored as variables
3. Bot uses answers to generate an output document (RFC, access request)
4. Output presented to user and optionally saved to SharePoint
