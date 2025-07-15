// acme-prod
resource "aws_organizations_account" "acme_prod" {
  name                       = "acme-prod"
  email                      = "anton+acme-prod@antonbabenko.com"
  iam_user_access_to_billing = "ALLOW"
  role_name                  = "admin"
}

output "acme_prod_organizations_account_id" {
  description = "The AWS account id"
  value       = aws_organizations_account.acme_prod.id
}

output "acme_prod_organizations_account_arn" {
  description = "The ARN for this account"
  value       = aws_organizations_account.acme_prod.arn
}
