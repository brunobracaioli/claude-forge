# =============================================================================
# Cloud Run service + dedicated service account, bound to Secret Manager + SQL
# =============================================================================

resource "google_service_account" "app" {
  account_id   = "${substr(var.project_name, 0, 16)}-${var.environment}-sa"
  display_name = "${var.project_name} ${var.environment} Cloud Run SA"
  project      = var.gcp_project
}

# Allow the SA to read the database URL secret
resource "google_secret_manager_secret_iam_member" "app_db_url" {
  project   = var.gcp_project
  secret_id = var.database_url_secret
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app.email}"
}

# Allow the SA to connect to Cloud SQL
resource "google_project_iam_member" "app_sql_client" {
  project = var.gcp_project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_cloud_run_v2_service" "main" {
  name     = "${var.project_name}-${var.environment}"
  project  = var.gcp_project
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    service_account = google_service_account.app.email

    scaling {
      min_instance_count = var.environment == "production" ? 1 : 0
      max_instance_count = 10
    }

    vpc_access {
      connector = var.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.container_image

      ports {
        container_port = var.container_port
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.database_url_secret
            version = "latest"
          }
        }
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      startup_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 2
        period_seconds        = 5
        failure_threshold     = 3
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloud_sql_connection]
      }
    }
  }

  depends_on = [
    google_secret_manager_secret_iam_member.app_db_url,
  ]
}
