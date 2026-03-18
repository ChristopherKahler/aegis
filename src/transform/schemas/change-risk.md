---
id: change-risk
name: Change Risk Assessment
version: 1.0.0
used_by:
  - change-risk-modeler
  - execution-validator
---

## Purpose

A Change Risk Assessment is a multi-dimensional risk evaluation for a proposed change to the target codebase. Every change that Transform considers — from a single-line configuration fix to a multi-file architectural refactor — must be assessed across four risk dimensions before a recommendation is issued.

Risk assessment exists because fixes have costs. A remediation that addresses a medium-severity finding but introduces high coupling risk and touches untested code paths may cause more damage than the original issue. Without structured risk assessment, Transform optimizes for "fix count" rather than "net improvement" — producing technically correct remediations that are practically dangerous.

Each risk dimension captures a different failure mode of change: blast radius measures how widely a change ripples, coupling risk measures whether the fix creates new dependencies, regression probability measures the likelihood of breaking existing functionality, and architectural tension measures whether the fix conflicts with the codebase's design direction. All four dimensions must be scored with evidence — a score without evidence is an unsupported assertion.

The overall risk classification and recommendation are derived from the dimensional scores but are not mechanical averages. A change with three dimensions at 1/5 and one dimension at 5/5 is not "low risk" — the critical dimension dominates. This mirrors the conservative derivation principle from @schema:confidence: the weakest dimension determines the overall posture.

Change Risk Assessments are consumed by the safety governance rules to gate intervention levels. High-risk changes are automatically constrained to lower intervention levels regardless of finding confidence.

## Template

```markdown
### {change_id}

**Findings Addressed:** {finding_refs}
**Overall Risk:** {overall_risk}
**Recommendation:** {recommendation}

---

#### Blast Radius

**Score:** {blast_radius_score}/5
**Evidence:** {blast_radius_evidence}
**Affected Files:** {affected_files}

#### Coupling Risk

**Score:** {coupling_risk_score}/5
**Evidence:** {coupling_risk_evidence}
**New Dependencies:** {new_dependencies}

#### Regression Probability

**Score:** {regression_probability_score}/5
**Evidence:** {regression_probability_evidence}
**Test Coverage:** {test_coverage_pct}%

#### Architectural Tension

**Score:** {architectural_tension_score}/5
**Evidence:** {architectural_tension_evidence}
**Design Conflicts:** {design_conflicts}

---

#### Risk Summary

{risk_summary}
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `change_id` | string | yes | Unique change identifier. Format: `CR-{NNN}` where NNN is sequence. | Pattern: `CR-\d{3}` |
| `finding_refs` | list of strings | yes | Finding IDs this change addresses. A single change may remediate multiple related findings. Each must match a valid finding ID from @schema:finding. | List of `F-\d{2}-\d{3}` patterns. Minimum 1 entry. |
| `blast_radius_score` | integer | yes | How widely the change ripples through the codebase. | 1 (single file, no downstream consumers) to 5 (cross-service, multiple deployment units affected) |
| `blast_radius_evidence` | string | yes | Justification referencing specific dependency chains, import trees, or API contracts affected. | Free-form. Must cite concrete files or modules. |
| `affected_files` | list of strings | yes | Every file that will be directly modified or created by this change. | File paths relative to project root. Minimum 1 entry. |
| `coupling_risk_score` | integer | yes | Whether the change introduces or tightens coupling between components. | 1 (no new coupling, change is internal to one module) to 5 (creates hard dependency on external system or service) |
| `coupling_risk_evidence` | string | yes | Justification referencing specific interfaces, imports, or dependency relationships that are created or modified. | Free-form. Must cite concrete interfaces or dependencies. |
| `new_dependencies` | list of strings | yes | New package dependencies, service dependencies, or interface contracts introduced by this change. Empty list if no new dependencies. | List of dependency identifiers (package names, service names, API contracts). |
| `regression_probability_score` | integer | yes | Likelihood the change breaks existing functionality. | 1 (additive change, no existing behavior modified) to 5 (modifies core logic path with no test coverage) |
| `regression_probability_evidence` | string | yes | Justification referencing test coverage data, affected code paths, and historical change failure rates. | Free-form. Must cite test files, coverage metrics, or historical data. |
| `test_coverage_pct` | number | yes | Test coverage percentage for the files being modified. If unknown, state 0 with evidence explaining why coverage data is unavailable. | 0-100. |
| `architectural_tension_score` | integer | yes | Whether the change conflicts with the codebase's architectural direction or established patterns. | 1 (aligns with existing patterns) to 5 (contradicts established architecture, requires pattern migration) |
| `architectural_tension_evidence` | string | yes | Justification referencing architectural patterns, design documents, or established conventions in the codebase. | Free-form. Must cite concrete patterns or conventions. |
| `design_conflicts` | list of strings | yes | Specific architectural patterns or design decisions that this change conflicts with. Empty list if no conflicts. | List of pattern descriptions or document references. |
| `overall_risk` | enum | yes | Aggregate risk classification. Not a mechanical average — the highest-scoring dimension dominates. A single dimension at 5 with three at 1 is still high risk. | `low` (max dimension ≤2), `medium` (max dimension 3), `high` (max dimension 4), `critical` (any dimension 5) |
| `recommendation` | enum | yes | Action recommendation derived from overall risk. Must be logically consistent with the risk classification. | `proceed` (low risk, no special precautions), `proceed_with_caution` (medium risk, additional verification recommended), `human_review_required` (high risk, human must approve before execution), `reject` (critical risk, change should not be applied as designed) |
| `risk_summary` | string | yes | 2-4 sentence synthesis explaining the overall risk posture, the dominant risk dimension, and why the recommendation follows from the assessment. | Free-form. Must reference the specific dimensions that drive the recommendation. |

## Validation Rules

1. `change_id` must be unique across the entire audit. No two change risk assessments may share an ID. Format must match `CR-{NNN}`.
2. `finding_refs` must contain at least one entry. Each entry must reference a valid finding ID from the current audit. A change that addresses no findings is purposeless.
3. All four risk dimensions must have a score (integer 1-5), evidence (non-empty string), and dimension-specific sub-fields populated. A score without evidence is an unsupported assertion — it cannot be challenged or verified.
4. `overall_risk` must reflect the dominant dimension: if any dimension scores 5, overall must be `critical`; if max dimension is 4, overall must be `high`; if max is 3, overall must be `medium`; if max is ≤2, overall must be `low`. Overriding this mapping requires explicit justification in `risk_summary`.
5. `recommendation` must be logically consistent with `overall_risk`: `critical` risk cannot produce `proceed` or `proceed_with_caution`; `low` risk with `reject` must justify in `risk_summary`. The valid combinations are: low→proceed, medium→proceed_with_caution, high→human_review_required, critical→reject. Deviations require justification.
6. `affected_files` must list every file that will be directly modified. An empty list is invalid — every change touches at least one file. Files listed here must be verifiable against the actual change.
7. `test_coverage_pct` of 0 is valid only when accompanied by evidence explaining why coverage data is unavailable (no test suite, no coverage tooling, files are generated). A 0 without explanation is suspicious and should trigger reviewer attention.
8. `risk_summary` must reference the specific dimension(s) that drive the recommendation. A generic summary like "this change is low risk" without citing which dimensions support that conclusion is invalid.

## Examples

### Example: Low-Risk Configuration Change

```markdown
### CR-001

