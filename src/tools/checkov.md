---
id: checkov
name: Checkov
type: iac_scan
domains_fed: ["04", "05"]
install_required: true
install_command: "See Installation section — pip, brew, or Docker"
---

## Purpose

Static analysis tool for Infrastructure as Code (IaC) that identifies security misconfigurations and compliance violations before infrastructure is provisioned. Scans Terraform, CloudFormation, Kubernetes manifests, Dockerfiles, Helm charts, and ARM templates against a library of 1,000+ built-in security policies. Primary signal source for infrastructure security posture and compliance alignment. Feeds Security (04) and Compliance (05) domains.

Checkov evaluates IaC declaratively — it reads resource definitions and matches them against policy rules without requiring live cloud credentials or deployed infrastructure. Scans are fast (typically seconds to low minutes) because no runtime state is involved.

Signals are NOT findings. Checkov produces evidence that agents interpret.

## Configuration

Checkov supports configuration via `.checkov.yaml` file and command-line flags.

**Configuration File** (`.checkov.yaml`):
```yaml
directory:
  - ./terraform
  - ./kubernetes
framework:
  - terraform
  - kubernetes
  - dockerfile
output:
  - json
skip-check:
  - CKV_AWS_20    # S3 public access acceptable for static site bucket
  - CKV_K8S_14    # runAsRootGroup enforced at namespace admission level
soft-fail: true
compact: false
```

**Key Configuration Options**:
- **Framework Selection**: `--framework terraform,cloudformation,kubernetes,dockerfile,helm,arm` limits scan scope to relevant frameworks
- **Check Skipping**: `--skip-check CKV_AWS_20,CKV_AWS_57` suppresses known acceptable-risk or false-positive checks; include justification in comments
- **Custom Policies**: `--external-checks-dir ./checkov-custom-policies` loads org-specific policy YAML or Python checks
- **Severity Thresholds**: `--check-threshold HIGH` fails only on high-severity checks (requires Checkov ≥2.2.0)
- **Compact Output**: `--compact` omits passing checks from output to reduce noise
- **Baseline Mode**: `--create-baseline` captures current state; subsequent runs only report new violations
- **Soft Fail**: `--soft-fail` returns exit code 0 even when checks fail (useful in CI pipelines that should not block on findings)

**Custom Policy Directory** (`./checkov-custom-policies/`):

Custom YAML-based policies follow Checkov's `custom_checks` schema:
```yaml
metadata:
  name: "Require encryption at rest for all RDS instances"
  id: "CKV2_CUSTOM_001"
  category: "ENCRYPTION"
  severity: "HIGH"
definition:
  and:
    - cond_type: attribute
      resource_types:
        - aws_db_instance
      attribute: storage_encrypted
      operator: equals
      value: "true"
```

**Environment Variables**:
- `BC_API_KEY`: Bridgecrew/Prisma Cloud API key for enhanced policy sets and SaaS reporting
- `CHECKOV_RUNNER_MAX_WORKERS`: Parallelism control for large IaC repositories
- `CHECKOV_EXPERIMENTAL_TERRAFORM_MANAGED_MODULES`: Enable module resolution in experimental mode

## Execution

### Installation Options

**1. pip** (recommended for scripted environments):
```bash
pip install checkov
# Or for a specific version:
pip install checkov==3.2.158
```

**2. Homebrew** (macOS/Linux):
```bash
brew install checkov
```

**3. Docker** (recommended for CI/CD and consistency):
```bash
docker pull bridgecrew/checkov:latest
```

**4. pipx** (isolated install, avoids dependency conflicts):
```bash
pipx install checkov
```

### Primary Execution Commands

**Full IaC Scan — Filesystem** (AEGIS primary use case):
```bash
checkov --directory {target_path} \
  --framework terraform,cloudformation,kubernetes,dockerfile,helm \
  --output json \
  --output-file-path {output_dir}/checkov-results.json \
  --compact \
  --soft-fail
```

**Docker Variant**:
```bash
docker run --rm \
  -v {target_path}:/target \
  -v {output_dir}:/output \
  bridgecrew/checkov:latest \
  --directory /target \
  --framework terraform,cloudformation,kubernetes,dockerfile,helm \
  --output json \
  --output-file-path /output/checkov-results.json \
  --compact \
  --soft-fail
```

