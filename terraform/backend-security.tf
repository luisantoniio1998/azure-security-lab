resource "azurerm_network_security_group" "backend" {
  name                = "nsg-backend"
  location            = azurerm_virtual_network.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_network_security_rule" "backend_to_database" {
  name      = "Allow-Backend-To-PostgreSQL"
  priority  = 100
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = var.postgresql_port

  source_address_prefix      = "10.10.1.0/24"
  destination_address_prefix = "10.10.2.0/24"

  resource_group_name         = azurerm_resource_group.lab.name
  network_security_group_name = azurerm_network_security_group.backend.name
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}
