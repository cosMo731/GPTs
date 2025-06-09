terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-terraform-lock"
  }
}