**Single File Scan**:
```bash
checkov --file {target_path}/main.tf \
  --framework terraform \
  --output json \
  --output-file-path {output_dir}/checkov-results.json
```

**Terraform Plan Scan** (post-`terraform plan`, catches computed values):
```bash
terraform plan -out=tfplan.binary && terraform show -json tfplan.binary > tfplan.json
checkov --file tfplan.json \
  --framework terraform_plan \
  --output json \
  --output-file-path {output_dir}/checkov-tfplan-results.json
```

### Execution Parameters

| Parameter | Purpose | Values | Default |
|-----------|---------|--------|---------|
| `--directory` / `-d` | Target directory to scan | directory path | current dir |
| `--file` / `-f` | Single file to scan | file path | — |
| `--framework` | Limit to specific frameworks | terraform, cloudformation, kubernetes, dockerfile, helm, arm, terraform_plan, all | all |
| `--output` / `-o` | Output format | cli, json, junitxml, github_failed_only, sarif | cli |
| `--output-file-path` | Write output to file | file path | stdout |
| `--skip-check` | Comma-separated check IDs to suppress | CKV_AWS_*, CKV_K8S_*, etc. | none |
| `--check` | Run only specified check IDs | CKV_AWS_*, CKV_K8S_*, etc. | all enabled |
| `--compact` | Omit passed checks from output | boolean | false |
| `--soft-fail` | Return exit 0 even on failures | boolean | false |
| `--external-checks-dir` | Custom policy directory | directory path | none |
| `--check-threshold` | Minimum severity to report | LOW, MEDIUM, HIGH, CRITICAL | LOW |
| `--create-baseline` | Snapshot current state as baseline | boolean | false |
| `--baseline` | Compare against saved baseline file | file path | none |
| `--download-external-modules` | Resolve Terraform registry modules | boolean | false |

### Runtime Characteristics

- **Terraform/CloudFormation scans**: 5–30 seconds for typical project sizes (< 200 resources)
- **Kubernetes manifests**: 2–10 seconds per cluster manifest directory
- **Dockerfile scans**: Near-instant (< 2 seconds per file)
- **Large monorepos**: 1–3 minutes for repositories with thousands of IaC files
- **Terraform Plan scans**: Slightly slower than static HCL scans due to JSON plan size
- **Resource Usage**: Low CPU, negligible memory; no network required after install
- **Offline Operation**: Fully offline; no cloud credentials or external API calls required for built-in checks
- **Failure Modes**: Returns exit code 1 when checks fail (use `--soft-fail` for non-blocking CI integration); exits with error on parse failures for malformed IaC files

## Output Format

Checkov produces structured JSON with a results object split into `passed_checks` and `failed_checks`. AEGIS normalization processes only `failed_checks`.

