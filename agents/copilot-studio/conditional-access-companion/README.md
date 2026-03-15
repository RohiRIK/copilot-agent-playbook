# Conditional Access Change Companion — Deployment Guide

## Overview
Copilot Studio agent that validates CA policy changes before execution. Approval required for changes affecting >100 users or privileged roles. The agent never writes — humans execute all changes.

**Architecture:** Copilot Studio (Tier 3) | **Approval:** Yes | **License:** M365 Copilot + Entra ID P1/P2

## Prerequisites
- [ ] Copilot Studio license (included in M365 Copilot)
- [ ] App registration: `Policy.Read.All`, `Group.Read.All`, `User.Read.All`
- [ ] Power Automate premium (for approval flows)

## Deployment
1. **Create Copilot Studio bot** in Power Platform admin center.
2. **Add topics:** CA change assessment, break-glass validation, policy conflict check.
3. **Add Power Automate actions:** Graph API calls for policy read, group size resolution, approval routing.
4. **Publish to Teams** — restrict to IAM admin security group.
5. **Test:** *"What would happen if I added compliant device requirement to All Users?"*
