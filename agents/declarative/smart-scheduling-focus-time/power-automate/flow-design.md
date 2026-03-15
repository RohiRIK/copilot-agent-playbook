# Power Automate Flow Design — Smart Scheduling & Focus Time

## Architecture

```
M365 Copilot (declarative agent)
    │
    │ OpenAPI action call
    ▼
Power Automate HTTP-triggered flow
    │
    │ Graph API (delegated, user context)
    ▼
Microsoft Graph (Calendar API)
    │
    ▼
Response JSON → agent → user
```

---

## Flows to Create (3 total)

### Flow 1: Get Free Slots

**Trigger:** When an HTTP request is received
**Method:** POST
**Input schema:**
```json
{ "date": "2026-03-16", "minDurationMinutes": 90 }
```

**Steps:**
1. **Parse JSON** — extract `date` and `minDurationMinutes`
2. **HTTP (Graph)** — GET `https://graph.microsoft.com/v1.0/me/calendarView`
   - `startDateTime`: `{date}T00:00:00`
   - `endDateTime`: `{date}T23:59:00`
   - `$select`: `start,end,subject,showAs`
   - Auth: OAuth 2.0 with `Calendars.Read` delegated
3. **Select** — filter events where `showAs != free`
4. **Compose** — calculate gaps between busy blocks ≥ minDurationMinutes
5. **Filter** — flag gaps before 11:00 or after 15:00 as `preferred: true`
6. **Response** — return slots array + meetingLoadPercent

**Graph permission:** `Calendars.Read` (delegated)

---

### Flow 2: Create Focus Block

**Trigger:** When an HTTP request is received
**Method:** POST
**Input schema:**
```json
{ "start": "2026-03-16T09:00:00", "end": "2026-03-16T11:00:00", "title": "Focus Time" }
```

**Steps:**
1. **Parse JSON** — extract start, end, title
2. **HTTP (Graph)** — POST `https://graph.microsoft.com/v1.0/me/events`
   ```json
   {
     "subject": "{title}",
     "start": { "dateTime": "{start}", "timeZone": "UTC" },
     "end": { "dateTime": "{end}", "timeZone": "UTC" },
     "showAs": "busy",
     "categories": ["Focus Time"],
     "body": { "content": "Protected focus time — created by Smart Scheduling Agent", "contentType": "text" }
   }
   ```
3. **Response** — return `eventId`, `webLink`, `start`, `end`

**Graph permission:** `Calendars.ReadWrite` (delegated)

---

### Flow 3: Get Meeting Load

**Trigger:** When an HTTP request is received
**Method:** POST
**Input schema:**
```json
{ "weekStart": "2026-03-16" }
```

**Steps:**
1. **Parse JSON** — extract weekStart (default to current Monday if empty)
2. **HTTP (Graph)** — GET calendarView for Mon–Fri (5 calls or single range)
3. **Compose** — sum meeting duration vs working hours (8h/day = 40h/week)
4. **Apply to each** — detect anti-patterns:
   - Back-to-back: events with < 5 min gap
   - No lunch: no 30+ min gap between 12:00–14:00
   - Outside hours: events before 08:00 or after 18:00
   - No-focus day: entire day > 80% booked
5. **Response** — return meetingHours, focusHours, meetingPercent, antiPatterns[]

**Graph permission:** `Calendars.Read` (delegated)

---

## Setup Steps

### 1. Create flows in Power Automate

1. Go to [make.powerautomate.com](https://make.powerautomate.com)
2. New flow → **Instant cloud flow** → trigger: **When an HTTP request is received**
3. Build steps as above for each flow
4. Copy the HTTP POST URL from the trigger step

### 2. Configure authentication

In the HTTP action (Graph calls):
- Authentication: **Active Directory OAuth**
- Tenant: your tenant ID
- Client ID: your app registration client ID
- Client Secret: stored in Azure Key Vault (never hardcoded)
- Audience: `https://graph.microsoft.com`

> **Tip:** Use a connection to the built-in **Office 365 Users** or **Office 365 Outlook** connector instead of raw HTTP if you prefer no-code Graph access.

### 3. Update openapi.json

Replace the server URL placeholders with your actual flow trigger URLs:
```json
"servers": [
  { "url": "https://prod-12.australiasoutheast.logic.azure.com" }
]
```

And update each path to match the actual trigger path from Power Automate.

### 4. Update graph-plugin.json

Point the plugin at `openapi.json`:
```json
{
  "schema_version": "v2",
  "name_for_human": "Smart Scheduling",
  "name_for_model": "smartScheduling",
  "description_for_human": "Access and manage calendar for focus time and scheduling",
  "description_for_model": "Use this to get free calendar slots, create focus blocks, and analyse weekly meeting load.",
  "auth": { "type": "none" },
  "api": {
    "type": "openapi",
    "url": "https://raw.githubusercontent.com/RohiRIK/copilot-agent-playbook/main/agents/declarative/smart-scheduling-focus-time/power-automate/openapi.json"
  }
}
```

### 5. Re-package and reinstall

```bash
cd /tmp/smart-scheduling-focus-time
bunx @microsoft/m365agentstoolkit-cli package --env local
bunx @microsoft/m365agentstoolkit-cli install --file-path appPackage/build/appPackage.local.zip
```

---

## Security Notes

- Flows run in **delegated user context** — agent can only see the signed-in user's calendar
- Never hardcode secrets in flow definitions — use Azure Key Vault references
- HTTP trigger URLs are secret by default (SAS token in URL) — treat as credentials
- Add IP filtering on HTTP trigger if exposing beyond your tenant
