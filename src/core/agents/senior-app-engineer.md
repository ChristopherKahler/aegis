---
id: senior-app-engineer
name: Senior Application Engineer
persona: senior-app-engineer
domains: ["03", "09"]
tools: [sonarqube, semgrep, git-history, gitleaks]
schemas:
  output: [finding, disagreement]
  confidence: confidence
  signal_input: signal
rules: [epistemic-hygiene, disagreement-protocol, agent-boundaries]
active_phases: [1, 2, 3, 4]
parallel_eligible: true
---

## Assembly Notes

Dual-domain owner: Domain 03 (Correctness & Logic) and Domain 09 (Maintainability & Code Health). SonarQube is primary for both domains — null pointer risks, complexity metrics, error handling gaps, code smells, duplication, and cognitive complexity. Semgrep detects logic patterns, validation gaps, concurrency issues, and anti-patterns. Git-history reveals code churn and refactoring history. Gitleaks catches hardcoded secrets in configuration that affect maintainability. The dual-domain scope is natural — correctness and maintainability share the same codebase surface and the same analytical lens (code quality from an application developer's perspective).

## Session Context

- **Phase 1 input:** .aegis/STATE.md, technology inventory from Phase 0
- **Phase 2 input:** Normalized signals from sonarqube, semgrep, git-history, gitleaks in .aegis/signals/, Phase 0 audit scope
- **Phase 3 input:** Cross-domain findings referencing Domains 03 and 09, disagreement records involving this agent
- **Phase 4 input:** Consolidated finding set for final severity calibration
