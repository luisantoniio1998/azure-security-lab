resource "azurerm_private_dns_zone" "postgresql" {
  count = var.deploy_workloads ? 1 : 0

  name                = "security-lab.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  count = var.deploy_workloads ? 1 : 0

  name                  = "postgresql-vnet-link"
  resource_group_name   = azurerm_resource_group.lab.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql[0].name
  virtual_network_id    = azurerm_virtual_network.lab.id

  registration_enabled = false
}
