resource "azurerm_key_vault" "lab" {
  count = var.deploy_workloads ? 1 : 0

  name                = "kv-nata-seclab-16c2"
  location            = azurerm_virtual_network.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "None"
    virtual_network_subnet_ids = [azurerm_subnet.backend.id]
    ip_rules                   = [var.allowed_client_cidr]
  }
}

resource "azurerm_role_assignment" "app_secret_reader" {
  count = var.deploy_workloads ? 1 : 0

  scope                = azurerm_key_vault.lab[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.backend[0].identity[0].principal_id
}

resource "azurerm_role_assignment" "operator_secret_manager" {
  count = var.deploy_workloads ? 1 : 0

  scope                = azurerm_key_vault.lab[0].id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
