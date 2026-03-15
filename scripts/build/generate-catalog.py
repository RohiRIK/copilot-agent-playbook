#!/usr/bin/env python3
"""
generate-catalog.py
Reads all ideas/**/*.md files, parses YAML frontmatter, and generates:
  - docs/catalog/index.md  (full sortable table of all agents)
  - docs/catalog/by-domain.md  (agents grouped by domain)

Usage:
    python scripts/build/generate-catalog.py
    python scripts/build/generate-catalog.py --validate-only
"""

import argparse
import sys
from pathlib import Path
from typing import Any

try:
    import frontmatter
except ImportError:
    print("ERROR: python-frontmatter is required. Run: pip install python-frontmatter")
    sys.exit(1)


REQUIRED_FIELDS: list[str] = [
    "title",
    "emoji",
    "domain",
    "tags",
    "impact",
    "effort",
    "risk",
    "approval_required",
    "data_sources",
    "architecture",
    "maturity",
    "last_updated",
]

VALID_VALUES: dict[str, list[str]] = {
    "domain": ["identity", "endpoint", "secops", "compliance", "collaboration", "productivity"],
    "impact": ["low", "medium", "high"],
    "effort": ["low", "medium", "high"],
    "risk": ["low", "medium", "high"],
    "architecture": ["declarative", "copilot-studio", "power-automate", "hybrid"],
    "maturity": ["concept", "pilot", "production"],
}

DOMAIN_ORDER: list[str] = ["identity", "endpoint", "secops", "compliance", "collaboration", "productivity"]

DOMAIN_META: dict[str, dict[str, str]] = {
    "identity": {
        "display": "Identity",
        "icon": "🔐",
        "tagline": "Zero Trust identity posture — MFA, PIM, Conditional Access, and emergency access",
        "persona": "Identity Admins · Security Architects",
    },
    "endpoint": {
        "display": "Endpoint",
        "icon": "💻",
        "tagline": "Intune compliance, device hygiene, and Autopilot readiness at scale",
        "persona": "Endpoint Admins · Helpdesk Teams",
    },
    "secops": {
        "display": "SecOps",
        "icon": "🛡️",
        "tagline": "SOC triage, incident response, offboarding, and alert fatigue reduction",
        "persona": "SOC Analysts · Security Engineers",
    },
    "compliance": {
        "display": "Compliance",
        "icon": "📋",
        "tagline": "DLP, data classification, Purview, and Copilot governance readiness",
        "persona": "Compliance Officers · GRC Teams",
    },
    "collaboration": {
        "display": "Collaboration",
        "icon": "🤝",
        "tagline": "Teams governance, license optimization, and knowledge management",
        "persona": "M365 Admins · IT Operations",
    },
    "productivity": {
        "display": "Productivity",
        "icon": "⚡",
        "tagline": "Email triage, meeting summaries, scheduling, and status reporting",
        "persona": "Knowledge Workers · Business Users",
    },
}

IMPACT_EMOJI: dict[str, str] = {"high": "🔴", "medium": "🟡", "low": "🟢"}
EFFORT_EMOJI: dict[str, str] = {"high": "⬆️", "medium": "➡️", "low": "⬇️"}
RISK_EMOJI: dict[str, str] = {"high": "⚠️", "medium": "🔶", "low": "✅"}

ARCH_DISPLAY: dict[str, str] = {
    "declarative": "Declarative",
    "copilot-studio": "Copilot Studio",
    "power-automate": "Power Automate",
    "hybrid": "Hybrid",
}


def parse_agent_file(path: Path) -> dict[str, Any] | None:
    """Parse a single agent markdown file and return metadata dict or None on error."""
    try:
        post = frontmatter.load(str(path))
    except Exception as e:
        print(f"ERROR: Could not parse {path}: {e}")
        return None

    metadata = dict(post.metadata)
    metadata["_path"] = path
    return metadata


def validate_agent(metadata: dict[str, Any]) -> list[str]:
    """Validate a single agent's frontmatter. Returns list of error strings."""
    errors: list[str] = []
    path = metadata.get("_path", "unknown")

    for field in REQUIRED_FIELDS:
        if field not in metadata:
            errors.append(f"{path}: Missing required field '{field}'")

    for field, valid in VALID_VALUES.items():
        if field in metadata and str(metadata[field]).lower() not in valid:
            errors.append(
                f"{path}: Invalid value '{metadata[field]}' for '{field}'. "
                f"Must be one of: {', '.join(valid)}"
            )

    if "approval_required" in metadata and not isinstance(metadata["approval_required"], bool):
        errors.append(f"{path}: 'approval_required' must be a boolean (true/false)")

    return errors


def agent_link(metadata: dict[str, Any], prefix: str = "../") -> str:
    """Return a markdown link to the agent's idea page."""
    path = metadata["_path"]
    title = metadata.get("title", path.stem)
    emoji = metadata.get("emoji", "")
    label = f"{emoji} {title}" if emoji else title
    return f"[{label}]({prefix}{path})"


