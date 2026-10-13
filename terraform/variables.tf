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
