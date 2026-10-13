resource "azurerm_service_plan" "backend" {
  name                = "asp-security-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_virtual_network.lab.location

  os_type  = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "backend" {
  name                = "app-security-lab-backend"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_virtual_network.lab.location
  service_plan_id     = azurerm_service_plan.backend.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"

    application_stack {
      node_version = "22-lts"
    }
  }
}
