# Data Classification Assistant — Deployment Guide

## Overview
Dual-persona declarative agent: label coach for end users + coverage analyst for compliance admins.

**Time to deploy:** ~30 minutes | **License:** M365 Copilot + Microsoft Purview

## Prerequisites
- [ ] M365 Copilot license | Microsoft Purview sensitivity labels deployed
- [ ] App registration with `InformationProtectionPolicy.Read`, `Sites.Read.All`
- [ ] SharePoint site with label definitions and classification decision guide

## Deployment
1. **App Registration** — Name: `CopilotAgent-DataClassification`. Grant admin consent.
2. **Update manifest.json** — Set SharePoint URL and Graph plugin endpoint.
3. **Package & Upload** → Teams Admin Center.
4. **Access** — End user persona: all employees. Admin persona: compliance team only.
5. **Test** — Ask: *"Which label should I use for a document with salary data?"*
