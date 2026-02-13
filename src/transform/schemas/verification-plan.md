---
id: verification-plan
name: Verification Plan
version: 1.0.0
used_by:
  - execution-validator
  - guardrail-generator
---

## Purpose

A Verification Plan defines the checks that must be performed before, after, and in regression testing of a proposed change, along with the conditions that trigger rollback and the procedure to undo the change. Every change that reaches Authorizing or Executing intervention level (@schema:intervention-level) must have a corresponding Verification Plan. Changes at lower levels may optionally include one.

Verification Plans exist because remediation without verification is hope, not engineering. A fix that passes the developer's mental model but breaks an integration test, a deployment pipeline, or a downstream service is worse than no fix — it introduces a new defect while consuming the effort meant to resolve an existing one. Structured verification catches these failures before they propagate.

The three check categories serve different purposes. Pre-change checks establish a baseline — confirming that the system is in a known-good state before the change is applied. Post-change checks confirm the fix works as intended — the anti-pattern is resolved, the new behavior is correct, and the change integrates properly. Regression checks confirm that nothing else broke — the full test suite passes, dependent services respond correctly, and deployment smoke tests succeed.

Rollback criteria and procedures ensure every change is reversible. A change that cannot be rolled back carries inherently higher risk and should be reflected in the change-risk assessment (@schema:change-risk). The rollback procedure must be concrete — "revert the commit" is only valid when the change is a single commit with no database migrations or infrastructure changes.

## Template

```markdown
### Verification Plan: {change_id}

---

#### Pre-Change Checks

| # | Check | Command/Instruction | Expected Result |
|---|-------|---------------------|-----------------|
| 1 | {check_name} | {command_or_instruction} | {expected_result} |
| 2 | {check_name} | {command_or_instruction} | {expected_result} |

#### Post-Change Checks

| # | Check | Command/Instruction | Expected Result |
|---|-------|---------------------|-----------------|
| 1 | {check_name} | {command_or_instruction} | {expected_result} |
| 2 | {check_name} | {command_or_instruction} | {expected_result} |

#### Regression Checks

| # | Check | Command/Instruction | Expected Result |
|---|-------|---------------------|-----------------|
| 1 | {check_name} | {command_or_instruction} | {expected_result} |
| 2 | {check_name} | {command_or_instruction} | {expected_result} |

---

#### Rollback Criteria

{rollback_criteria}

#### Rollback Procedure

{rollback_procedure}
```

## Field Reference

| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| `change_id` | string | yes | The change this verification plan covers. Must match a change-risk assessment's `change_id` from @schema:change-risk. | Pattern: `CR-\d{3}` |
| `pre_change_checks` | list of objects | yes | Checks to run before applying the change. Establish that the system is in a known-good state. Each object must contain `check_name`, `command_or_instruction`, and `expected_result`. | Minimum 1 check. At least one must be a test-suite execution. |
| `pre_change_checks[].check_name` | string | yes | Short descriptive name for the check. | Free-form, max 60 characters. Should describe what is being verified. |
| `pre_change_checks[].command_or_instruction` | string | yes | The exact command to run or instruction to follow. Must be copy-pasteable into a terminal or actionable without interpretation. | Executable command or concrete instruction. Not "run the tests" — specify which tests. |
| `pre_change_checks[].expected_result` | string | yes | What the check should produce when the system is in a correct state. Must be observable and unambiguous. | Specific output, exit code, or observable condition. Not "it works." |
| `post_change_checks` | list of objects | yes | Checks to run after applying the change. Confirm the fix works as intended. Same object structure as pre_change_checks. | Minimum 1 check. Must include at least one check specific to the remediation (not just general tests). |
| `regression_checks` | list of objects | yes | Checks to confirm no existing functionality is broken. Same object structure as pre_change_checks. | Minimum 1 check. Must include the full test suite or a representative subset. |
| `rollback_criteria` | list of strings | yes | Conditions under which rollback is required. Each criterion must be a specific, observable condition — not a judgment call. | Minimum 1 criterion. Each must be falsifiable (you can definitively say whether it occurred). |
| `rollback_procedure` | string | yes | Step-by-step procedure to undo the change and restore the previous state. Must be concrete — specific commands, specific files, specific actions. | Free-form. Must include at least 2 concrete steps. "Undo the change" is not a valid procedure. |

## Validation Rules

