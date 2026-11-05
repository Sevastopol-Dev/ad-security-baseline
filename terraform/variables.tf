variable "environment" {
  type        = string
  description = "Target deployment environment (must be 'dev', 'staging', 'prod'."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "GUARDRAIL VILOATION: Environment must be 'dev', 'staging', 'prod'."
  }
}

variable "aws_region" {
  type        = string
  description = "Target AWS region for Directory Service and IAM deployments"
  default     = "us-east-1"
}

variable "ad_domain_name" {
  type        = string
  description = "Fully qualified domain name (FQDN) of the target Directory domain"
  default     = "corp.local" # Placeholder for personal lab

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\\.[azA-Z]{2,}$", var.ad_domain_name))
    error_message = "GUARDRAIL VIOLATION: must provide a valid domain FQDN (e.g., corp.local)"
  }

}

variable "allowed_ad_group_sids" {
  type        = list(string)
  description = "List of explicitly authorized AD Group SIDS"

  validation {
    condition     = length(var.allowed_ad_group_sids) > 0
    error_message = "GUARDRAIL VILOATION: At least one explicit AD Group SID must be defined to restrict role assumption."
  }
}

variable "require_mfa_for_federation" {
  type        = bool
  description = "Enforce step-up Multi-Factor Authentication for all SAML/OIDC federated sessions."
  default     = true

  validation {
    condition     = var.require_mfa_for_federation == true
    error_message = "GUARDRAIL VILOATION: MFA enforcement cannot be set to false in enterprise baseline policies."

  }
}

