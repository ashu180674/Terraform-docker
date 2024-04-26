terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "terraform-backend-test12"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
  }
}
