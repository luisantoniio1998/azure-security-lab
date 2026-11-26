variable "postgresql_port" {
  description = "PostgreSQL database port"
  type        = string
  default     = "5432"
}

variable "deploy_workloads" {
  description = "Deploy paid application and database resources"
  type        = bool
  default     = false
}

variable "allowed_client_cidr" {
  description = "Single public IPv4 address allowed to access the app and deployment endpoint"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.allowed_client_cidr)) && endswith(var.allowed_client_cidr, "/32")
    error_message = "Provide one IPv4 address with a /32 prefix."
  }
}
