---
id: domain-13
number: "13"
name: Risk Synthesis & Forecasting
owner_agents: [principal-engineer]
---

## Overview

Risk Synthesis & Forecasting aggregates findings across all prior domains to identify compound risks, forecast time-to-failure scenarios, and prioritize remediation efforts based on likelihood-times-impact analysis. This is a SYNTHESIS domain—it consumes findings from domains 00-12 rather than generating primary findings. Its failure patterns describe breakdowns in the synthesis process itself (treating risks in isolation, missing cross-domain interactions, short-term bias), not defects in the codebase. Effective risk synthesis answers "what breaks first" and "what requires immediate action" by understanding how risks interact and evolve. This domain does NOT cover individual domain analysis (architecture, security, performance, team risk, etc.).

## Audit Questions

- How are risks from different domains weighted and combined into a unified risk score?
- Which cross-domain risk combinations create compound scenarios (e.g., security vulnerability + high coupling + single author)?
- What is the predicted time-to-failure for critical systems based on trend analysis across quality, security, and ownership metrics?
- Are risks assessed in isolation, or is there analysis of cascading failure modes and interaction effects?
- What criteria determine whether a risk is accepted vs remediated, and are these criteria documented and consistently applied?
- How is remediation sequenced—by severity, by time-to-failure, by dependency order, or by business priority?
- Does risk assessment consider multiple time horizons (immediate, 3-month, 12-month), or focus only on current state?
- Are there documented risk acceptance decisions with expiration dates and reassessment triggers?
- How often are risk profiles updated, and what triggers reevaluation (new findings, production incidents, architecture changes)?
- Are historical risk trends tracked to identify worsening patterns or validate remediation effectiveness?
- What percentage of identified risks have defined remediation plans vs sit unaddressed?
- How is risk communicated to stakeholders—raw scores, narrative summaries, or visual dashboards?

## Failure Patterns

### Risk Compartmentalization
- **Description:** Treating risks from different domains as independent factors, missing critical interactions where vulnerabilities in one domain amplify or trigger failures in another, leading to blind spots in compound risk scenarios.
- **Indicators:**
  - Risk reports organized by domain with no cross-domain correlation analysis
  - Security findings addressed independently of code ownership patterns (ignoring abandoned code with known CVEs)
  - Performance degradation trends not correlated with coupling metrics (missing cascading slowdown risks)
  - Remediation priorities set per-domain without considering interaction effects
- **Severity Tendency:** high

### Missing Compound Risk Analysis
- **Description:** Failure to identify scenarios where multiple moderate risks combine into critical failure modes, such as a security vulnerability in single-author legacy code with high coupling and no test coverage.
- **Indicators:**
  - No documented compound risk scenarios or cascading failure mode analysis
  - Risk scoring treats each finding as independent, ignoring multiplicative effects
  - Production incidents reveal risk combinations that were individually triaged as low-priority
  - Remediation planning focuses on highest individual scores without dependency or interaction consideration
- **Severity Tendency:** critical

### Short-Term Bias
- **Description:** Risk assessment focuses exclusively on current state without trend analysis or forecasting, missing accelerating decay patterns that will cause future failures even if current metrics appear acceptable.
- **Indicators:**
  - Risk dashboards show only current snapshots with no historical trend lines
  - No time-to-failure predictions or degradation rate calculations
  - Technical debt treated as static rather than accruing with interest
  - No differentiation between stable risks and rapidly worsening risks in remediation priority
- **Severity Tendency:** high

### Risk Normalization
- **Description:** Persistent exposure to risks leads to acceptance-as-default rather than deliberate risk acceptance decisions, causing critical risks to become invisible through familiarity rather than judgment.
- **Indicators:**
  - Increasing count of "accepted" risks without documented acceptance criteria or reassessment dates
  - Same risks appear in reports quarter after quarter with no remediation progress
  - Team communication treats high-severity findings as "known issues" without urgency
  - Production incidents greeted with "we knew that was fragile" rather than triggering remediation
- **Severity Tendency:** high

### Missing Risk Acceptance Criteria
- **Description:** No documented framework for deciding when to accept vs remediate risks, leading to inconsistent decisions driven by urgency or loudest voice rather than principled assessment of likelihood, impact, and cost.
- **Indicators:**
  - Risk triage meetings result in ad-hoc decisions without reference to criteria
  - Similar risks handled inconsistently (one accepted, another escalated)
  - No risk acceptance artifacts documenting rationale, owner, expiration date, or monitoring plan
  - Stakeholders surprised by production issues from risks assumed to be "handled"
- **Severity Tendency:** medium

### Remediation Without Prioritization
- **Description:** Attempting to fix all identified risks simultaneously or in arbitrary order, leading to resource waste, incomplete fixes, and missing the highest-impact or most time-sensitive issues.
- **Indicators:**
  - Remediation backlog with >50 items and no rank ordering or deadline assignments
  - Engineering time split across many small fixes without addressing critical compound risks
  - No dependency analysis (some fixes unblock others; some are prerequisites)
  - Remediation effort allocated proportionally to finding count per domain rather than impact or urgency