1. `change_id` must match a `change_id` from an existing change-risk assessment in the current audit. A verification plan without a corresponding risk assessment is orphaned — the risk profile is unknown.
2. `pre_change_checks` must contain at least one entry, and at least one check must execute the project's test suite (or relevant subset). If the project has no test suite, this must be noted as a check: "Confirm no test suite exists" with expected result "No test runner configured" — the absence of tests is itself a verifiable condition.
3. `post_change_checks` must contain at least one check that is specific to the remediation being verified. A generic "run all tests" is a regression check, not a post-change check. Post-change checks must verify that the specific anti-pattern is resolved and the correct pattern is in place.
4. `regression_checks` must contain at least one check. For projects with a test suite, this must include a full test-suite run. For projects without tests, regression checks must describe manual verification of key functionality.
5. Every check's `command_or_instruction` must be actionable without interpretation. "Run the relevant tests" is invalid — specify "Run `pytest tests/test_config.py -v`". "Check the deployment" is invalid — specify "Run `curl -s http://localhost:8000/health | jq .status` and confirm output is `ok`".
6. Every check's `expected_result` must be observable and unambiguous. "It works correctly" is invalid. "Exit code 0, all tests pass, no new warnings" is valid. "Output contains `DB_USER` with non-empty value" is valid.
7. `rollback_criteria` must contain at least one entry. Each criterion must be a specific, observable condition — not a judgment call. "If something goes wrong" is invalid. "If `pytest tests/` exits with non-zero code after applying the change" is valid. "If application fails to start within 30 seconds of configuration change" is valid.
8. `rollback_procedure` must contain at least 2 concrete steps. "Revert the change" is valid only when accompanied by the specific revert mechanism (e.g., "Run `git revert HEAD`" or "Restore `config/database.py` from backup at `.aegis/backups/CR-001/database.py`"). If the change involves database migrations, infrastructure changes, or external service configuration, the rollback procedure must address each.

## Examples

### Example: Verification Plan for Credential Externalization

```markdown
### Verification Plan: CR-001

---

#### Pre-Change Checks

| # | Check | Command/Instruction | Expected Result |
|---|-------|---------------------|-----------------|
| 1 | Existing tests pass | `pytest tests/ -v` | Exit code 0, all tests pass |
| 2 | Current config loads | `python -c "from config.database import DB_USER; print(DB_USER)"` | Prints `admin` (current hardcoded value) |
| 3 | Git working tree clean | `git status --porcelain` | Empty output (no uncommitted changes) |

#### Post-Change Checks

| # | Check | Command/Instruction | Expected Result |
|---|-------|---------------------|-----------------|
| 1 | No hardcoded secrets remain | `grep -r "pr0d_s3cret\|admin\|prod-db.internal" config/` | No output (no matches found) |
| 2 | Config loads from environment | Set `DB_USER=test_user DB_PASS=test_pass DB_HOST=localhost` then run `python -c "from config.database import DB_USER; print(DB_USER)"` | Prints `test_user` |
| 3 | Missing env vars fail-closed | Run `unset DB_USER && python -c "from config.database import DB_USER"` | Raises `KeyError: 'DB_USER'` |
| 4 | .env.example exists | `cat .env.example` | Contains `DB_USER=`, `DB_PASS=`, `DB_HOST=` with no values |
| 5 | .env is gitignored | `git check-ignore .env` | Output: `.env` |

#### Regression Checks

| # | Check | Command/Instruction | Expected Result |
|---|-------|---------------------|-----------------|
| 1 | Full test suite | `pytest tests/ -v` with `.env` file present | Exit code 0, all tests pass (including test_config.py) |
| 2 | Application starts | `python app.py &` with `.env` file, then `curl http://localhost:8000/health` | Returns 200 with `{"status": "ok"}` |
| 3 | Config module interface unchanged | `python -c "from config import DB_USER, DB_PASS, DB_HOST; print('OK')"` | Prints `OK` (imports still work via config/__init__.py) |

---

#### Rollback Criteria

- `pytest tests/` exits with non-zero code after applying the change and the failures are in config-related tests
- Application fails to start with error referencing `DB_USER`, `DB_PASS`, or `DB_HOST` environment variables
- Any downstream service reports connection failures to the database after deployment

#### Rollback Procedure

1. Restore the original `config/database.py` from git: `git checkout HEAD~1 -- config/database.py`
2. Remove `python-dotenv` from `requirements.txt`: `git checkout HEAD~1 -- requirements.txt`
3. Remove `.env.example` if it was newly created: `rm .env.example`
4. Run `pytest tests/ -v` to confirm tests pass with restored hardcoded values
5. If already deployed: redeploy with the reverted code and confirm database connectivity
```
