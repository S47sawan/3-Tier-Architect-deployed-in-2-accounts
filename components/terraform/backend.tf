
terraform {
  backend "s3" {
    bucket = "terraform-backend-state"
    key    = "terraform-backend-state/terraform.tfstate"
    region = "eu-west-2"
  }
}