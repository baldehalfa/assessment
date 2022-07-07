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
  access_key = "AKIAY2B3EA3DPIFFY3M6"
  secret_key = "Qi+iJ/e9JA13AMBfH+s3TjsPXw+c+9qorw7fC+fC"
  region     = "ap-southeast-1"
}