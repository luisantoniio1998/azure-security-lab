resource "azurerm_postgresql_flexible_server" "database" {
  name                = "psql-security-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_virtual_network.lab.location

  version = "16"

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768

  delegated_subnet_id = azurerm_subnet.database.id
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id

  public_network_access_enabled = false

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql
  ]
}
