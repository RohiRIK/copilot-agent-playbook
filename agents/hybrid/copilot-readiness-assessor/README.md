# Copilot Readiness Assessor — Deployment Guide
## Overview
Hybrid agent assessing organizational readiness for M365 Copilot across 5 dimensions.
**Architecture:** Hybrid | **Approval:** No | **License:** M365 Copilot + Azure Functions
## Prerequisites
- [ ] App registration: `Sites.Read.All`, `Reports.Read.All`, `InformationProtectionPolicy.Read`, `User.Read.All`
- [ ] Azure Function for SharePoint content quality scanning
## Deployment
1. Deploy Azure Function (TypeScript/Bun) for content quality analysis.
2. Create PA flows: scheduled readiness scans, progress tracking.
3. Create Copilot Studio bot for conversational queries.
4. Publish — IT leadership + governance team.
