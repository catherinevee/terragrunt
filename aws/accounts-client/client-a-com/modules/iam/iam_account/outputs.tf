output "iam_account_identity_id" {
  description = "Name of the IAM account"
  value       = module.iam_account.caller_identity_account_id
}

output "iam_account_user_id" {
  description = "Name of the IAM account"
  value       = module.iam_account.caller_identity_user_id
}