terraform {
  backend "s3" {
    bucket   = "vmo-amperfii-terraform-state"
    key      = "ec2/bastion_host.tfstate"
    region   = "ap-northeast-1"
  }
}