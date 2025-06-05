module "network" {
  source = "./modules/network"
  prefix = var.prefix
  region = var.region
}

module "ecr" {
  source = "./modules/ecr"
  prefix = var.prefix
}

module "ecs" {
  source      = "./modules/ecs"
  prefix      = var.prefix
  image_tag   = var.image_tag
  ecr_repo    = module.ecr.repository_url
  subnet_ids  = module.network.subnet_ids
  vpc_id      = module.network.vpc_id
  security_group_id = module.network.security_group_id
  region      = var.region
}

module "docker_local" {
  source         = "./modules/docker_local"
  image_tag      = var.image_tag
  docker_host    = var.docker_host
  docker_registry = var.docker_registry
  docker_username = var.docker_username
  docker_password = var.docker_password
}

module "s3_code" {
  source              = "./modules/s3_code"
  bucket_name         = var.source_code_bucket
  source_code_archive = var.source_code_archive
}