- **Severity Tendency:** medium

## Best Practice Patterns

### Cross-Domain Risk Correlation
- **Replaces Failure Pattern:** Risk Compartmentalization
- **Abstract Pattern:** Analyze relationships between findings across domains, identifying interaction effects and cascading failure modes through correlation matrices and dependency graphs to surface compound risks.
- **Framework Mappings:**
  - Risk Matrix (ISO 31000): Extend 2D likelihood-impact matrix with correlation layers for cross-domain dependencies
  - FAIR (Factor Analysis of Information Risk): Model compound risks using dependency trees and conditional probabilities
  - Bow-Tie Analysis: Map risk interactions with threat scenarios on left, barriers in center, consequences on right
- **Language Patterns:**
  - Python/Pandas: Build correlation matrices between domain metrics (e.g., security score vs ownership concentration)
  - SQL: Join findings tables across domains with shared code location keys to identify multi-domain hotspots
  - Graph databases (Neo4j): Model risks as nodes with interaction edges, query for critical path scenarios

### Compound Risk Identification
- **Replaces Failure Pattern:** Missing Compound Risk Analysis
- **Abstract Pattern:** Define and detect high-priority compound risk scenarios where multiple domain findings intersect in the same code location, multiplying severity through interaction effects.
- **Framework Mappings:**
  - FAIR framework: Calculate compound risk as P(A ∩ B) with amplification factors when risks overlap
  - Risk scenario modeling: Define templates like "security vuln + abandoned owner + production-critical" as tier-1 scenarios
  - Failure Mode and Effects Analysis (FMEA): Score compound risks using detection difficulty × occurrence probability × impact severity
- **Language Patterns:**
  - Rule engines (Drools, Python rules): Define compound risk patterns as logical rules triggering on multi-domain findings
  - Risk scoring algorithms: Multiply base severity by amplification factors (e.g., 2x for single-author, 1.5x for high coupling)
  - Alert thresholds: Escalate when ≥3 high-severity findings from different domains affect same module

### Time-Series Forecasting
- **Replaces Failure Pattern:** Short-Term Bias
- **Abstract Pattern:** Track risk metrics over time, fit trend models to detect acceleration or decay, and predict time-to-failure thresholds to prioritize risks by urgency rather than current severity alone.
- **Framework Mappings:**
  - Predictive analytics: Use linear regression, exponential smoothing, or ARIMA models on metric time series
  - Technical debt interest: Model accumulating debt as compound interest, forecasting when cost-to-fix exceeds cost-to-rewrite
  - Reliability growth models: Apply Weibull or exponential failure models to predict next incident based on historical MTBF trends
- **Language Patterns:**
  - Python statsmodels/Prophet: Fit forecasting models to security debt, test coverage decay, or performance degradation trends
  - Time-series databases (Prometheus, InfluxDB): Store historical risk metrics, query for moving averages and rate-of-change
  - Alerting on derivatives: Trigger when second derivative is positive (acceleration in negative direction)

### Deliberate Risk Acceptance
- **Replaces Failure Pattern:** Risk Normalization
- **Abstract Pattern:** Treat risk acceptance as an explicit decision requiring documented rationale, owner assignment, expiration date, and monitoring plan, preventing invisible accumulation of unaddressed risks.
- **Framework Mappings:**
  - Risk register (ISO 31000): Formal log of accepted risks with fields for justification, owner, review date, and compensating controls
  - Risk acceptance matrix: Document criteria for accept vs mitigate vs transfer vs avoid based on likelihood-impact quadrant
  - Exception management: Use ticketing system with SLA for accepted risk reviews (e.g., quarterly reassessment)
- **Language Patterns:**
  - Issue tracking: Create "accepted risk" ticket type with required fields (rationale, owner, expiry, monitoring)
  - Automated expiration: Alert when accepted risk passes review date without reassessment
  - Compensating controls checklist: Require documentation of mitigations even for accepted risks (e.g., monitoring, incident runbooks)

### Risk Acceptance Framework
- **Replaces Failure Pattern:** Missing Risk Acceptance Criteria
- **Abstract Pattern:** Publish transparent criteria for risk triage decisions, including thresholds for automatic acceptance, escalation triggers, and stakeholder approval requirements, ensuring consistent and defensible risk management.
- **Framework Mappings:**
  - Risk appetite statement: Document organizational tolerance for risk categories (e.g., "no critical security vulns in production code")
  - Decision tree: Flowchart mapping severity × exploitability × impact to accept/mitigate/escalate outcomes
  - RACI matrix: Define who is Responsible, Accountable, Consulted, Informed for risk decisions by severity level
