# =============================================================================
# Variables — [CUSTOMIZE] all default values for your project
# =============================================================================

variable "project_name" {
  description = "Project name used for resource naming and labeling"
  type        = string
  # [CUSTOMIZE] Set your project name (lowercase, hyphens; used in resource names)
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "gcp_project" {
  description = "GCP project ID (one per environment is strongly recommended)"
  type        = string
  # [CUSTOMIZE] e.g. myapp-dev, myapp-prd
}

variable "gcp_region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-central1"
}

variable "subnet_cidr" {
  description = "CIDR for the service subnet"
  type        = string
  default     = "10.10.0.0/20"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-custom-1-3840"
}

variable "container_image" {
  description = "Full image URI (Artifact Registry)"
  type        = string
  # [CUSTOMIZE] e.g. us-central1-docker.pkg.dev/<project>/<repo>/<image>:<tag>
  default = "gcr.io/cloudrun/placeholder"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}
