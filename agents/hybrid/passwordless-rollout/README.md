# Passwordless Rollout Planner — Deployment Guide
## Overview
Hybrid agent: Copilot Studio for conversation + Power Automate for orchestration + Azure Function for tenant-wide readiness computation.
**Architecture:** Hybrid | **Approval:** Yes | **License:** M365 Copilot + Azure Functions
## Prerequisites
- [ ] App registration: `UserAuthenticationMethod.Read.All`, `User.Read.All`, `Policy.Read.All`, `Reports.Read.All`
- [ ] Azure Function App for readiness scanning
- [ ] Power Automate premium for orchestration
## Deployment
1. Deploy Azure Function (TypeScript/Bun) for readiness assessment computation.
2. Create PA flows: trigger readiness scan, registration campaign, reminder series.
3. Create Copilot Studio bot for conversational planning interface.
4. Publish — IAM team + IT leadership.
