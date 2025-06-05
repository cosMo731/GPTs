output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "local_container_id" {
  value = module.docker_local.container_id
}

output "s3_bucket_id" {
  value = module.s3_code.bucket_id
}

output "s3_object_key" {
  value = module.s3_code.object_key
}
