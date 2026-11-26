resource "azurerm_postgresql_flexible_server" "database" {
  count = var.deploy_workloads ? 1 : 0

  name                = "psql-security-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_virtual_network.lab.location

  version    = "16"
  zone       = "1"
  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  delegated_subnet_id = azurerm_subnet.database.id
  private_dns_zone_id = azurerm_private_dns_zone.postgresql[0].id

  public_network_access_enabled = false

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql
  ]
}


resource "azurerm_postgresql_flexible_server_database" "notes" {
  count = var.deploy_workloads ? 1 : 0

  name      = "labnotes"
  server_id = azurerm_postgresql_flexible_server.database[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
