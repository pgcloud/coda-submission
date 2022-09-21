terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.30.0" # Pin to the version used when creating this project
    }
  }
}

provider "aws" {
  # Configuration options
  # We are not configuring the keys here as they will be injected from the env vars
  # Shared configuration files, IAM roles, and using STS to assume roles can all be done
  # per instructions here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  #
  # However, as this appears out of scope for this project, we will use the basic env var injection method
  region = var.aws_region
}