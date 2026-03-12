# SecOps Starter Pack

Deploy three SecOps agents together to accelerate incident response, reduce alert fatigue, and automate postmortem documentation.

## Included Agents

| Agent | Architecture | Purpose |
|-------|-------------|---------|
| [SOC Triage Summarizer](../../ideas/secops/soc-triage-summarizer.md) | Copilot Studio | Summarize Defender/Sentinel incidents for faster triage |
| [Phishing Response Agent](../../ideas/secops/phishing-response.md) | Copilot Studio | Orchestrate phishing investigation and response steps |
| [Incident Postmortem Generator](../../ideas/secops/incident-postmortem-generator.md) | Copilot Studio | Auto-generate structured postmortem reports |

## Why These Three Together

Every security incident follows the same lifecycle:

1. **Detect & Triage** — SOC Triage Summarizer cuts time-to-understand by aggregating incident context from Defender XDR and Sentinel into a 5-line summary.
2. **Respond** — Phishing Response Agent walks analysts through each response step (contain, investigate, notify, remediate) with approval gates for destructive actions.
3. **Learn** — Incident Postmortem Generator turns incident data into a structured blameless postmortem that drives process improvement.

## Prerequisites

- Microsoft 365 Copilot or Copilot Studio (per-session licensing)
- Microsoft Defender XDR Plan 2
- Microsoft Sentinel (Log Analytics Workspace)
- App registration with: `SecurityAlert.Read.All`, `SecurityIncident.Read.All`, `Mail.ReadWrite` (for phishing response)

## Deployment Order

```
Step 1: Incident Postmortem Generator (no write permissions — start here)
Step 2: SOC Triage Summarizer (read-only Defender/Sentinel access)
Step 3: Phishing Response Agent (requires approval workflow setup)
```

## Usage After Deployment

During an active incident, the SOC workflow becomes:

```
Alert fires in Defender →
  Analyst asks: "Summarize incident INC-2024-001" (Triage Summarizer) →
  If phishing: "Walk me through the phishing response for this incident" (Phishing Agent) →
  After resolution: "Generate a postmortem for INC-2024-001" (Postmortem Generator)
```

## Success Metrics

- Mean time to triage: target < 5 minutes (from alert to decision)
- Phishing response steps completed: 100% (no skipped steps)
- Postmortems completed within 48h of incident resolution: > 90%
