# Pull Request

## Type of Change

- [ ] New agent idea (`feat: add <Agent Name> agent`)
- [ ] Improvement to existing agent (`fix: improve <Agent Name> <section>`)
- [ ] Architecture documentation
- [ ] Script or tooling
- [ ] Bug fix or correction

---

## Summary

*Brief description of what this PR adds or changes.*

---

## Agent Checklist (for new agent ideas)

### Frontmatter
- [ ] All required fields present: `title`, `emoji`, `domain`, `tags`, `impact`, `effort`, `risk`, `approval_required`, `data_sources`, `architecture`, `maturity`, `last_updated`
- [ ] Values conform to allowed options (e.g., `impact: low | medium | high`)
- [ ] `last_updated` set to today's date

### Content
- [ ] Problem Statement: specific, grounded in real enterprise pain (2-4 paragraphs)
- [ ] Agent Concept: clear plain-English description of what the agent does
- [ ] Architecture: explains tier choice with Mermaid diagram
- [ ] Implementation Steps: numbered, actionable, specific
- [ ] Required Permissions: least-privilege, each permission justified
- [ ] Security & Compliance Controls: relevant guardrails documented
- [ ] Business Value & Success Metrics: quantifiable metrics table present
- [ ] Example Use Cases: 3+ realistic prompts/scenarios
- [ ] Alternative Approaches: what exists without this agent
- [ ] Related Agents: at least 2 cross-links to related agents

### Quality
- [ ] Minimum 400 words of content (excluding frontmatter)
- [ ] No placeholder text remaining (no "TODO", "TBD", "describe here")
- [ ] Correct relative links to other agent files (tested locally)

### Navigation
- [ ] Agent added to `mkdocs.yml` nav in the correct domain section

---

## Documentation Checklist

- [ ] `mkdocs.yml` updated if new pages were added
- [ ] No broken relative links (run `mkdocs build --strict` locally)

---

## Scripts / Tooling Checklist (if applicable)

- [ ] Script has a `param` block (PowerShell) or type hints (Python)
- [ ] Error handling implemented
- [ ] Tested against a real tenant (or clearly marked as untested)
- [ ] No hardcoded tenant IDs, client IDs, or secrets

---

## Testing

*How did you validate this change?*

- [ ] Deployed the agent in a test tenant
- [ ] Ran `generate-catalog.py --validate-only` locally
- [ ] Ran `mkdocs serve` locally and verified the page renders correctly
- [ ] Peer reviewed by a colleague with M365 expertise

---

## Related Issues

Closes #
