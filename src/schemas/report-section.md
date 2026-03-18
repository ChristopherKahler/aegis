---
id: report-section
name: Report Section
version: 1.0.0
used_by:
  - principal-engineer
  - phase-5-synthesis-workflow
---

## Purpose

The report section schema defines the structure of the AEGIS Layer A diagnostic report — the primary deliverable of every audit. The report consists of 7 sections in fixed order, each with a defined purpose, required content, data sources, and target audience.

This schema governs structure, not generation. How the report is assembled is workflow logic (Phase 6). What the report must contain is defined here. The distinction prevents structural drift across audits — every AEGIS report has the same sections in the same order with the same content requirements, regardless of the target codebase.

## Template

```markdown
# AEGIS Audit Report: {project_name}

**Audit ID:** {audit_id}
**Date:** {audit_date}
**Version:** {audit_version}
**Target:** {target_description}

---

## Section 1: Executive Risk Summary

{executive_risk_summary}

## Section 2: Architecture Narrative

{architecture_narrative}

## Section 3: Findings by Domain (Severity-Ranked)

### Domain {DD} — {domain_name}

{domain_findings_block}

[Repeated for all 14 domains]

## Section 4: Cross-Validation Notes

{cross_validation_notes}

## Section 5: Remediation Roadmap

{remediation_roadmap}

## Section 6: Long-Term Structural Risks

{long_term_risks}

## Section 7: What Would Break First at 10x Scale

{scale_failure_analysis}

---

**Audit metadata:**
- Agents deployed: {agent_list}
- Tools executed: {tool_list}
- Total findings: {finding_count}
- Total disagreements: {disagreement_count}
- Unresolved disagreements: {unresolved_count}
```

## Field Reference

### Report Metadata

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `audit_id` | string | yes | Unique identifier for this audit run. | Format: `AEGIS-{YYYYMMDD}-{NNN}` |
| `audit_date` | string | yes | Date the audit was completed. | ISO 8601 date. |
| `audit_version` | string | yes | Version of the AEGIS system used. | Semantic version matching AEGIS release. |
| `target_description` | string | yes | What was audited. | Repository name, path, and scope constraints. |

### Section Specifications

| Section | Name | Required Content | Data Sources | Audience |
|---------|------|-----------------|--------------|----------|
| 1 | Executive Risk Summary | Top 5 risks by severity, overall risk posture (critical/high/medium/low), count of findings per severity, count of unresolved disagreements, single-paragraph assessment | Aggregated @schema:finding by severity, @schema:disagreement with status: open | Leadership, non-technical stakeholders |
| 2 | Architecture Narrative | System description, architectural pattern identified, component map, dependency direction analysis, key strengths, key concerns | Domain 00 (Context) Phase 0 output, Domain 01 (Architecture) findings | Technical leadership, architects |
| 3 | Findings by Domain | All findings grouped by domain (00-13), severity-ranked within each domain, each finding in full @schema:finding format | All @schema:finding instances | Engineering teams, domain owners |
| 4 | Cross-Validation Notes | All disagreements with positions, root causes, resolution models, and Principal responses. Disagreement heatmap data (severity x disagreement intensity). | All @schema:disagreement instances | Principal Engineer, technical leadership |
| 5 | Remediation Roadmap | Prioritized action plan, findings with action: must_fix or should_fix, ordered by severity then dependency, estimated effort categories, quick wins highlighted | @schema:finding where action is must_fix or should_fix | Engineering teams, project managers |
| 6 | Long-Term Structural Risks | Risks that worsen over time — architectural erosion, tech debt accumulation, knowledge concentration, test coverage decay | @schema:finding where time_horizon is long_term or hypothetical | Technical leadership, architects |
| 7 | What Would Break First at 10x Scale | Predictive failure analysis — which components fail first under 10x load/users/data, bottleneck identification, cascade failure paths | Domain 07 (Reliability) + Domain 08 (Performance) findings, findings with blast_radius: systemic | CTO, architects, SRE team |

### Section Content Rules

| Rule | Applies To | Description |
|------|-----------|-------------|
| Severity ranking | Section 3 | Findings within each domain are ordered: critical → high → medium → low → informational |
| Completeness | Section 3 | All 14 domains must be present. Domains with no findings state "No findings in this domain." |
| Resolution status | Section 4 | Each disagreement shows current status. Unresolved disagreements are flagged. |
| Dependency ordering | Section 5 | Remediations are ordered by dependency (foundation fixes before dependent fixes), not just severity. |
| Evidence grounding | Section 7 | Predictions must reference specific findings and evidence, not speculation. |

## Validation Rules

1. **All sections required:** All 7 sections must be present. Omitting a section is a validation error, even if the section would be sparse.
2. **Fixed order:** Sections must appear in order 1-7. Reordering is a validation error.
3. **Section 3 completeness:** All 14 domains (00-13) must be represented in Section 3, even if a domain has zero findings.
4. **Data source traceability:** Every finding in Section 3 must have a valid finding_id matching @schema:finding. Every disagreement in Section 4 must have a valid disagreement_id matching @schema:disagreement.
5. **Executive summary constraints:** Section 1 must not exceed one page equivalent (~500 words). It is a summary, not a detailed analysis.
6. **No orphaned references:** Any finding_id or disagreement_id referenced in the report must exist in the audit's dataset. Forward references to findings not yet produced are invalid.
7. **Unresolved disagreement count:** Report metadata must accurately count disagreements with status: open. A report claiming zero unresolved disagreements when open disagreements exist is a validation error.

## Examples

### Example: Executive Risk Summary (Section 1)

```markdown
## Section 1: Executive Risk Summary

**Overall Risk Posture: HIGH**

| Severity | Count |
|----------|-------|
| Critical | 2 |
| High | 7 |
| Medium | 14 |
| Low | 8 |
| Informational | 3 |

**Top 5 Risks:**

1. **F-04-001 — Hardcoded production database credentials** (Critical, Security)
   Plaintext credentials in source code accessible to all repository users. Immediate remediation required.

2. **F-04-012 — Missing authentication on admin API endpoints** (Critical, Security)
   Three admin endpoints accept unauthenticated requests. Exploitation is trivial.

3. **F-01-003 — Circular dependency between core modules** (High, Architecture)
   Service layer and data layer have bidirectional dependencies, preventing independent deployment and testing.

4. **F-07-002 — No circuit breaker on external API calls** (High, Reliability)
   Downstream service failures cascade into full application unavailability.

5. **F-02-005 — Race condition in user balance updates** (High, Data Integrity)
   Concurrent requests can produce incorrect balances. Confirmed by code structure; unverified at runtime.

**Disagreements:** 4 total, 1 unresolved (D-003: severity of F-02-005 disputed between data-engineer and senior-app-engineer).

**Assessment:** The codebase has two critical security vulnerabilities requiring immediate attention. Architectural issues (circular dependencies, missing circuit breakers) create systemic fragility that will worsen under growth. The unresolved disagreement on F-02-005 needs runtime validation to determine true severity.
```
