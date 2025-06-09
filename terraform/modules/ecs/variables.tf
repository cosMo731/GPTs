variable "prefix" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "ecr_repo" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "region" {
  type = string
}
