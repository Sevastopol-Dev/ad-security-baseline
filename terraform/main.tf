terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ad-cloud-security-baseline"
      Environment = var.environment
      ADDomain    = var.ad_domain_name
      ManagedBy   = "Terraform"
    }
  }
}

module "identity_trust_boundary" {
  source = "./modules/least_privilege_iam"

  role_name                  = "EnterpriseFederatedSecurityRole-${var.environment}"
  saml_provider_arn          = "arn:aws:iam::123456789012:saml-provider/CorporateIdentityBridge"
  allowed_ad_group_sids      = var.allowed_ad_group_sids
  require_mfa_for_federation = var.require_mfa_for_federation
}

output "enforced_federated_role_arn" {
  description = "The authoritative ARN of the secured identity boundary role."
  value       = module.identity_trust_boundary.role_arn
}