module "iam_account" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-account"

  account_alias = var.account_alias

  minimum_password_length = 37
  require_numbers         = false
}