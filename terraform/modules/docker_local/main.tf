variable "image_tag" {
  type = string
}

variable "docker_host" {
  type = string
}

variable "docker_registry" {
  type = string
}

variable "docker_username" {
  type = string
}

variable "docker_password" {
  type = string
  sensitive = true
}

provider "docker" {
  alias  = "remote"
  host   = var.docker_host
  registry_auth {
    address  = var.docker_registry
    username = var.docker_username
    password = var.docker_password
  }
}

resource "docker_image" "app" {
  name          = "${var.docker_registry}/app:${var.image_tag}"
  keep_locally  = false
  provider      = docker.remote
}

resource "docker_container" "app" {
  name  = "app-${var.image_tag}"
  image = docker_image.app.name
  provider = docker.remote
}

output "container_id" {
  value = docker_container.app.id
}
