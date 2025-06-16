variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_region" {
  default = "ap-northeast-1"
}

variable "domain" {}

variable "backend_image" {}
variable "frontend_bucket" {}
variable "subnets" {
  type = list(string)
}
