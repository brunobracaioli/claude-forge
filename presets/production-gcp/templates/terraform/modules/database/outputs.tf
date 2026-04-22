output "connection_name" {
  description = "Cloud SQL connection string (project:region:instance)"
  value       = google_sql_database_instance.main.connection_name
  sensitive   = true
}

output "url_secret_id" {
  description = "Secret Manager resource holding the Postgres URL"
  value       = google_secret_manager_secret.db_url.id
}

output "instance_name" {
  value = google_sql_database_instance.main.name
}
