---
id: confidence
name: Confidence Vector
version: 1.0.0
used_by:
  - principal-engineer
  - architect
  - data-engineer
  - security-engineer
  - compliance-officer
  - senior-app-engineer
  - sre
  - performance-engineer
  - test-engineer
  - staff-engineer
  - reality-gap-analyst
  - devils-advocate
---

## Purpose

Confidence in AEGIS is a vector, not a scalar. A single "high/medium/low" rating hides which aspects of confidence are strong and which are weak. An agent might have strong evidence diversity (four tools flagged the same issue) but weak signal freshness (all evidence is static analysis, no runtime validation). A scalar "medium" hides this — the vector exposes it.

The 4-dimension model enables nuanced statements like "High-impact, low-confidence risk — validate before remediation." This is senior-level nuance that scalar confidence destroys.

Each dimension is independently scored on a 1-5 scale with anchored descriptions, producing a confidence profile rather than a confidence rating. The `overall` field derives from the dimensions using a conservative formula — the weakest evidence dimension drags the aggregate down, because a finding is only as trustworthy as its weakest evidential link.

Transform intervention levels gate on confidence dimensions: a finding with low evidence diversity cannot produce a planning-level remediation, regardless of how high its historical precedent score is. This prevents confident-sounding but poorly-evidenced findings from generating unsafe change plans.

## Template

```markdown
#### Confidence Vector

| Dimension | Score | Anchor |
|-----------|-------|--------|
| Evidence diversity | {evidence_diversity} | {evidence_diversity_anchor} |
| Signal freshness | {signal_freshness} | {signal_freshness_anchor} |
| Assumption fragility | {assumption_fragility} | {assumption_fragility_anchor} |
| Historical precedent | {historical_precedent} | {historical_precedent_anchor} |

**Overall:** {overall}
**Justification:** {justification}
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `evidence_diversity` | integer | yes | How many independent source types support this finding. Independent means different evidence categories (static analysis, runtime, history, config), not different tools within the same category. | 1-5 (see scale below) |
| `signal_freshness` | integer | yes | Temporal relevance of the evidence. Static code analysis sees code as-written; runtime data sees code as-running. Fresher signals are more trustworthy for behavioral claims. | 1-5 (see scale below) |
| `assumption_fragility` | integer | yes | How easily the finding's assumptions could be wrong. Inverse fragility — higher scores mean more robust assumptions. | 1-5 (see scale below) |
| `historical_precedent` | integer | yes | Whether this pattern is a known failure mode with documented incidents. Known patterns have higher prior probability and better-understood consequences. | 1-5 (see scale below) |
| `overall` | enum | yes | Conservative aggregate derived from dimension scores. | `low`, `medium`, `high` (see derivation formula) |
| `justification` | string | yes | Explanation of the dimension scores. At minimum, one sentence per dimension scored 4 or 5. Must explain why the score is warranted, not just restate the anchor description. | Free text, minimum one sentence per high-scoring dimension. |

### Dimension Scales

#### Evidence Diversity (1-5)

| Score | Anchor | Description |
|-------|--------|-------------|
| 1 | Single source | One tool or one manual observation. No corroboration. |
| 2 | Single source type | Multiple tools of the same type (e.g., two static analyzers). Corroboration within one evidence category. |
| 3 | Two source types | Two different evidence categories (e.g., static analysis + configuration review). |
| 4 | Three+ source types | Three or more evidence categories (e.g., static + runtime + history). Strong cross-validation. |
| 5 | Comprehensive | Multiple independent source types with cross-validation. Evidence converges from orthogonal directions. |

#### Signal Freshness (1-5)

| Score | Anchor | Description |
|-------|--------|-------------|
| 1 | Historical only | Evidence is from past data only (old git history, archived logs). No current evidence. |
| 2 | Static only | Code as-written analysis. No runtime, deployment, or configuration validation. |
| 3 | Static + config | Static analysis plus recent configuration or deployment data. |
| 4 | Includes runtime | Evidence includes recent runtime data (logs, metrics, profiling). |
| 5 | Live validation | Current runtime validation available. Evidence reflects the system as it runs now. |

#### Assumption Fragility (1-5)

Higher score = more robust assumptions (inverse fragility).

| Score | Anchor | Description |
|-------|--------|-------------|
| 1 | Highly fragile | Finding depends on multiple unverified assumptions. Any one being wrong invalidates the finding. |
| 2 | Fragile | Key assumption is plausible but unverified. Finding may not hold under closer inspection. |
| 3 | Moderate | Key assumptions are reasonable with partial evidence. Finding likely holds but has uncertainty. |
| 4 | Robust | Most assumptions are verified or low-risk. Finding is solid with minor uncertainty. |
| 5 | Self-evident | All assumptions are verified or self-evident from the evidence. Finding is effectively certain given the evidence. |

#### Historical Precedent (1-5)

| Score | Anchor | Description |
|-------|--------|-------------|
| 1 | Novel | No known precedent for this pattern. First-time observation. |
| 2 | Theoretical | Theoretically possible failure mode discussed in literature but rarely observed. |
| 3 | Documented | Known anti-pattern in engineering literature or standards (CWE, OWASP). |
| 4 | Incident-proven | Documented failure mode with real-world incidents. Known to cause production failures. |
| 5 | Frequent | Frequent failure pattern with extensive incident history across the industry. Well-understood failure mode. |

### Overall Derivation

The `overall` confidence is derived conservatively. The formula prioritizes evidential strength (evidence diversity and signal freshness) over pattern recognition (historical precedent).

**Formula:**

```
raw_score = floor(
  min(evidence_diversity, signal_freshness) * 0.6
  + assumption_fragility * 0.3
  + historical_precedent * 0.1
)
```

**Mapping:**
| Raw Score | Overall |
|-----------|---------|
| 1-2 | low |
| 3 | medium |
| 4-5 | high |

**Conservative properties:**
- The `min()` of evidence diversity and signal freshness means the weaker evidential dimension dominates. A finding with 5 evidence sources but only static analysis (freshness = 2) gets a low evidential contribution.
- Assumption fragility carries 30% weight because fragile assumptions undermine even well-evidenced findings.
- Historical precedent carries only 10% weight because "this pattern is known" doesn't compensate for weak evidence in this specific instance.

**Override rule:** If any single dimension scores 1, the overall is capped at `low` regardless of other dimension scores. A finding with one catastrophically weak dimension cannot be trusted at any aggregate level.

## Validation Rules

1. **Integer range:** Each dimension must be an integer in the range 1-5. No fractional scores, no scores outside range.
2. **All dimensions required:** All four dimensions must be present. Omitting a dimension is a validation error — confidence cannot be partially assessed.
3. **Overall derivation:** `overall` must be derived from the formula. Manual override of the overall is not permitted — the formula enforces conservative aggregation.
4. **Override enforcement:** If any dimension is 1, overall must be `low`. Any other value is a validation error.
5. **Justification required:** `justification` is required and must contain at minimum one sentence per dimension scored 4 or 5. High scores without explanation are the primary vector for confidence inflation.
6. **Consistency check — evidence diversity vs others:** `evidence_diversity` of 1 (single source) with `signal_freshness` of 4+ or `assumption_fragility` of 5 is flagged as inconsistent. A single source cannot produce live runtime validation or self-evident assumptions across a broad finding.
7. **Immutability:** Confidence vectors are immutable once attached to a submitted finding. If confidence changes, the finding must be reissued with a new version (appending a version suffix to the finding_id, e.g., `F-04-001v2`).

## Examples

### Example 1: High-Confidence Finding — Hardcoded Credentials

```markdown
#### Confidence Vector