```json
{
  "check_type": "terraform",
  "results": {
    "passed_checks": [
      {
        "check_id": "CKV_AWS_18",
        "bc_check_id": "BC_AWS_LOGGING_3",
        "check_name": "Ensure the S3 bucket has access logging enabled",
        "check_result": {
          "result": "passed",
          "evaluated_keys": ["logging/[0]/target_bucket"]
        },
        "file_path": "/terraform/modules/storage/main.tf",
        "file_abs_path": "/home/runner/project/terraform/modules/storage/main.tf",
        "repo_file_path": "/terraform/modules/storage/main.tf",
        "file_line_range": [12, 28],
        "resource": "aws_s3_bucket.audit_logs",
        "evaluations": null,
        "check_class": "checkov.terraform.checks.resource.aws.S3AccessLogs",
        "fixed_definition": null,
        "entity_tags": {
          "Environment": "production",
          "Team": "platform"
        }
      }
    ],
    "failed_checks": [
      {
        "check_id": "CKV_AWS_19",
        "bc_check_id": "BC_AWS_S3_14",
        "check_name": "Ensure all data stored in the S3 bucket is securely encrypted at rest",
        "check_result": {
          "result": "failed",
          "evaluated_keys": ["server_side_encryption_configuration/[0]/rule/[0]/apply_server_side_encryption_by_default/[0]/sse_algorithm"]
        },
        "file_path": "/terraform/modules/storage/main.tf",
        "file_abs_path": "/home/runner/project/terraform/modules/storage/main.tf",
        "repo_file_path": "/terraform/modules/storage/main.tf",
        "file_line_range": [42, 67],
        "resource": "aws_s3_bucket.application_data",
        "evaluations": null,
        "check_class": "checkov.terraform.checks.resource.aws.S3Encryption",
        "fixed_definition": null,
        "entity_tags": {
          "Environment": "production",
          "Team": "backend"
        }
      },
      {
        "check_id": "CKV_AWS_86",
        "bc_check_id": "BC_AWS_S3_52",
        "check_name": "Ensure S3 bucket has a lifecycle configuration",
        "check_result": {
          "result": "failed",
          "evaluated_keys": ["lifecycle_rule"]
        },
        "file_path": "/terraform/modules/storage/main.tf",
        "file_abs_path": "/home/runner/project/terraform/modules/storage/main.tf",
        "repo_file_path": "/terraform/modules/storage/main.tf",
        "file_line_range": [42, 67],
        "resource": "aws_s3_bucket.application_data",
        "evaluations": null,
        "check_class": "checkov.terraform.checks.resource.aws.S3LifecycleConfiguration",
        "fixed_definition": null,
        "entity_tags": {
          "Environment": "production",
          "Team": "backend"
        }
      },
      {
        "check_id": "CKV_K8S_28",
        "bc_check_id": "BC_K8S_27",
        "check_name": "Minimize the admission of containers with added capability",
        "check_result": {
          "result": "failed",
          "evaluated_keys": ["spec/[0]/containers/[0]/securityContext/[0]/capabilities/[0]/add"]
        },
        "file_path": "/kubernetes/deployments/api-server.yaml",
        "file_abs_path": "/home/runner/project/kubernetes/deployments/api-server.yaml",
        "repo_file_path": "/kubernetes/deployments/api-server.yaml",
        "file_line_range": [33, 58],
        "resource": "Deployment.default.api-server",
        "evaluations": null,
        "check_class": "checkov.kubernetes.checks.resource.k8s.Capabilities",
        "fixed_definition": null,
        "entity_tags": {}
      },
      {
        "check_id": "CKV_DOCKER_2",
        "bc_check_id": "BC_DKR_2",
        "check_name": "Ensure that HEALTHCHECK instructions have been added to the container image",
        "check_result": {
          "result": "failed",
          "evaluated_keys": ["HEALTHCHECK"]
        },
        "file_path": "/services/api/Dockerfile",
        "file_abs_path": "/home/runner/project/services/api/Dockerfile",
        "repo_file_path": "/services/api/Dockerfile",
        "file_line_range": [1, 24],
        "resource": "Dockerfile",
        "evaluations": null,
        "check_class": "checkov.dockerfile.checks.HealthcheckExists",
        "fixed_definition": null,
        "entity_tags": {}
      },
      {
        "check_id": "CKV_AWS_111",
        "bc_check_id": "BC_AWS_IAM_56",
        "check_name": "Ensure IAM policies does not have statements with admin permissions",
        "check_result": {
          "result": "failed",
          "evaluated_keys": ["statement/[0]/action", "statement/[0]/resource"]
        },
        "file_path": "/terraform/iam/policies.tf",
        "file_abs_path": "/home/runner/project/terraform/iam/policies.tf",
        "repo_file_path": "/terraform/iam/policies.tf",
        "file_line_range": [88, 107],
        "resource": "aws_iam_policy.deployment_role_policy",
        "evaluations": null,
        "check_class": "checkov.terraform.checks.resource.aws.IAMAdminPolicyDocument",
        "fixed_definition": null,
        "entity_tags": {
          "Environment": "production",
          "ManagedBy": "terraform"
        }
      }
    ],
    "skipped_checks": [
      {
        "check_id": "CKV_AWS_20",
        "check_name": "Ensure the S3 bucket does not have MFA delete disabled",
        "check_result": {
          "result": "skipped",
          "suppress_comment": "S3 public access acceptable for static site hosting bucket"
        },
        "file_path": "/terraform/modules/cdn/main.tf",
        "file_abs_path": "/home/runner/project/terraform/modules/cdn/main.tf",
        "repo_file_path": "/terraform/modules/cdn/main.tf",
        "file_line_range": [5, 19],
        "resource": "aws_s3_bucket.static_assets"
      }
    ],
    "parsing_errors": []
  },
  "summary": {
    "passed": 47,
    "failed": 5,
    "skipped": 1,
    "parsing_error": 0,
    "resource_count": 38,
    "checkov_version": "3.2.158"
  }
}
```

