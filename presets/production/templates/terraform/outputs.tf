# =============================================================================
# Outputs — Useful values after terraform apply
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "load_balancer_url" {
  description = "Application load balancer DNS name"
  value       = module.compute.lb_dns_name
}

output "database_endpoint" {
  description = "RDS endpoint (host:port)"
  value       = module.database.endpoint
  sensitive   = true
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = module.compute.ecr_repository_url
}
