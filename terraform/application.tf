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

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    APP_ENV                        = "production"
    API_KEY                        = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.lab[0].vault_uri}secrets/api-key)"
    PGHOST                         = azurerm_postgresql_flexible_server.database[0].fqdn
    PGDATABASE                     = azurerm_postgresql_flexible_server_database.notes[0].name
    PGUSER                         = "notes_app"
  }

  site_config {
    app_command_line  = "gunicorn --bind 0.0.0.0:8000 --workers 2 --worker-class uvicorn_worker.UvicornWorker --access-logfile /dev/null main:app"
    health_check_path = "/health"

    health_check_eviction_time_in_min = 2
    minimum_tls_version               = "1.2"
    vnet_route_all_enabled            = true
    ftps_state                        = "Disabled"

    ip_restriction_default_action     = "Deny"
    scm_use_main_ip_restriction       = true
    scm_ip_restriction_default_action = "Deny"

    ip_restriction {
      name       = "Allow-Lab-Client"
      action     = "Allow"
      priority   = 100
      ip_address = var.allowed_client_cidr
    }

    application_stack {
      python_version = "3.12"
    }
  }
}
