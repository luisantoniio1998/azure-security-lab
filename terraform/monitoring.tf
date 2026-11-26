# SEC-012 — VNet Deletion Detection

resource "azurerm_monitor_activity_log_alert" "vnet_deletion" {
  name                = "sec012-vnet-deletion-alert"
  resource_group_name = azurerm_resource_group.lab.name
  location            = "global"
  scopes              = ["/subscriptions/4c60d5e6-e707-4ed4-b35b-05b7d56916c2/resourcegroups/rg-azure-security-lab"]
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/virtualNetworks/delete"
  }

  action {
    action_group_id = local.security_action_group_id
  }
}

# SEC-012 — Resource Lock Deletion Detection

resource "azurerm_monitor_activity_log_alert" "lock_deletion" {
  name                = "sec012-lock-deletion-alert"
  resource_group_name = azurerm_resource_group.lab.name
  location            = "global"
  scopes              = ["/subscriptions/4c60d5e6-e707-4ed4-b35b-05b7d56916c2/resourcegroups/rg-azure-security-lab"]
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/locks/delete"
    statuses       = ["succeeded"]
  }

  action {
    action_group_id = local.security_action_group_id
  }
}

locals {
  security_action_group_id = "/subscriptions/4c60d5e6-e707-4ed4-b35b-05b7d56916c2/resourcegroups/rg-azure-security-lab/providers/microsoft.insights/actiongroups/ag-security-alerts"
}

# SEC-013.1 — NSG Security Rule Changes

resource "azurerm_monitor_activity_log_alert" "nsg_rule_changes" {
  name                = "sec013-nsg-rule-changes-alert"
  resource_group_name = azurerm_resource_group.lab.name
  location            = "global"
  scopes              = [azurerm_resource_group.lab.id]
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/securityRules/write"
  }

  action {
    action_group_id = local.security_action_group_id
  }
}
