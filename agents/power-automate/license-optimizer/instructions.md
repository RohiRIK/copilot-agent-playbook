# License Optimizer — Flow Logic
## Purpose
Monthly analysis of M365 license utilization to identify waste and generate cost optimization recommendations.
## Analysis Dimensions
| Dimension | Source | Check |
|-----------|--------|-------|
| SKU utilization | `GET /subscribedSkus` | Assigned vs. available per SKU |
| Inactive users | Usage reports | Licensed users with no activity in 90 days |
| Service plan overlap | License details | Users with redundant SKUs (E5 + standalone) |
| Disabled accounts | User status | Disabled users retaining licenses |
| Department allocation | User attributes | License distribution by department |
## Monthly Report Format
```
## License Optimization Report — [Month Year]
**Total annual spend:** $X | **Potential savings:** $Y

| SKU | Total | Assigned | Active | Inactive | Savings |
|-----|-------|----------|--------|----------|---------|
| M365 E5 | 500 | 480 | 420 | 60 | $X/yr |
```
## Constraints
- Read-only analysis. License reassignment is a recommendation for the licensing admin.