| Dimension | Score | Anchor |
|-----------|-------|--------|
| Evidence diversity | 4 | Three+ source types |
| Signal freshness | 2 | Static only |
| Assumption fragility | 5 | Self-evident |
| Historical precedent | 5 | Frequent |

**Overall:** high
**Justification:**
- Evidence diversity (4): Four independent sources — Gitleaks (secrets scan), Semgrep (static analysis), SonarQube (static analysis), and git history (commit archaeology). Three distinct evidence categories (secrets scan, static analysis, commit history).
- Signal freshness (2): All evidence is from static analysis of the codebase. No runtime confirmation that these values are actually used in production (could be overridden by environment variables). However, for hardcoded credentials, static evidence is sufficient — the credentials are visible regardless of runtime behavior.
- Assumption fragility (5): The credentials are plaintext string literals assigned to database connection variables. The observation is self-evident from the code — no inference or interpretation required to establish that credentials exist in source code.
- Historical precedent (5): CWE-798 (Use of Hard-coded Credentials) is among the most documented and frequently observed security failures. Extensive incident history across all industries and technology stacks.

Derivation: min(4, 2) * 0.6 + 5 * 0.3 + 5 * 0.1 = 1.2 + 1.5 + 0.5 = 3.2 → floor(3.2) = 3 → medium.
Override: No dimension is 1. But note the raw formula yields medium despite the finding being very well-supported. This is the conservative bias at work — signal freshness of 2 drags the evidential component down. In practice, the Principal Engineer may note that this specific finding type (plaintext credentials) does not require runtime validation, and the overall is appropriate for the confidence gating thresholds (medium enables Planning intervention level).
```

### Example 2: Low-Confidence Finding — Potential Race Condition

```markdown
#### Confidence Vector

| Dimension | Score | Anchor |
|-----------|-------|--------|
| Evidence diversity | 1 | Single source |
| Signal freshness | 2 | Static only |
| Assumption fragility | 2 | Fragile |
| Historical precedent | 3 | Documented |

**Overall:** low
**Justification:**
- Evidence diversity (1): Single source — manual code review of the request handler. No tool flagged this pattern. No runtime data, no concurrency testing results.
- Signal freshness (2): Static code analysis only. The race condition is inferred from code structure (read-modify-write without locking), not observed in runtime behavior.
- Assumption fragility (2): The finding assumes concurrent requests to the same endpoint modify the same database row simultaneously. This is plausible for a multi-user system but unverified — the actual request concurrency pattern is unknown without runtime data. If the endpoint is rarely called concurrently, the race condition may never manifest.
- Historical precedent (3): Read-modify-write race conditions are a documented anti-pattern in concurrent systems (CWE-362). Known in literature and standards, but the specific manifestation depends heavily on deployment context.

Derivation: min(1, 2) * 0.6 + 2 * 0.3 + 3 * 0.1 = 0.6 + 0.6 + 0.3 = 1.5 → floor(1.5) = 1 → low.
Override: evidence_diversity is 1, so overall is capped at low regardless. This finding needs corroborating evidence (concurrency testing, runtime logs showing concurrent access) before it can support any intervention level above Suggesting.
```