**Key Output Fields**:
- `check_type`: IaC framework evaluated (terraform, cloudformation, kubernetes, dockerfile, helm, arm)
- `results.failed_checks[]`: Checks that did not pass — these become AEGIS signals
- `results.passed_checks[]`: Checks that passed — informational only, not normalized as signals
- `results.skipped_checks[]`: Explicitly suppressed checks — audit trail only
- `check_id`: Checkov-native check identifier (CKV_AWS_*, CKV_K8S_*, CKV_DOCKER_*, etc.)
- `bc_check_id`: Bridgecrew SaaS platform check identifier (present even in open-source runs)
- `check_name`: Human-readable description of what the policy checks
- `check_result.result`: "passed", "failed", or "skipped"
- `check_result.evaluated_keys`: Specific attribute path(s) that determined the result
- `file_path`: Relative path to the IaC file containing the resource
- `file_line_range`: Line numbers bounding the resource block in the file
- `resource`: Terraform resource address or Kubernetes resource identifier
- `entity_tags`: Tags applied to the IaC resource (useful for blast radius scoping)
- `summary.checkov_version`: Version used, relevant for policy coverage differences

## Normalization

Checkov raw output requires normalization to AEGIS signal format. Only `failed_checks` entries are normalized — `passed_checks` and `skipped_checks` are not converted to signals.

| Checkov Field | AEGIS Signal Field | Transformation Logic |
|---------------|-------------------|----------------------|
| Auto-generated | `signal_id` | Pattern: `S-CHK-{NNN}` (sequential per scan run) |
| Fixed value | `source_tool` | Always "checkov" |
| `check_id` | `source_rule` | Direct mapping (e.g., CKV_AWS_19) |
| `check_name` | `title` | Direct mapping |
| `file_path` + `resource` | `file_path` | Combine: `{file_path}:{resource}` (e.g., "/terraform/modules/storage/main.tf:aws_s3_bucket.application_data") |
| `file_line_range` | `line_range` | Direct mapping as `[start, end]` tuple |
| `check_result.evaluated_keys` | `context` | Enriched: "Policy {check_id} evaluated attribute(s): {evaluated_keys}" |
| Derived from `check_id` category | `severity` | Category-based derivation — see rules below |
| Fixed value | `confidence_estimate` | Always "high" — IaC checks are deterministic pattern matching |
| Derived from resource scope | `blast_radius` | Infrastructure-wide resource types→widespread, single-resource→localized |
| Derived from `check_id` category | `domain_relevance` | Most→["04"], compliance-relevant checks→["04","05"] |
| `entity_tags` | Signal metadata | Attach as `resource_tags` metadata field for agent scoping |

### Normalization Rules

**Severity Derivation** (Checkov does not emit severity natively; derive from check category):

Checkov check IDs encode the provider and category in their naming. Map as follows:

- Encryption checks (`CKV_AWS_19`, `CKV_AWS_3`, `CKV_AWS_95`, and similar SSE/KMS checks) → `severity: "high"`
- Access control / IAM checks (`CKV_AWS_111`, `CKV_AWS_40`, `CKV_K8S_155`) → `severity: "high"`
- Network exposure checks (`CKV_AWS_24`, `CKV_AWS_25`, `CKV_AWS_260`) → `severity: "high"`
- Kubernetes privilege / capability checks (`CKV_K8S_16`, `CKV_K8S_28`, `CKV_K8S_6`) → `severity: "high"`
- Logging and audit checks (`CKV_AWS_18`, `CKV_AWS_50`, `CKV_GCP_26`) → `severity: "medium"`
- Monitoring and alerting checks (`CKV_AWS_67`, `CKV_AWS_80`) → `severity: "medium"`
- Backup and lifecycle checks (`CKV_AWS_86`, `CKV_AWS_96`) → `severity: "medium"`
- Container best practice checks (`CKV_DOCKER_2`, `CKV_DOCKER_7`) → `severity: "medium"`
- Tagging / metadata checks (`CKV_AWS_6`, org-specific tagging policies) → `severity: "low"`
- Informational / hygiene checks (descriptions, comments, formatting) → `severity: "informational"`

