terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/waf?ref=main"
}

inputs = {
  name = "client-a-waf"
  scope = "REGIONAL"
  default_action = "allow"
  rules = [
    {
      name     = "AWS-AWSManagedRulesCommonRuleSet"
      priority = 1
      override_action = "none"
      statement_managed_rule_group = {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
  ]
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "Security"
    Owner       = "Zofia Zatanna"
  }
}
