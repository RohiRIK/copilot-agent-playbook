# Endpoint Governance Pack

Deploy three endpoint agents together to maintain Intune compliance posture, simplify app deployment, and safely retire stale devices.

## Included Agents

| Agent | Architecture | Purpose |
|-------|-------------|---------|
| [Device Compliance Drift](../../ideas/endpoint/device-compliance-drift.md) | Declarative | Surface devices drifting from compliance policies |
| [Autopilot Readiness](../../ideas/endpoint/autopilot-readiness.md) | Declarative | Validate devices are ready for Autopilot enrollment |
| [Stale Device Cleanup Planner](../../ideas/endpoint/stale-device-cleanup-planner.md) | Copilot Studio | Plan and execute stale device retirement safely |

## Why These Three Together

Endpoint governance has three phases:

1. **Maintain** — Device Compliance Drift gives daily visibility into which devices are out of policy, before users notice or helpdesk tickets flood in.
2. **Onboard** — Autopilot Readiness validates new or reprovisioned devices meet prerequisites before enrollment, reducing failed deployments.
3. **Retire** — Stale Device Cleanup Planner identifies dormant devices and walks through the retirement workflow with appropriate approvals.

## Prerequisites

- Microsoft 365 Copilot licenses for Endpoint Admin users
- Microsoft Intune Plan 1 or 2
- Windows Autopilot (for Autopilot Readiness agent)
- App registration with: `DeviceManagementManagedDevices.Read.All`, `DeviceManagementConfiguration.Read.All`

## Deployment Order

```
Step 1: Device Compliance Drift (read-only, no risk — deploy first)
Step 2: Autopilot Readiness (read-only, no risk)
Step 3: Stale Device Cleanup Planner (requires approval workflow — deploy after team is comfortable)
```

## Usage After Deployment

Monday morning endpoint health check:

> "Give me a compliance drift summary for this week"
> "How many devices are stale (>90 days)?"
> "Which devices are ready for Autopilot re-enrollment?"

Monthly cleanup cycle:

> "Show me a stale device retirement plan for devices inactive > 180 days"
→ Agent generates list → Manager approves → Devices are disabled with 30-day recovery window

## Success Metrics

- Compliance drift detected within 24 hours of policy violation
- Stale devices (>180 days): < 2% of total fleet
- Autopilot enrollment failure rate: < 5%
