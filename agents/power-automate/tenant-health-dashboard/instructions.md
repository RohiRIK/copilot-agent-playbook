# Tenant Health Dashboard — Flow Logic
## Purpose
Weekly executive health summary: service health, license utilization, security posture, and compliance metrics in one Teams post.
## Metrics Collected
| Category | Metric | Source |
|----------|--------|--------|
| Service Health | Active incidents, degradations | `GET /admin/serviceAnnouncement/issues` |
| Licensing | Utilization rate per SKU | `GET /subscribedSkus` |
| Security | Secure Score, trend | `GET /security/secureScores` |
| Identity | CA policy coverage, MFA adoption | Graph Identity Protection |
| Compliance | Sensitivity label coverage | Purview APIs |
| Endpoint | Device compliance rate | Intune Graph |
## Output: Weekly Adaptive Card
Posted to IT Leadership Teams channel every Monday at 09:00 UTC.
