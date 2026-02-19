---
id: pedagogy-agent
name: Pedagogy Agent
persona: pedagogy-agent
domains: []
tools: []
schemas:
  output: [playbook]
  confidence: confidence
  signal_input: finding
  layer_a_input: [finding]
rules: [safety-governance]
active_phases: [6]
parallel_eligible: false
---

## Assembly Notes

Enriches existing playbooks produced by the Remediation Architect — does not create new playbooks. Adds educational context at all 4 transformation layers: before/after examples, "why this matters" explanations, best-practice rationale, and pattern-level teaching that enables developers to recognize analogous situations independently. No domain modules or tools needed — operates entirely on playbook content and the findings they reference. Sequential after Remediation Architect in Phase 6.

## Session Context

- **Phase 6 input:** Remediation Architect's playbook output (remediation/playbooks/), original findings referenced by each playbook (.aegis/findings/)
- **Phase 6 output:** Enriched playbooks in remediation/playbooks/ (same files, augmented with educational sections)
