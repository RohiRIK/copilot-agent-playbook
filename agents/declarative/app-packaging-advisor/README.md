# App Packaging Advisor — Deployment Guide

## Overview
Declarative agent grounded in Win32/MSIX packaging documentation and the org's packaging library. Provides complete packaging specs on first ask.

**Time to deploy:** ~20 minutes | **License:** M365 Copilot

## Prerequisites
- [ ] M365 Copilot license
- [ ] SharePoint site with packaging standards and app library
- [ ] (Optional) App registration with `DeviceManagementApps.Read.All` for duplicate checking

## Deployment
1. **Update manifest.json** — Set SharePoint URL to your packaging library site.
2. **Package & Upload** — Zip manifest.json + instructions.md → Teams Admin Center.
3. **Restrict Access** — Endpoint engineering, desktop support.
4. **Test** — Ask: *"How do I package Adobe Acrobat Reader 2024 as a Win32 app?"*

## Troubleshooting
| Issue | Resolution |
|-------|-----------|
| Agent can't find packaging specs | Ensure SharePoint packaging library site URL is correct in manifest.json |
| Duplicate app check fails | Grant `DeviceManagementApps.Read.All` permission |
