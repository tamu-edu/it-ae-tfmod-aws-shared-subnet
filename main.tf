locals {
  default_availability_zones = {
    us-east-1 = [
        "us-east-1a",
        "us-east-1b",
    ],
    us-east-2 = [
        "us-east-2a",
        "us-east-2b",
    ],
  }
  default_region = "us-east-1"
  availability_zones = [
        "us-east-1a",
        "us-east-1b",
  ]
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    alias = "us-east-1"
    region = "us-east-1"
}

provider "aws" {
    alias = "us-east-2"
    region = "us-east-2"
}
