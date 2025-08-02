remote_state {
  backend = "s3"
  config = {
    bucket         = "client-a-com-tfstate"
    key            = "eu-west-1/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "client-a-com-tfstate-lock"
    encrypt        = true
  }
}
