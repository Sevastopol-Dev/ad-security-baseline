
# AD & Cloud Security Baseline (`ad-cloud-security-baseline`)

An enterprise-grade, zero-dependency hybrid security baseline establishing cryptographic trust boundaries between Active Directory and AWS. This repository enforces least-privilege IAM federation, automated IaC static analysis, and native Active Directory security hardening without external RSAT dependencies.

---

## Architecture Overview


                     ┌─────────────────────────────────────────┐
                     │          Active Directory Domain        │
                     │  - Zero-Dependency Audit ([adsisearcher])│
                     │  - Strip Unconstrained Delegation       │
                     └────────────────────┬────────────────────┘
                                          │
                                    SAML 2.0 / OIDC
                                  Identity Federation
                                          │
                                          ▼
                     ┌─────────────────────────────────────────┐
                     │         AWS STS Trust Boundary          │
                     │  - MFA Condition Assertion Enforcement │
                     │  - Least-Privilege Role Policies       │
                     └────────────────────┬────────────────────┘
                                          │
                                          ▼
                     ┌─────────────────────────────────────────┐
                     │        CI/CD Security Guardrails        │
                     │  - TFlint Syntax & Version Checking    │
                     │  - Checkov IaC Security Analysis        │
                     └─────────────────────────────────────────┘

```

---

## Key Features

* **Zero-Dependency AD Hardening**: `HardenActiveDirectory.ps1` utilizes native `.NET` LDAP interfaces (`[adsisearcher]`) to audit and strip unconstrained delegation flags without requiring Remote Server Administration Tools (RSAT).
* **Cryptographic Trust Boundaries**: Terraform modules enforce strict MFA condition checks (`aws:MultiFactorAuthPresent`) within AWS STS trust policies during identity federation.
* **IaC Security Hygiene**: Strict variable validation, pin-versioning in `versions.tf`, and continuous security scanning via TFlint and Checkov integrated directly into GitHub Actions workflows.

---

## Repository Structure

```text
├── .github/
│   └── workflows/
│       └── security-lint.yml           # Automated TFlint & Checkov CI/CD checks
├── README.md                           # Architecture and baseline documentation
├── scripts/
│   └── HardenActiveDirectory.ps1       # Native LDAP audit & remediation script
└── terraform/
    ├── main.tf                         # Root module orchestration & provider config
    ├── variables.tf                    # Domain and federation parameters
    └── modules/
        └── least_privilege_iam/        # Federated IAM role trust boundary module
            ├── main.tf
            └── versions.tf

```

---

## Getting Started

### 1. Prerequisites

* **Terraform**: `>= 1.5.0`
* **TFlint**: `>= 0.47.0`
* **Checkov**: `>= 3.0.0`
* **PowerShell**: `5.1+` or `PowerShell Core` (Domain-joined execution environment)

### 2. Running Local Active Directory Audit

Audit unconstrained delegation without making changes:

```powershell
.\scripts\HardenActiveDirectory.ps1 -DomainController "dc01.domain.local"

```

Remediate detected accounts using standard `-WhatIf` evaluation:

```powershell
.\scripts\HardenActiveDirectory.ps1 -DomainController "dc01.domain.local" -Remediate -WhatIf

```

### 3. Validating Terraform Configurations

Initialize and execute static security analysis locally:

```bash
cd terraform/
terraform init
tflint --recursive
checkov -d .

```

---

## License

Internal Enterprise Security Baseline — All Rights Reserved.

```
