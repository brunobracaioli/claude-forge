output "network_id" {
  description = "Self-link of the VPC"
  value       = google_compute_network.main.id
}

output "network_name" {
  description = "VPC name"
  value       = google_compute_network.main.name
}

output "subnet_id" {
  value = google_compute_subnetwork.main.id
}

output "vpc_connector_id" {
  description = "Serverless VPC Access connector ID for Cloud Run"
  value       = google_vpc_access_connector.main.id
}

output "private_vpc_peering" {
  description = "Dependency handle for Cloud SQL private-IP provisioning"
  value       = google_service_networking_connection.private_vpc_connection.id
}
