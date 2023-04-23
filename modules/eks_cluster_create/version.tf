
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.18.0"
    }
  }
}

