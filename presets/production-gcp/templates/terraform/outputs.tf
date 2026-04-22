output "service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = module.compute.service_url
}

output "service_account_email" {
  description = "Service account email used by Cloud Run"
  value       = module.compute.service_account_email
}

output "database_connection_name" {
  description = "Cloud SQL connection name (project:region:instance)"
  value       = module.database.connection_name
  sensitive   = true
}

output "network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}