def deploy_link(metadata: dict[str, Any]) -> str:
    architecture = metadata.get("architecture", "")
    agent_dir = metadata["_path"].stem
    return f"[Code](../agents/{architecture}/{agent_dir}/README.md)"


def generate_catalog_row(metadata: dict[str, Any]) -> str:
    """Generate a single table row for the catalog."""
    impact = metadata.get("impact", "")
    effort = metadata.get("effort", "")
    risk = metadata.get("risk", "")
    approval = "Yes" if metadata.get("approval_required", False) else "No"
    domain = metadata.get("domain", "")
    architecture = metadata.get("architecture", "")
    arch_display = ARCH_DISPLAY.get(architecture, architecture)

    return (
        f"| {agent_link(metadata)} "
        f"| {domain.title()} "
        f"| {arch_display} "
        f"| {IMPACT_EMOJI.get(impact, '')} {impact.title()} "
        f"| {EFFORT_EMOJI.get(effort, '')} {effort.title()} "
        f"| {RISK_EMOJI.get(risk, '')} {risk.title()} "
        f"| {approval} "
        f"| {deploy_link(metadata)} |"
    )


def generate_index_md(agents: list[dict[str, Any]]) -> str:
    """Generate docs/catalog/index.md content."""

    def sort_key(a: dict[str, Any]) -> tuple[int, str]:
        domain = a.get("domain", "")
        idx = DOMAIN_ORDER.index(domain) if domain in DOMAIN_ORDER else 99
        return (idx, a.get("title", ""))

    sorted_agents = sorted(agents, key=sort_key)

    # Stats
    high_impact = [a for a in agents if a.get("impact") == "high"]
    quick_wins = [a for a in agents if a.get("impact") == "high" and a.get("effort") == "low"]
    declarative_count = sum(1 for a in agents if a.get("architecture") == "declarative")

    # Domain counts
    domain_counts = {d: sum(1 for a in agents if a.get("domain") == d) for d in DOMAIN_ORDER}

    lines: list[str] = [
        "# Agent Catalog",
        "",
        "> Auto-generated — manual edits are overwritten on next build.",
        "",
        "## At a Glance",
        "",
        f"| | |",
        f"|---|---|",
        f"| **Total agents** | {len(agents)} |",
        f"| **High-impact** | {len(high_impact)} |",
        f"| **Quick wins** (High Impact + Low Effort) | {len(quick_wins)} |",
        f"| **No-approval needed** | {sum(1 for a in agents if not a.get('approval_required', False))} |",
        f"| **Declarative** (simplest to deploy) | {declarative_count} |",
        "",
    ]

    # Domain summary row
    lines.extend([
        "| Domain | Agents | Start Here |",
        "|--------|--------|------------|",
    ])
    domain_starters = {
        "identity": "break-glass-validator",
        "endpoint": "device-compliance-drift",
        "secops": "soc-triage-summarizer",
        "compliance": "copilot-readiness-assessor",
        "collaboration": "knowledge-base-rag",
        "productivity": "meeting-action-item-tracker",
    }
    for domain in DOMAIN_ORDER:
        meta = DOMAIN_META[domain]
        count = domain_counts.get(domain, 0)
        starter_slug = domain_starters.get(domain, "")
        # Find starter agent
        starter = next((a for a in agents if a["_path"].stem == starter_slug), None)
        if starter:
            starter_text = agent_link(starter)
        else:
            starter_text = "—"
        lines.append(f"| {meta['icon']} **{meta['display']}** | {count} | {starter_text} |")

    lines.extend(["", "---", ""])

    # Quick Wins section
    lines.extend([
        "## ⚡ Quick Wins",
        "",
        "Deploy these first — **High Impact, Low Effort**, no approval required where possible.",
        "",
        "| Agent | Domain | Architecture | Risk | Approval |",
        "|-------|--------|--------------|------|----------|",
    ])
    for a in sorted(quick_wins, key=lambda x: (x.get("approval_required", False), x.get("title", ""))):
        risk = a.get("risk", "")
        approval = "Yes" if a.get("approval_required", False) else "**No**"
        architecture = a.get("architecture", "")
        domain = a.get("domain", "")
        lines.append(
            f"| {agent_link(a)} "
            f"| {domain.title()} "
            f"| {ARCH_DISPLAY.get(architecture, architecture)} "
            f"| {RISK_EMOJI.get(risk, '')} {risk.title()} "
            f"| {approval} |"
        )

    lines.extend(["", "---", ""])

    # Full catalog table
    lines.extend([
        "## All Agents",
        "",
        "| Agent | Domain | Architecture | Impact | Effort | Risk | Approval | Code |",
        "|-------|--------|--------------|--------|--------|------|----------|------|",
    ])
    for agent in sorted_agents:
        lines.append(generate_catalog_row(agent))

    lines.extend(["", "---", ""])

    # Architecture decision guide
    lines.extend([
        "## Which Architecture Should I Pick?",
        "",
        "| Tier | Architecture | Best For | Complexity | Example |",
        "|------|-------------|----------|------------|---------|",
        "| 1 | **Declarative** | Read-only queries, knowledge agents | Low — no code | Break-Glass Validator |",
        "| 2 | **Power Automate** | Scheduled jobs, notifications, approvals | Medium — flow builder | Secrets Expiry Monitor |",
        "| 3 | **Copilot Studio** | Multi-turn conversations, guided workflows | Medium-High — canvas | SOC Triage Summarizer |",
        "| 4 | **Hybrid** | Complex orchestration, cross-system actions | High — custom code | Offboarding Orchestrator |",
        "",
        "> **Rule of thumb:** Start with Declarative. Only move up a tier when you need write actions or multi-turn flows.",
        "",
    ])

    return "\n".join(lines)


