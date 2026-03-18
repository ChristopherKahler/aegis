---
id: trivy
name: Trivy
type: vulnerability_scan
domains_fed: ["04", "05"]
install_required: true
install_command: "See Installation section — apt, brew, script, or Docker"
---

## Purpose

Comprehensive vulnerability scanner covering OS packages, language-specific dependencies, container images, IaC misconfigurations, and embedded secrets. Primary signal source for dependency CVEs and compliance-relevant vulnerabilities. Feeds Security (04) and Compliance (05) domains.

Trivy scans multiple targets: filesystem (lock files, manifests), container images, git repositories, and IaC configurations (Terraform, CloudFormation, Kubernetes). For AEGIS, filesystem scanning is the primary mode (analyzing the codebase's dependency tree).

Signals are NOT findings. Trivy produces evidence that agents interpret.

## Configuration

Trivy supports configuration via `trivy.yaml` file and command-line flags:

**Configuration File** (`trivy.yaml`):
```yaml
severity: CRITICAL,HIGH,MEDIUM
cache:
  dir: ~/.cache/trivy
db:
  repository: ghcr.io/aquasecurity/trivy-db
  skip-update: false
timeout: 5m0s
```

**Key Configuration Options**:
- **Severity Filtering**: `--severity CRITICAL,HIGH,MEDIUM` excludes LOW/UNKNOWN for focused scanning
- **Cache Settings**: Database cache location and retention policy
- **DB Update Policy**: Automatic vulnerability database updates (default) or manual control
- **Scan Type Selection**: `fs` (filesystem/dependencies), `image` (containers), `config` (IaC)
- **Offline Mode**: `--skip-db-update` for air-gapped environments

**Ignore File** (`.trivyignore`):
```
# Accepted risks - include justification
CVE-2024-12345  # False positive - vendored with backported patch
CVE-2024-67890  # Risk accepted - no exploitable code path in our usage
```

**Environment Variables**:
- `TRIVY_CACHE_DIR`: Override default cache location
- `TRIVY_DB_REPOSITORY`: Custom vulnerability database mirror
- `TRIVY_TIMEOUT`: Scan timeout duration

## Execution

### Installation Options

**Platform-Agnostic Methods**:

1. **Docker** (recommended for CI/CD and consistency):
   ```bash
   docker pull aquasec/trivy:latest
   ```

2. **Installation Script** (Linux/macOS):
   ```bash
   curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
   ```

3. **apt-get** (Debian/Ubuntu):
   ```bash
   sudo apt-get install wget gnupg
   wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
   echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list
   sudo apt-get update
   sudo apt-get install trivy
   ```

4. **Homebrew** (macOS):
   ```bash
   brew install trivy
   ```

5. **Binary Download** (all platforms):
   Download from [GitHub Releases](https://github.com/aquasecurity/trivy/releases)

### Primary Execution Commands

**Filesystem Scanning** (AEGIS primary use case):
```bash
trivy fs --format json --output {output_dir}/trivy-results.json --severity CRITICAL,HIGH,MEDIUM {target_path}
```

**Docker Variant**:
```bash
docker run --rm -v {target_path}:/target aquasec/trivy:latest fs --format json --output /target/.aegis/signals/trivy-results.json --severity CRITICAL,HIGH,MEDIUM /target
```

**Container Image Scanning**:
```bash
trivy image --format json --output {output_dir}/trivy-image-results.json {image_name}
```

**IaC Configuration Scanning**:
```bash
trivy config --format json --output {output_dir}/trivy-iac-results.json {target_path}
```

### Execution Parameters

| Parameter | Purpose | Values | Default |
|-----------|---------|--------|---------|
| `--format` | Output format | json, table, sarif, cyclonedx | table |
| `--output` | Output file path | file path | stdout |
| `--severity` | Filter by severity | CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN | All |
| `--vuln-type` | Vulnerability types | os, library | os,library |
| `--skip-db-update` | Skip DB update | boolean | false |
| `--timeout` | Scan timeout | duration (e.g., 5m) | 5m0s |
| `--ignore-unfixed` | Skip unfixed vulns | boolean | false |
| `--exit-code` | Exit code on findings | integer | 0 |
| `--scanners` | Scanners to enable | vuln, misconfig, secret, license | vuln |

### Runtime Characteristics

- **First Run**: 2-5 minutes (includes ~500MB vulnerability database download)
- **Subsequent Runs**: 1-2 minutes (database cached)
- **Database Updates**: Daily automatic updates (configurable)
- **Resource Usage**: Low CPU, moderate disk I/O during initial scan
- **Network Requirements**: Initial DB download only (offline mode available)

## Output Format

Trivy produces structured JSON output with nested results by target:

```json
{
  "SchemaVersion": 2,
  "CreatedAt": "2026-02-15T10:30:45.123456789Z",
  "ArtifactName": "/home/user/project",
  "ArtifactType": "filesystem",
  "Metadata": {
    "ImageConfig": {}
  },
  "Results": [
    {
      "Target": "package-lock.json",
      "Class": "lang-pkgs",
      "Type": "npm",
      "Vulnerabilities": [
        {
          "VulnerabilityID": "CVE-2024-45590",
          "PkgName": "express",
          "PkgPath": "node_modules/express/package.json",
          "PkgIdentifier": {
            "PURL": "pkg:npm/express@4.17.1"
          },
          "InstalledVersion": "4.17.1",
          "FixedVersion": "4.19.2",
          "Status": "fixed",
          "Layer": {},
          "SeveritySource": "nvd",
          "PrimaryURL": "https://avd.aquasec.com/nvd/cve-2024-45590",
          "DataSource": {
            "ID": "npm-advisory-db",
            "Name": "npm Advisory Database",
            "URL": "https://github.com/advisories?query=type%3Areviewed+ecosystem%3Anpm"
          },
          "Title": "Express.js path traversal vulnerability in static file serving",
          "Description": "Express.js static file serving middleware allows path traversal attacks via specially crafted requests with encoded path separators, enabling unauthorized access to files outside the intended directory.",
          "Severity": "HIGH",
          "CweIDs": [
            "CWE-22"
          ],
          "VendorSeverity": {
            "nvd": 3,
            "redhat": 2
          },
          "CVSS": {
            "nvd": {
              "V3Vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N",
              "V3Score": 7.5
            }
          },
          "References": [
            "https://github.com/expressjs/express/security/advisories/GHSA-qw6h-vgh9-j6wx",
            "https://nvd.nist.gov/vuln/detail/CVE-2024-45590"
          ],
          "PublishedDate": "2024-09-10T15:15:00Z",
          "LastModifiedDate": "2024-09-12T18:31:00Z"
        },
        {
          "VulnerabilityID": "CVE-2024-43796",
          "PkgName": "axios",
          "PkgPath": "node_modules/axios/package.json",
          "PkgIdentifier": {
            "PURL": "pkg:npm/axios@0.21.1"
          },
          "InstalledVersion": "0.21.1",
          "FixedVersion": "1.7.4",
          "Status": "fixed",
          "Layer": {},
          "SeveritySource": "npm-advisory-db",
          "PrimaryURL": "https://github.com/advisories/GHSA-8hc4-vh64-cxmj",
          "DataSource": {
            "ID": "npm-advisory-db",
            "Name": "npm Advisory Database",
            "URL": "https://github.com/advisories?query=type%3Areviewed+ecosystem%3Anpm"
          },
          "Title": "Server-Side Request Forgery in axios",
          "Description": "Axios library allows Server-Side Request Forgery (SSRF) attacks via URL parsing inconsistencies when handling user-controlled URLs with CRLF injection, potentially enabling attackers to bypass allow-lists and access internal resources.",
          "Severity": "CRITICAL",
          "CweIDs": [
            "CWE-918"
          ],
          "VendorSeverity": {
            "npm-advisory-db": 4,
            "nvd": 4
          },
          "CVSS": {
            "nvd": {
              "V3Vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N",
              "V3Score": 9.3
            }
          },
          "References": [
            "https://github.com/axios/axios/issues/6463",
            "https://github.com/axios/axios/pull/6539",
            "https://nvd.nist.gov/vuln/detail/CVE-2024-43796"
          ],
          "PublishedDate": "2024-08-12T13:38:00Z",
          "LastModifiedDate": "2024-08-16T17:43:00Z"
        },
        {
          "VulnerabilityID": "CVE-2023-26136",
          "PkgName": "tough-cookie",
          "PkgPath": "node_modules/tough-cookie/package.json",
          "PkgIdentifier": {
            "PURL": "pkg:npm/tough-cookie@2.5.0"
          },
          "InstalledVersion": "2.5.0",
          "FixedVersion": "4.1.3",
          "Status": "fixed",
          "Layer": {},
          "SeveritySource": "nvd",
          "PrimaryURL": "https://avd.aquasec.com/nvd/cve-2023-26136",
          "DataSource": {
            "ID": "npm-advisory-db",
            "Name": "npm Advisory Database",
            "URL": "https://github.com/advisories?query=type%3Areviewed+ecosystem%3Anpm"
          },
          "Title": "Prototype pollution in tough-cookie",
          "Description": "The tough-cookie package before 4.1.3 for Node.js allows prototype pollution via cookie values, which could enable arbitrary property injection and potential denial of service.",
          "Severity": "MEDIUM",
          "CweIDs": [
            "CWE-1321"
          ],
          "VendorSeverity": {
            "nvd": 2,
            "npm-advisory-db": 2
          },
          "CVSS": {
            "nvd": {
              "V3Vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:N/I:L/A:L",
              "V3Score": 4.8
            }
          },
          "References": [
            "https://github.com/salesforce/tough-cookie/issues/282",
            "https://github.com/salesforce/tough-cookie/commit/12d474791bb856004e858fdb1c47b7608d09cf6e",
            "https://nvd.nist.gov/vuln/detail/CVE-2023-26136"
          ],
          "PublishedDate": "2023-07-01T06:15:00Z",
          "LastModifiedDate": "2023-07-12T13:18:00Z"
        }
      ]
    },
    {
      "Target": "requirements.txt",
      "Class": "lang-pkgs",
      "Type": "pip",
      "Vulnerabilities": [
        {
          "VulnerabilityID": "CVE-2024-35195",
          "PkgName": "requests",
          "PkgPath": "",
          "PkgIdentifier": {
            "PURL": "pkg:pypi/requests@2.28.0"
          },
          "InstalledVersion": "2.28.0",
          "FixedVersion": "2.32.0",
          "Status": "fixed",
          "Layer": {},
          "SeveritySource": "nvd",
          "PrimaryURL": "https://avd.aquasec.com/nvd/cve-2024-35195",
          "DataSource": {
            "ID": "pip-security-db",
            "Name": "pip Security Database",
            "URL": "https://github.com/pypa/advisory-database"
          },
          "Title": "Proxy-Authorization header disclosure in requests library",
          "Description": "The requests library for Python does not strip the Proxy-Authorization header when handling cross-origin redirects, potentially leaking proxy credentials to third-party servers.",
          "Severity": "MEDIUM",
          "CweIDs": [
            "CWE-200"
          ],
          "VendorSeverity": {
            "nvd": 2,
            "redhat": 2
          },
          "CVSS": {
            "nvd": {
              "V3Vector": "CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N",
              "V3Score": 5.9
            }
          },
          "References": [
            "https://github.com/psf/requests/security/advisories/GHSA-9wx4-h78v-vm56",
            "https://github.com/psf/requests/pull/6655",
            "https://nvd.nist.gov/vuln/detail/CVE-2024-35195"
          ],
          "PublishedDate": "2024-05-20T21:15:00Z",
          "LastModifiedDate": "2024-05-28T18:32:00Z"
        }
      ]
    }
  ]
}
```

**Key Output Fields**:
- `SchemaVersion`: Trivy output schema version
- `ArtifactName`: Scanned target path/name
- `ArtifactType`: Type of artifact (filesystem, container, repository)
- `Results[]`: Array of result objects per target file
  - `Target`: Specific file scanned (e.g., package-lock.json, requirements.txt)
  - `Class`: Classification (lang-pkgs, os-pkgs, config)
  - `Type`: Package manager type (npm, pip, gem, maven, etc.)
  - `Vulnerabilities[]`: Array of vulnerability objects
    - `VulnerabilityID`: CVE identifier
    - `PkgName`: Affected package name
    - `InstalledVersion`: Currently installed version
    - `FixedVersion`: Version containing fix (if available)
    - `Severity`: CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN
    - `CVSS`: Common Vulnerability Scoring System scores
    - `References[]`: Links to advisories and patches

## Normalization

Trivy raw output requires normalization to AEGIS signal format:

| Trivy Field | AEGIS Signal Field | Transformation Logic |
|-------------|-------------------|----------------------|
| `VulnerabilityID` | `source_rule` | Direct mapping (e.g., CVE-2024-45590) |
| Auto-generated | `signal_id` | Pattern: `S-TRV-{NNN}` (sequential numbering) |
| Fixed value | `source_tool` | Always "trivy" |
| `Target` + `PkgName` | `file_path` | Combine: `{Target}:{PkgName}` (e.g., "package-lock.json:express") |
| `Description` + `InstalledVersion` + `FixedVersion` | `context` | Enriched: "{Description} Found: {InstalledVersion}, Fixed: {FixedVersion}" |
| `Severity` | `severity` | Map: CRITICAL→critical, HIGH→high, MEDIUM→medium, LOW→low, UNKNOWN→informational |
| `CVSS.nvd.V3Score` | `confidence_estimate` | Score-based: ≥9.0→high, ≥7.0→medium, <7.0→low, missing→medium |
| Derived from package | `blast_radius` | Core dependency→widespread, dev dependency→localized, transitive→moderate |
| Derived from CVE type | `domain_relevance` | Most CVEs→["04"], data/crypto CVEs→["04","05"] |
| `FixedVersion` presence | Signal enrichment | Available→actionable, null→informational flag |

### Normalization Rules

**Severity Mapping**:
- CRITICAL → `severity: "critical"`
- HIGH → `severity: "high"`
- MEDIUM → `severity: "medium"`
- LOW → `severity: "low"`
- UNKNOWN → `severity: "informational"` (requires manual triage)

**Confidence Estimation**:
- CVSS ≥9.0 → `confidence_estimate: "high"`
- CVSS ≥7.0 → `confidence_estimate: "medium"`
- CVSS <7.0 → `confidence_estimate: "low"`
- CVSS missing → `confidence_estimate: "medium"` (default for known CVEs)

**Blast Radius Derivation**:
- Core/production dependency → `blast_radius: "widespread"`
- Dev/test dependency → `blast_radius: "localized"`
- Transitive dependency → `blast_radius: "moderate"`
- Determine via dependency tree analysis (production vs devDependencies)

**Domain Relevance Assignment**:
- Default → `domain_relevance: ["04"]` (Security domain)
- Data handling CVEs (CWE-200, CWE-502) → `domain_relevance: ["04", "05"]`
- Encryption/auth CVEs (CWE-295, CWE-327) → `domain_relevance: ["04", "05"]`
- Compliance-relevant CVEs → `domain_relevance: ["04", "05"]` (Compliance domain)

**Deduplication Strategy**:
- Same CVE in multiple lock files → Single signal with aggregated locations
- Key: `{VulnerabilityID}:{PkgName}:{InstalledVersion}`
- Merge `file_path` entries: `["package-lock.json:express", "npm-shrinkwrap.json:express"]`

**Special Cases**:
- UNKNOWN severity → Flag for manual triage, do NOT auto-dismiss
- Missing FixedVersion → Mark as "unfixed", lower priority but track for future remediation
- Zero CVSS score → Use vendor severity as fallback

## Limitations

### Cannot Detect

1. **Custom/Proprietary Vulnerabilities**: Only identifies vulnerabilities present in public databases (NVD, GitHub Advisory, vendor advisories). Organization-specific or proprietary vulnerabilities not disclosed publicly will not be detected.

2. **Business Logic Vulnerabilities**: Cannot identify application-specific logic flaws, authentication bypasses, or authorization issues that depend on code implementation rather than dependency versions.

3. **Zero-Day Exploits**: Undisclosed vulnerabilities without assigned CVE identifiers are invisible to Trivy until they are publicly reported and added to vulnerability databases.

4. **Vendored/Copied Code**: Dependencies copied directly into the codebase (not managed by package managers) are not scanned. Trivy relies on package manifests and lock files to identify components.

5. **Runtime Configuration Vulnerabilities**: Environment-dependent misconfigurations, insecure defaults, or vulnerabilities that only manifest with specific runtime parameters are outside Trivy's detection scope.

6. **Source Code Vulnerabilities**: Does not perform static code analysis to identify vulnerabilities in custom application code (SQL injection, XSS, etc.). Trivy focuses on known vulnerabilities in third-party components.

### False Positives

1. **Vendored Dependencies with Backported Patches**: OS packages and system libraries often backport security patches to older versions without changing version numbers. Trivy may flag these as vulnerable when they are actually patched.

2. **Unused Dependencies**: Dependencies listed in manifests but not actually imported or executed in the application are flagged at the same severity level as actively used components, leading to over-reporting.

3. **Platform-Specific CVEs**: Vulnerabilities that only affect specific operating systems, architectures, or runtime configurations may be reported even when the codebase runs on unaffected platforms.

4. **Test-Only Dependencies**: Development and test dependencies are flagged at production-level severity even though they never execute in production environments, inflating risk assessments.

5. **Configuration-Dependent Vulnerabilities**: CVEs that require specific configuration flags or usage patterns to be exploitable are reported regardless of whether the vulnerable code path is reachable.

### False Negatives

1. **Transitive Dependencies Not in Lock Files**: Indirect dependencies not captured in lock files (due to incomplete dependency resolution or manual installations) remain undetected.

2. **Script-Installed Dependencies**: Packages installed via shell scripts, manual downloads, or custom build processes bypass package manager tracking and are not scanned.

3. **Custom Forks of Open Source Packages**: Modified versions of open source libraries maintained internally may contain unpatched vulnerabilities that differ from the upstream vulnerability status.

4. **Recently Disclosed CVEs**: Vulnerability database updates occur daily, but there is a lag between public disclosure and database inclusion. Very recent CVEs may be missed until the next database sync.

5. **Compiled Binaries and Embedded Code**: Pre-compiled binaries, embedded third-party SDKs, and closed-source components cannot be analyzed for vulnerabilities without manifest metadata.

6. **Vulnerabilities in Build Tools**: Security issues in build-time dependencies (compilers, bundlers, CI/CD tools) that don't appear in production manifests are not detected during codebase scanning.
