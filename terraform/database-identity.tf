variable "postgresql_admin_object_id" {
  description = "Object ID of the Microsoft Entra principal administering PostgreSQL"
  type        = string
}

variable "postgresql_admin_principal_name" {
  description = "Name of the Microsoft Entra administrator principal"
  type        = string
}

variable "postgresql_admin_principal_type" {
  description = "Microsoft Entra administrator principal type"
  type        = string
  default     = "User"

  validation {
    condition     = contains(["User", "Group", "ServicePrincipal"], var.postgresql_admin_principal_type)
    error_message = "Principal type must be User, Group or ServicePrincipal."
  }
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  server_name         = azurerm_postgresql_flexible_server.database.name
  resource_group_name = azurerm_resource_group.lab.name

  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = var.postgresql_admin_object_id
  principal_name = var.postgresql_admin_principal_name
  principal_type = var.postgresql_admin_principal_type
}

data "azurerm_client_config" "current" {}
