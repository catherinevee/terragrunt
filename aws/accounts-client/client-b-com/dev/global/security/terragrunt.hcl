# ==============================================================================
# Global Security Module Configuration for Client B - Development Environment
# ==============================================================================

include "root" {
  path = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  expose = true
}

include "account" {
  path = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  expose = true
}

# Terraform source with version pinning
terraform {
  source = "git::https://github.com/catherinevee/security.git//?ref=v1.0.0"
}

inputs = {
  # Environment and account configuration
  environment = include.account.locals.environment
  account_id  = include.account.locals.account_id
  client_name = include.account.locals.client_name
  project     = "Global Security - Development"
  
  # Global security configuration
  security_config = {
    # Organization and naming
    organization_name = "ClientB"
    environment_name  = "development"
    project_name      = "Global Security"
    
    # Global security settings
    enable_global_security = true
    enable_compliance_frameworks = true
    enable_audit_logging = true
    enable_threat_detection = true
    
    # Compliance frameworks
    compliance_frameworks = ["GDPR", "ISO27001", "SOC2"]
    
    # Data residency
    data_residency = "EU"
    
    # Tags for all security resources
    tags = {
      Environment = "Development"
      Project     = "Client B Infrastructure"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
      DataClass   = "Internal"
      SecurityLevel = "High"
    }
  }
} 