# =============================================================================
# Variables — [CUSTOMIZE] all default values for your project
# =============================================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  # [CUSTOMIZE] Set your project name
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

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "container_image" {
  description = "Docker image URI for the application"
  type        = string
  # [CUSTOMIZE] Set after first build: e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/app:latest
  default = "app:latest"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}
