variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "vpc_connector_id" {
  type = string
}

variable "cloud_sql_connection" {
  type = string
}

variable "database_url_secret" {
  type = string
}