def generate_by_domain_md(agents: list[dict[str, Any]]) -> str:
    """Generate docs/catalog/by-domain.md content."""
    lines: list[str] = [
        "# Agent Catalog — By Domain",
        "",
        "> Auto-generated — manual edits are overwritten on next build.",
        "",
        "Jump to: " + " · ".join(
            f"[{DOMAIN_META[d]['icon']} {DOMAIN_META[d]['display']}](#{d})" for d in DOMAIN_ORDER
        ),
        "",
        "---",
        "",
    ]

    for domain in DOMAIN_ORDER:
        domain_agents = [a for a in agents if a.get("domain") == domain]
        if not domain_agents:
            continue

        meta = DOMAIN_META[domain]
        quick_wins_here = [a for a in domain_agents if a.get("impact") == "high" and a.get("effort") == "low"]

        lines.extend([
            f'<a name="{domain}"></a>',
            f"## {meta['icon']} {meta['display']} ({len(domain_agents)} agents)",
            "",
            f"**{meta['tagline']}**",
            "",
            f"*Audience: {meta['persona']}*",
            "",
        ])

        if quick_wins_here:
            lines.extend([
                "!!! tip \"Quick Wins in this domain\"",
                "",
            ])
            for a in quick_wins_here:
                lines.append(f"    - {agent_link(a)} — High Impact, Low Effort")
            lines.append("")

        lines.extend([
            "| Agent | Architecture | Impact | Effort | Risk | Approval | Code |",
            "|-------|-------------|--------|--------|------|----------|------|",
        ])

        for agent in sorted(domain_agents, key=lambda a: (
            0 if (a.get("impact") == "high" and a.get("effort") == "low") else 1,
            a.get("title", "")
        )):
            impact = agent.get("impact", "")
            effort = agent.get("effort", "")
            risk = agent.get("risk", "")
            approval = "Yes" if agent.get("approval_required", False) else "No"
            architecture = agent.get("architecture", "")

            lines.append(
                f"| {agent_link(agent)} "
                f"| {ARCH_DISPLAY.get(architecture, architecture)} "
                f"| {IMPACT_EMOJI.get(impact, '')} {impact.title()} "
                f"| {EFFORT_EMOJI.get(effort, '')} {effort.title()} "
                f"| {RISK_EMOJI.get(risk, '')} {risk.title()} "
                f"| {approval} "
                f"| {deploy_link(agent)} |"
            )

        lines.extend(["", "---", ""])

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate agent catalog files")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Only validate frontmatter, do not write output files",
    )
    args = parser.parse_args()

    ideas_path = Path("ideas")
    if not ideas_path.exists():
        print("ERROR: 'ideas/' directory not found. Run from the repository root.")
        return 1

    agent_files = [
        p for p in ideas_path.rglob("*.md")
        if p.name != "_template.md"
    ]

    if not agent_files:
        print("WARNING: No agent files found in ideas/")
        return 0

    print(f"Found {len(agent_files)} agent files")

    agents: list[dict[str, Any]] = []
    all_errors: list[str] = []

    for path in sorted(agent_files):
        metadata = parse_agent_file(path)
        if metadata is None:
            all_errors.append(f"{path}: Could not parse file")
            continue

        errors = validate_agent(metadata)
        if errors:
            all_errors.extend(errors)
        else:
            agents.append(metadata)

    if all_errors:
        print("\nVALIDATION ERRORS:")
        for error in all_errors:
            print(f"  {error}")

        if args.validate_only:
            return 1

    print(f"Validated {len(agents)} agents successfully")

    if all_errors and not args.validate_only:
        print(f"WARNING: {len(all_errors)} errors found. Continuing with valid agents only.")

    if args.validate_only:
        if not all_errors:
            print("All agents passed validation.")
        return 0 if not all_errors else 1

    catalog_dir = Path("docs/catalog")
    catalog_dir.mkdir(parents=True, exist_ok=True)

    index_content = generate_index_md(agents)
    (catalog_dir / "index.md").write_text(index_content, encoding="utf-8")
    print(f"Written: {catalog_dir / 'index.md'}")

    by_domain_content = generate_by_domain_md(agents)
    (catalog_dir / "by-domain.md").write_text(by_domain_content, encoding="utf-8")
    print(f"Written: {catalog_dir / 'by-domain.md'}")

    print(f"\nCatalog generated successfully. {len(agents)} agents catalogued.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
