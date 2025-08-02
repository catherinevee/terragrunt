module "iam_group_complete" {
  source = "../../modules/iam-group-with-assumable-roles-policy"

  name = "production-admins"

  assumable_roles = ["arn:aws:iam::01985728471:role/admin"]

  group_users = [
    module.iam_user_username.iam_username[*]
  ]
}