When a check does not clearly fit a category above, cross-reference `bc_check_id` prefix against Bridgecrew category taxonomy or default to `severity: "medium"`.

**Confidence Estimation**:

IaC checks are deterministic — they match attribute presence or value against a static rule. There is no probabilistic component.
- Default → `confidence_estimate: "high"` for all Checkov signals
- Exception: Checks that evaluate computed/interpolated values in Terraform (`evaluations` field non-null) → `confidence_estimate: "medium"` because the value may differ at apply time from the plan-time placeholder

**Blast Radius Derivation**:

Derive from the resource type and scope encoded in the `resource` field:
- IAM policies, shared VPC/network resources, global S3 buckets, RDS cluster-level settings → `blast_radius: "widespread"` (misconfiguration affects all consumers of the shared resource)
- Individual EC2 instance, single Lambda function, single Pod/Deployment → `blast_radius: "localized"` (misconfiguration is contained to that resource)
- Security groups, CloudWatch log groups, shared tagging policies → `blast_radius: "moderate"` (affects resources that reference the shared construct)
- Kubernetes Namespace or ClusterRole level → `blast_radius: "widespread"`
- Kubernetes Pod or Deployment level → `blast_radius: "localized"`

**Domain Relevance Assignment**:
- Default for infrastructure checks → `domain_relevance: ["04"]` (Security domain)
- Encryption-at-rest and in-transit checks → `domain_relevance: ["04", "05"]` (encryption controls are compliance-mapped)
- Access logging and audit trail checks → `domain_relevance: ["04", "05"]` (logging is a compliance requirement)
- IAM least-privilege checks → `domain_relevance: ["04", "05"]` (access control is compliance-relevant)
- Public exposure / network ACL checks → `domain_relevance: ["04"]`
- Container HEALTHCHECK and operational hygiene → `domain_relevance: ["04"]`
- Tagging / cost allocation checks → `domain_relevance: ["04"]`

**Deduplication Strategy**:
- Same `check_id` on the same `resource` in the same `file_path` across multiple scan invocations → Single signal, do not duplicate
- Deduplication key: `{check_id}:{file_path}:{resource}`
- If the same logical resource appears in both a `.tf` file and a corresponding `terraform_plan` scan, prefer the plan-based signal (more accurate for computed values) and discard the static HCL signal

**Special Cases**:
- `parsing_errors` entries → Do not normalize as signals; emit a tool-level diagnostic event so agents know coverage is incomplete for the affected files
- `skipped_checks` entries → Do not normalize as signals; preserve the `suppress_comment` in an audit log for compliance review
- Multi-framework scans → Signals from different frameworks (e.g., both terraform and kubernetes) are pooled in the same signal set; `source_rule` prefix distinguishes them (CKV_AWS_* vs CKV_K8S_* vs CKV_DOCKER_*)
- Checks with `file_line_range: [1, N]` where N equals the total file length → Resource could not be pinpointed; set `file_path` to the file path only without resource suffix

## Limitations

### Cannot Detect

1. **Runtime Misconfiguration Drift**: Checkov evaluates IaC source files or plans. If infrastructure has been manually modified after deployment (configuration drift), those changes are invisible. A resource that passed all checks at plan time may be misconfigured in production.

2. **Secrets in Environment Variables at Runtime**: While Checkov can flag hardcoded secrets in IaC files, it cannot detect secrets injected at runtime via CI/CD environment variables, secret manager lookups, or `user_data` scripts that reference external values.

3. **Transitive Module Misconfiguration**: When Terraform modules are sourced from external registries (Terraform Registry, GitHub), Checkov requires `--download-external-modules` to analyze them. Without it, module contents are not evaluated and misconfigurations inside modules are silent.

