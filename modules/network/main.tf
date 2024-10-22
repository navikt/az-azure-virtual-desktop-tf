data "azurerm_resource_group" "existing" {
  count = var.resource_group.mode == "existing" ? 1 : 0

  name = var.resource_group.name
}

resource "azurerm_resource_group" "new" {
  count = var.resource_group.mode == "new" ? 1 : 0

  name     = var.resource_group.name
  location = var.resource_group.location
  lifecycle {
    ignore_changes = [tags]
  }
}

data "azurerm_virtual_network" "existing" {
  depends_on = [azurerm_resource_group.new, data.azurerm_resource_group.existing]
  count      = var.vnet.mode == "existing" ? 1 : 0

  name                = var.vnet.name
  resource_group_name = var.resource_group.name
}

resource "azurerm_virtual_network" "new" {
  depends_on = [azurerm_resource_group.new, data.azurerm_resource_group.existing]
  count      = var.vnet.mode == "new" ? 1 : 0

  name                = var.vnet.name
  address_space       = var.vnet.address_space
  location            = var.vnet.location
  resource_group_name = var.resource_group.name
  lifecycle {
    ignore_changes = [tags]
  }
}

data "azurerm_subnet" "existing" {
  depends_on = [azurerm_virtual_network.new, data.azurerm_virtual_network.existing]
  count      = var.subnet.mode == "existing" ? 1 : 0

  name                 = var.subnet.name
  virtual_network_name = var.vnet.name
  resource_group_name  = var.resource_group.name
}

resource "azurerm_subnet" "new" {
  depends_on = [azurerm_virtual_network.new, data.azurerm_virtual_network.existing]
  count      = var.subnet.mode == "new" ? 1 : 0

  name                 = var.subnet.name
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.vnet.name
  address_prefixes     = var.subnet.address_prefixes
}

output "subnet_id" {
  value = var.subnet.mode == "new" ? azurerm_subnet.new[0].id : data.azurerm_subnet.existing[0].id
}
