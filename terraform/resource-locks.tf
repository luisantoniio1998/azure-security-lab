resource "azurerm_management_lock" "vnet_protection" {
  name       = "lock-vnet-security-lab"
  scope      = azurerm_virtual_network.lab.id
  lock_level = "CanNotDelete"
  notes      = "Protects the security lab VNet against accidental deletion."

  # Apply protection after workload provisioning finishes its subnet operations.
  depends_on = [
    azurerm_postgresql_flexible_server.database,
    azurerm_linux_web_app.backend,
  ]
}
