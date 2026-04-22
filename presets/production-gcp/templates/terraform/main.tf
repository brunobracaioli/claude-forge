# =============================================================================
# Terraform — Production-GCP preset
# [CUSTOMIZE] Adjust project, region, and backend configuration.
# =============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # [CUSTOMIZE] Configure remote backend (GCS)
  # Create the bucket once, out-of-band:
  #   gcloud storage buckets create gs://<project>-tfstate --location=<region> --uniform-bucket-level-access
  #   gcloud storage buckets update gs://<project>-tfstate --versioning
  # backend "gcs" {
  #   bucket = "your-project-tfstate"
  #   prefix = "terraform/state"
  # }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project
  region  = var.gcp_region
}

# --- Enable required APIs (idempotent, safe to re-run) ---
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "iamcredentials.googleapis.com",
  ])
  project            = var.gcp_project
  service            = each.value
  disable_on_destroy = false
}

# --- VPC + Cloud NAT + Serverless VPC Access ---
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  gcp_project  = var.gcp_project
  gcp_region   = var.gcp_region
  subnet_cidr  = var.subnet_cidr
}

# --- Cloud SQL (Postgres, private IP) ---
module "database" {
  source = "./modules/database"

  project_name      = var.project_name
  environment       = var.environment
  gcp_project       = var.gcp_project
  gcp_region        = var.gcp_region
  network_id        = module.vpc.network_id
  private_vpc_peering = module.vpc.private_vpc_peering
  db_tier           = var.db_tier
}

# --- Cloud Run service + per-service SA ---
module "compute" {
  source = "./modules/compute"

  project_name         = var.project_name
  environment          = var.environment
  gcp_project          = var.gcp_project
  gcp_region           = var.gcp_region
  container_image      = var.container_image
  container_port       = var.container_port
  vpc_connector_id     = module.vpc.vpc_connector_id
  cloud_sql_connection = module.database.connection_name
  database_url_secret  = module.database.url_secret_id
}