4. **Computed / Dynamic Values**: Terraform resources with attribute values determined by data sources, locals, or `for_each` expressions may evaluate to placeholder values at static analysis time. The actual deployed value may differ — especially for conditional expressions and dynamic blocks.

5. **Application-Layer Security**: Checkov operates on infrastructure definitions. It cannot detect vulnerabilities in application code deployed onto the infrastructure — SQL injection, XSS, insecure API design, or misconfigured application-layer security controls are out of scope.

6. **Live Cloud State Validation**: Checkov does not connect to cloud provider APIs. It cannot verify whether an IaC resource accurately reflects what is deployed, nor can it check cloud-native settings that are not representable in IaC (e.g., service control policies applied at the AWS Organization level).

7. **Policy Compliance Gaps Between Frameworks**: A check that exists for Terraform may not have an equivalent for CloudFormation or ARM. Cross-framework coverage is not symmetric — infrastructure expressed in different frameworks may receive different check coverage for the same security concern.

### Known False Positives

1. **Terraformed Resources With Defaults Enforced Elsewhere**: Some organizations enforce encryption, tagging, or logging through AWS Service Control Policies, CloudFormation StackSets, or organization-level defaults. Checkov flags the IaC resource for not explicitly declaring these controls even though they are enforced at a higher layer.

2. **Dev/Test Environment Resources**: Checkov applies the same policy set to production and non-production IaC without environment context. Resources intentionally configured with relaxed security for development (e.g., publicly accessible test databases, open security groups for local testing) are flagged at the same severity as production equivalents.

3. **Legacy Resource Definitions Not Yet Migrated**: Large IaC repositories often contain older resource definitions written before specific check policies were introduced. These are flagged as violations even though the resource may be scheduled for migration or retirement, or may represent accepted technical debt with a remediation plan.

4. **Helm Chart Default Values**: Kubernetes Helm chart scans evaluate `values.yaml` defaults, which are frequently intentionally permissive (designed to be overridden by operators at install time). Checkov may flag default permissive values as violations even though the chart's documentation specifies that production deployments override them.

5. **Checkov Version Sensitivity**: Policy definitions and evaluation logic change between Checkov releases. A check that passes on one version may fail on a newer version due to expanded scope or stricter evaluation, producing apparent regressions that are artifacts of the tool update rather than genuine new misconfigurations.

### Known False Negatives

1. **Inline Policy Documents as JSON Strings**: Terraform `aws_iam_policy_document` data sources written as raw JSON heredoc strings instead of using the structured `aws_iam_policy_document` Terraform resource are not parsed by IAM-specific checks. The IAM policy content is invisible to Checkov and goes unchecked.

2. **Kubernetes Resources Created by Helm at Runtime**: Helm charts that generate Kubernetes resources dynamically via templating (`{{ if }}`, `{{ range }}`) may produce resource definitions not representable in static YAML. Checkov evaluates the template source, not the rendered output, and may miss security issues that only appear in specific rendering contexts.

3. **Terraform Modules From Private Registries Without Download**: When `--download-external-modules` is not set (the default for performance and reproducibility), all resources defined inside external modules are skipped. Modules from private registries are always skipped regardless of the flag.

4. **CloudFormation Macros and Custom Resources**: CloudFormation templates using macros (`AWS::CloudFormation::Transform`, `AWS::Include`) or custom resources (`AWS::CloudFormation::CustomResource`) have their logic resolved only at deploy time. Checkov evaluates the pre-transform template and cannot check security properties that are determined by macro expansion.

5. **Misconfiguration Requiring Cross-Resource Context**: Some misconfigurations only exist when two resources interact incorrectly — for example, an S3 bucket policy that grants access to an overly permissive IAM role, or a security group that allows wide ingress combined with an EC2 instance that has a public IP. Checkov evaluates resources in isolation and cannot detect cross-resource relationship vulnerabilities.

6. **ARM Template Nested Deployments**: Azure ARM templates using `Microsoft.Resources/deployments` (nested or linked deployments) may reference external template URIs or define child resources with scoped permissions. Checkov does not follow external URI references and may miss misconfigurations in linked templates.
