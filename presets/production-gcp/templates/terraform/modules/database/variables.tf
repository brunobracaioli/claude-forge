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

variable "network_id" {
  type = string
}

variable "private_vpc_peering" {
  description = "Dependency handle to ensure private services access is provisioned first"
  type        = string
}

variable "db_tier" {
  type = string
}
