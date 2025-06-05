variable "prefix" {
  description = "Project prefix"
  type        = string
  default     = "example"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "latest"
}

variable "docker_host" {
  description = "Docker remote API host"
  type        = string
  default     = "tcp://192.168.0.1:2375"
}

variable "docker_registry" {
  description = "Docker registry address"
  type        = string
  default     = "registry.example.com"
}

variable "docker_username" {
  description = "Docker registry username"
  type        = string
  default     = "user"
}

variable "docker_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
  default     = "changeme"
}
