terraform {
  source = "git::https://github.com/catherinevee/terraform-aws-ec2.git//modules/iam?ref=main"
}

inputs = {
  name = "client-a-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
  tags = {
    Environment = "dev"
    Project     = "client-a-com"
    Department  = "IT"
    Owner       = "Zofia Zatanna"
  }
}

outputs = {
  role_arn = {
    value = module.iam.role_arn
    description = "The ARN of the IAM role."
  }
}
