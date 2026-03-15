# Teams Meeting Notes — Deployment Guide

## Overview
Declarative agent that generates structured meeting notes from Teams transcripts. Available to all Teams users.

**Time to deploy:** ~20 minutes | **License:** M365 Copilot

## Prerequisites
- [ ] M365 Copilot license
- [ ] Teams meeting transcription enabled in Teams admin policies
- [ ] App registration with `CallRecords.Read.All`, `OnlineMeetingTranscript.Read.All`

## Deployment
1. **App Registration** — Name: `CopilotAgent-MeetingNotes`. Grant admin consent.
2. **Configure manifest.json** — Update Graph plugin endpoint.
3. **Package & Upload** → Teams Admin Center.
4. **Access** — All Teams users (no admin data exposed).
5. **Test** — After a recorded meeting, ask: *"Summarize my 2pm meeting today and list the action items."*
