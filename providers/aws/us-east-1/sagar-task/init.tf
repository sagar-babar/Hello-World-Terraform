terraform {
  backend "s3" {
    bucket = "sagar-terraform"
    key    = "us-east-1/global/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    profile = "sagar-devops"
  }
}
