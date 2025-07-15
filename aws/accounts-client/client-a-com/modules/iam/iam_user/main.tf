module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  for_each = toset(["catherine", "qatherine", "katherine"])
  name = "${each.key}"
  create_iam_access_key = false
  create_iam_user_login_profile = true
  force_destroy = true
  pgp_key = "keybase:${each.key}"
  password_reset_required = false
}