**Findings Addressed:** F-04-001
**Overall Risk:** low
**Recommendation:** proceed

---

#### Blast Radius

**Score:** 2/5
**Evidence:** Change is confined to `config/database.py` (3 lines modified) and `requirements.txt` (1 line added). The `config/__init__.py` module imports `DB_USER`, `DB_PASS`, `DB_HOST` from `database.py` — these variable names are unchanged, so downstream consumers are unaffected. No API contracts change. No deployment configuration changes beyond environment variable provisioning.
**Affected Files:** config/database.py, requirements.txt, .env.example, .gitignore

#### Coupling Risk

**Score:** 2/5
**Evidence:** Introduces runtime dependency on `python-dotenv` package (well-maintained, 15M weekly downloads, no transitive dependencies). Introduces implicit dependency on environment variable availability — application will fail to start without `DB_USER`, `DB_PASS`, `DB_HOST` set. This is intentional fail-closed behavior.
**New Dependencies:** python-dotenv

#### Regression Probability

**Score:** 2/5
**Evidence:** `tests/test_config.py` has 4 test cases covering database configuration import. Tests currently import the hardcoded values directly. After change, tests will need either a `.env` file in the test environment or environment variables set in the test runner. Test coverage for `config/` module is 78% per coverage.py output.
**Test Coverage:** 78%

#### Architectural Tension

**Score:** 1/5
**Evidence:** Environment-based configuration is already the established pattern in this codebase. `config/api.py` (line 8) uses `os.environ["API_KEY"]`. `config/redis.py` (line 5) uses `os.environ["REDIS_URL"]`. The database configuration is the only module still using hardcoded values — this change makes it consistent with the existing pattern.
**Design Conflicts:** []

---

#### Risk Summary

This is a low-risk configuration change. The highest-scoring dimensions (blast radius and regression probability, both 2/5) are driven by the test fixture update needed and the new `python-dotenv` dependency, neither of which introduces meaningful risk. The change aligns with established codebase patterns (architectural tension 1/5) and the fail-closed behavior of `os.environ["KEY"]` is a deliberate safety property. Recommendation: proceed without special precautions.
```
