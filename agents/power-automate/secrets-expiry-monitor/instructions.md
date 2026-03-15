# Secrets & Certificates Expiry Monitor — Flow Logic

## Purpose
Proactively prevent outages caused by expired app registration credentials by alerting owners before expiry.

## Flow Schedule
Weekly scan every Monday at 08:00 UTC.

## Alert Thresholds
| Days to Expiry | Alert Level | Action |
|---------------|------------|--------|
| 30 days | ⚠️ Warning | Email to app owner |
| 14 days | 🔶 Urgent | Email + Teams channel alert |
| 7 days | ❌ Critical | Email + Teams + escalation to IAM lead |
| Expired | 🚨 Expired | All of the above + incident ticket |

## Flow Steps
1. Query `GET /applications?$select=displayName,appId,passwordCredentials,keyCredentials`
2. For each app, check all credentials (secrets + certificates)
3. Calculate days until expiry for each credential
4. If within threshold → resolve app owner from Graph
5. Send notification via Teams Adaptive Card and/or email
6. Log all findings to a SharePoint tracking list

## Notification Content
```
## ⚠️ Credential Expiry Alert
**App:** [name] (AppId: [id])
**Credential type:** Client Secret / Certificate
**Expires:** [date] ([X] days remaining)
**Owner:** [owner UPN]
**Action required:** Rotate credential before expiry to prevent outage.
```

## Constraints
- Read-only scan. Credential rotation is performed by the app owner.
- Always include the Entra portal link for the specific app registration.
