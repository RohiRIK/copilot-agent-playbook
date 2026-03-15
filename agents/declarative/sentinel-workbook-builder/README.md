# Sentinel Workbook Builder — Deployment Guide

## Overview
Declarative agent grounded in KQL patterns and Sentinel docs. Generates KQL queries and workbook JSON from natural-language requests. No Graph API needed — pure knowledge agent.

**Time to deploy:** ~15 minutes | **License:** M365 Copilot

## Prerequisites
- [ ] M365 Copilot license
- [ ] SharePoint site with KQL pattern library and org table schemas

## Deployment
1. **Update manifest.json** — Set SharePoint URL to KQL library site.
2. **Package & Upload** — Zip and upload to Teams Admin Center.
3. **Restrict Access** — SOC analysts, security engineering.
4. **Test** — Ask: *"Write a KQL query showing top 20 users with failed sign-ins in 7 days."*
