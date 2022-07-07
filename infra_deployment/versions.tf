terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configuring the AWS Provider
provider "aws" {
  # Key in your access key and secret key
  access_key = ""
  secret_key = ""
  region     = "ap-southeast-1"
}