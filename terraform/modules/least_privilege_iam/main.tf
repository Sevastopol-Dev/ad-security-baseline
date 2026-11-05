variable "role_name" {
  description = "Name of the secure IAM role to provision."
  type        = string
}

variable "saml_provider_arn" {
  description = "ARN of the corporate SAML identity provider in IAM."
  type        = string
}

variable "allowed_ad_group_sids" {
  description = "List of authorized AD Group SIDs permitted to assume this role."
  type        = list(string)
}

variable "ad_domain_name" {
  type        = string
  description = "Fully qualified domain name (FQDN) of the target Directory domain"
  default     = "corp.local" # Placeholder for personal lab
}

variable "require_mfa_for_federation" {
  type        = bool
  description = "Enforce step-up Multi-Factor Authentication for all SAML/OIDC federated sessions."
  default     = true
}

data "aws_iam_policy_document" "federated_trust" {
  statement {
    sid     = "EnforceADGroupAndMFABoundary"
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.saml_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "saml:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = [tostring(var.require_mfa_for_federation)]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "saml:attribute:http://schemas.xmlsoap.org/claims/Group"
      values   = var.allowed_ad_group_sids
    }
  }
}

resource "aws_iam_role" "secure_federated_role" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.federated_trust.json
  max_session_duration = 3600

  tags = {
    Environment   = "Production"
    ADDomain      = var.ad_domain_name # <--- Wire it here
    SecurityOwner = "Identity-Engineering"
  }
}

output "role_arn" {
  description = "The ARN of the secure, guardrail-protected IAM role."
  value       = aws_iam_role.secure_federated_role.arn
}
