# External Sharing Monitor — Flow Logic
## Purpose
Monitor SharePoint/OneDrive external sharing to prevent data leakage, with real-time alerts for sensitive content and weekly digests for governance.
## Two Flow Modes
### Real-Time Alert (Event-Driven)
Triggered when audit log records a sharing event involving "Confidential" or "Highly Confidential" labeled content → immediate alert to data governance team.
### Weekly Digest (Scheduled)
Every Monday: aggregate all external sharing events, rank by risk (anonymous links > org-wide > specific external user), present digest.
## Risk Scoring
| Share Type | Risk Level |
|-----------|-----------|
| Anonymous/Anyone link | ❌ High |
| Org-wide sharing | ⚠️ Medium |
| Specific external user | ℹ️ Low |
| Sensitivity-labeled content shared externally | ❌ Critical regardless of type |
## Constraints
- Read-only monitoring. Revoking shares is a recommendation for the site admin.
