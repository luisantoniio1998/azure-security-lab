resource "azurerm_network_security_group" "database" {
  name                = "nsg-database"
  location            = azurerm_virtual_network.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_network_security_rule" "allow_backend_database" {
  name      = "Allow-Backend-PostgreSQL"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = var.postgresql_port

  source_address_prefix      = "10.10.1.0/24"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.database.name
}

resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.database.id
}

resource "azurerm_network_security_rule" "allow_postgresql_internal" {
  name      = "Allow-PostgreSQL-Internal"
  priority  = 110
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "5432"

  source_address_prefix      = "10.10.2.0/24"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.database.name
}

resource "azurerm_network_security_rule" "allow_postgresql_storage" {
  name      = "Allow-PostgreSQL-Storage"
  priority  = 300
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "443"

  source_address_prefix      = "10.10.2.0/24"
  destination_address_prefix = "Storage"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.database.name
}

resource "azurerm_network_security_rule" "allow_postgresql_internal_outbound" {
  name      = "Allow-PostgreSQL-Internal-Outbound"
  priority  = 310
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = var.postgresql_port

  source_address_prefix      = "10.10.2.0/24"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.database.name
}

resource "azurerm_network_security_rule" "deny_other_database_clients" {
  name      = "Deny-Other-Database-Clients"
  priority  = 200
  direction = "Inbound"
  access    = "Deny"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "5432"

  source_address_prefix      = "10.10.0.0/16"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.database.name
}
