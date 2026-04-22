# =============================================================================
# Cloud SQL (Postgres) with private IP, PITR, IAM authentication
# =============================================================================

resource "random_password" "db_root" {
  length           = 32
  special          = true
  override_special = "!#$%*-_=+"
}

resource "google_sql_database_instance" "main" {
  name                = "${var.project_name}-${var.environment}"
  project             = var.gcp_project
  region              = var.gcp_region
  database_version    = "POSTGRES_15"
  deletion_protection = var.environment == "production"

  depends_on = [var.private_vpc_peering]

  settings {
    tier              = var.db_tier
    availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"
    disk_autoresize   = true
    disk_type         = "PD_SSD"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = false
    }
  }
}

resource "google_sql_database" "main" {
  name     = "app"
  project  = var.gcp_project
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "root" {
  name     = "app-root"
  project  = var.gcp_project
  instance = google_sql_database_instance.main.name
  password = random_password.db_root.result
}

# Store connection string in Secret Manager — consumed by Cloud Run at deploy time
resource "google_secret_manager_secret" "db_url" {
  project   = var.gcp_project
  secret_id = "${var.project_name}-${var.environment}-db-url"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_url" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = "postgres://${google_sql_user.root.name}:${random_password.db_root.result}@/app?host=/cloudsql/${google_sql_database_instance.main.connection_name}"
}
