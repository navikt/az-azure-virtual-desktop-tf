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

data "azurerm_virtual_desktop_workspace" "existing" {
  count = var.workspace.mode == "existing" ? 1 : 0

  name                = var.workspace.name
  resource_group_name = var.resource_group.name
}

resource "azurerm_virtual_desktop_workspace" "new" {
  depends_on = [azurerm_resource_group.new, data.azurerm_resource_group.existing]
  count      = var.workspace.mode == "new" ? 1 : 0

  name                = var.workspace.name
  location            = var.workspace.location
  resource_group_name = var.resource_group.name
  description         = var.friendly_name
  friendly_name       = var.description
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "main" {
  depends_on = [azurerm_virtual_desktop_workspace.new, azurerm_virtual_desktop_workspace.existing]
  for_each   = { for idx, dag_id in var.dag_ids : idx => dag_id }

  workspace_id         = var.workspace.mode == "new" ? azurerm_virtual_desktop_workspace.new[0].id : data.azurerm_virtual_desktop_workspace.existing[0].id
  application_group_id = each.value
}

output "workspace_id" {
  value = var.workspace.mode == "new" ? azurerm_virtual_desktop_workspace.new[0].id : data.azurerm_virtual_desktop_workspace.existing[0].id
}