# Zero Trust Identity Pack

Deploy three identity agents together to establish a continuous Zero Trust identity posture for your tenant.

## Included Agents

| Agent | Architecture | Purpose |
|-------|-------------|---------|
| [Break-Glass Validator](../../ideas/identity/break-glass-validator.md) | Declarative | Validate emergency access accounts |
| [MFA Registration Gap Finder](../../ideas/identity/mfa-gap-finder.md) | Declarative | Find users without MFA registered |
| [Least Privilege Builder](../../ideas/identity/least-privilege-builder.md) | Declarative | Identify standing privileged role assignments |

## Why These Three Together

Zero Trust identity requires three foundational controls:

1. **Verify explicitly** — MFA Registration Gap Finder ensures all users are registered for strong authentication before Conditional Access can enforce it.
2. **Use least privilege** — Least Privilege Builder identifies standing Global Admin / privileged role assignments that should be converted to PIM just-in-time access.
3. **Assume breach** — Break-Glass Validator ensures your emergency recovery path is always functional and monitored.

Together, these agents provide daily visibility into the three most critical identity hygiene controls.

## Prerequisites

- Microsoft 365 Copilot licenses for Identity Admin users
- Entra ID P2 (for PIM queries)
- App registration with: `User.Read.All`, `AuditLog.Read.All`, `Policy.Read.All`, `RoleManagement.Read.All`, `UserAuthenticationMethod.Read.All`

## Deployment Order

Deploy in this order to build confidence before complexity:

```
Step 1: Break-Glass Validator (15 min — simplest, no PIM required)
Step 2: MFA Registration Gap Finder (20 min)
Step 3: Least Privilege Builder (30 min — requires PIM P2)
```

## Usage After Deployment

Once deployed, your Identity Admins can ask in Teams:

> "Run our weekly identity hygiene check"

The three agents collectively answer:
- Are our break-glass accounts compliant?
- Which users don't have MFA registered?
- Who has standing privileged role assignments that should be PIM-activated?

## Success Metrics

After 30 days with this pack deployed:
- Break-glass compliance: 100%
- MFA registration gap: < 5% of licensed users
- Standing Global Admin assignments: 0 (all via PIM)
