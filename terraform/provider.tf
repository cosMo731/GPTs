terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.20"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "docker" {
  host = var.docker_host
  registry_auth {
    address  = var.docker_registry
    username = var.docker_username
    password = var.docker_password
  }
}
