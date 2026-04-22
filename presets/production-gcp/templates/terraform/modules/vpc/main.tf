# =============================================================================
# VPC — custom network, subnet, Cloud NAT, Serverless VPC Access connector
# =============================================================================

resource "google_compute_network" "main" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  project                 = var.gcp_project
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "main" {
  name                     = "${var.project_name}-${var.environment}-subnet"
  project                  = var.gcp_project
  region                   = var.gcp_region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Egress to external APIs from Cloud Run / Cloud SQL
resource "google_compute_router" "main" {
  name    = "${var.project_name}-${var.environment}-router"
  project = var.gcp_project
  region  = var.gcp_region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  name                               = "${var.project_name}-${var.environment}-nat"
  project                            = var.gcp_project
  region                             = var.gcp_region
  router                             = google_compute_router.main.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Private Services Access for Cloud SQL private IP
resource "google_compute_global_address" "private_ip_range" {
  name          = "${var.project_name}-${var.environment}-psa"
  project       = var.gcp_project
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

# Serverless VPC Access connector for Cloud Run → Cloud SQL private IP
resource "google_vpc_access_connector" "main" {
  name          = "${substr(var.project_name, 0, 12)}-${var.environment}-vpc-c"
  project       = var.gcp_project
  region        = var.gcp_region
  network       = google_compute_network.main.name
  ip_cidr_range = cidrsubnet(var.subnet_cidr, 8, 255)
  min_instances = 2
  max_instances = 3
}
