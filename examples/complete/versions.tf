terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.42.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.70.0"
    }
  }
}
