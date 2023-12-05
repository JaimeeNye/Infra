terraform {
  backend "s3" {
    bucket         = "infra-terraform-states"
    key            = "infra/bootstrap.tf"
    region         = "eu-west-3"
    dynamodb_table = "infra-terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}
