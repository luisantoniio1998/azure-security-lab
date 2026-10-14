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

variable "api_key_secret_uri" {
  description = "Existing Key Vault secret URI, never the API key value. Grant the web app identity secret-read access before startup."
  type        = string
  default     = ""
}
