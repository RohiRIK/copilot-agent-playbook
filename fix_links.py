import os
from pathlib import Path

replacements = {
    "azure-app-registration-governance.md": "app-registration-governance.md",
    "break-glass-account-validator.md": "break-glass-validator.md",
    "conditional-access-change-companion.md": "conditional-access-companion.md",
    "copilot-readiness-governance.md": "copilot-readiness-assessor.md",
    "external-sharing-exception-workflow.md": "external-sharing-monitor.md",
    "least-privilege-builder-pim.md": "least-privilege-builder.md",
    "license-optimization.md": "license-optimizer.md",
    "mfa-registration-gap-finder.md": "mfa-gap-finder.md",
    "passwordless-rollout-coach.md": "passwordless-rollout.md",
    "secrets-certificates-expiry.md": "secrets-expiry-monitor.md",
    "stale-device-cleanup-planner.md": "stale-device-cleanup.md",
}

for filepath in Path("ideas").rglob("*.md"):
    content = filepath.read_text()
    original = content
    for old, new in replacements.items():
        content = content.replace(old, new)
    if content != original:
        filepath.write_text(content)
        print(f"Updated {filepath}")