- **Language Patterns:**
  - Risk scoring rubrics: Published formulas for likelihood (1-5) × impact (1-5) with threshold rules (≥15 = escalate, 8-14 = mitigate, <8 = accept)
  - Approval workflows: Automate routing (e.g., critical = CTO approval, high = VP eng, medium = tech lead)
  - Audit trail: Log all risk decisions with timestamp, approver, and criteria reference for compliance review

### Impact-Driven Remediation Sequencing
- **Replaces Failure Pattern:** Remediation Without Prioritization
- **Abstract Pattern:** Order remediation by a composite score combining severity, time-to-failure, dependency blocking, and business criticality, ensuring highest-impact and most time-sensitive issues are addressed first.
- **Framework Mappings:**
  - Weighted shortest job first (WSJF): Prioritize by (business value + time criticality + risk reduction) / effort estimate
  - Dependency-aware scheduling: Use topological sort on remediation dependencies (fix A unblocks B and C)
  - Cost-benefit analysis: Rank by expected value of remediation (incident probability reduction × incident cost - fix cost)
- **Language Patterns:**
  - Priority scoring: Calculate composite = (severity × 0.4) + (urgency × 0.3) + (business criticality × 0.2) + (dependency unblock count × 0.1)
  - Gantt chart generation: Automate remediation roadmap with critical path highlighting and resource allocation
  - Kanban with WIP limits: Cap in-progress remediations to prevent fragmentation, focus on completing high-priority items

## Red Flags

- Risk reports list findings by domain with no cross-references or interaction analysis
- Same high-severity risks appear in quarterly reports without status changes or remediation progress
- Production incident reveals risk combination that was visible across multiple domain reports
- No documented risk acceptance decisions, or "accepted" tag applied without approval artifacts
- Remediation backlog sorted alphabetically or by date found rather than by impact or urgency
- Team treats persistent risks as background noise ("yeah, we know about that")
- Stakeholders express surprise at production issues from risks assumed to be managed
- Risk metrics show only current state with no trend lines or historical context
- No time-to-failure estimates or projections for degrading metrics
- Remediation planning allocates effort equally across domains without dependency or interaction consideration
- No risk acceptance expiration dates or reassessment triggers

## Tool Affinities

| Tool ID | Signal Type | Relevance |
|---------|-------------|-----------|
| git-history | Trend analysis for ownership concentration, change frequency, and documentation staleness over time | primary |
| SonarQube | Historical quality metrics, technical debt trends, code smell accumulation rates | supporting |
| Trivy | CVE discovery date trends, vulnerability backlog age, exploit availability timeline | supporting |
| Semgrep | Security finding trends by rule category, regression detection in security patterns | supporting |
| Gitleaks | Secret exposure timeline, remediation velocity for leaked credentials | contextual |

## Standards & Frameworks

- **ISO 31000 Risk Management** — Risk identification, assessment, treatment, monitoring, and communication framework
- **FAIR (Factor Analysis of Information Risk)** — Quantitative risk modeling with probability distributions and Monte Carlo simulation
- **Bow-Tie Analysis** — Visual method for analyzing risk scenarios with threats, barriers, and consequences
- **FMEA (Failure Mode and Effects Analysis)** — Systematic approach for identifying potential failure modes and prioritizing by severity × occurrence × detection
- **NIST Risk Management Framework (RMF)** — Risk categorization, control selection, monitoring, and authorization
- **DREAD (Damage, Reproducibility, Exploitability, Affected Users, Discoverability)** — Microsoft threat modeling risk scoring
- **Technical Debt Quadrant (Fowler)** — Reckless/Prudent × Deliberate/Inadvertent classification for debt prioritization

## Metrics

| Metric | What It Measures | Healthy Range |
|--------|-----------------|---------------|
| Cross-Domain Risk Score | Composite severity index combining weighted findings across all domains | 0-100; <40 is healthy, >70 requires immediate action |
| Compound Risk Count | Number of code locations with ≥3 high-severity findings from different domains | 0 is ideal; >5 indicates critical compound risks |
| Predicted Time-to-Failure | Estimated days until critical metric crosses failure threshold based on trend analysis | >180 days for all critical systems |
| Risk Acceptance Ratio | Count of deliberately accepted risks / total identified risks | 10-30% (some acceptance is pragmatic; >50% indicates normalization) |
| Risk-Accepted with Expiry | Percentage of accepted risks with documented reassessment dates | 100% (all accepted risks require review cycles) |
| Remediation Velocity | High-severity findings closed per sprint, indicating throughput and prioritization effectiveness | ≥3 per sprint for teams with active risk backlog |
| Time-to-Remediation (P50) | Median days from finding identification to resolution for high-severity risks | <30 days for high, <7 days for critical |
| Worsening Risk Trend % | Percentage of tracked metrics with negative trajectory (increasing debt, decreasing coverage) | <20% (some churn is normal; >40% indicates systemic decay) |
