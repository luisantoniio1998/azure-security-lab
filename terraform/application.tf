resource "azurerm_service_plan" "backend" {
  count = var.deploy_workloads ? 1 : 0

  name                = "asp-security-lab"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_virtual_network.lab.location

  os_type  = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "backend" {
  count = var.deploy_workloads ? 1 : 0

  name                = "app-security-lab-backend"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_virtual_network.lab.location
  service_plan_id     = azurerm_service_plan.backend[0].id

  https_only                = true
  virtual_network_subnet_id = azurerm_subnet.backend.id

  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = true
    ftps_state             = "Disabled"

    application_stack {
      node_version = "22-lts"
    }
  }
}
