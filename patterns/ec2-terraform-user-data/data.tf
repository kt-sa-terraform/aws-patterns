data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vmo-amperfii-terraform-state"
    key    = "vpc/vpc.tfstate"
    region   = "ap-northeast-1"
  }
}

data "aws_ssm_parameter" "user_database" {
  name = "/terraform/variables/database_user"
}