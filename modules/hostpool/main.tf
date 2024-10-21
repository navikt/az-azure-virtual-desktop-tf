data "azurerm_resource_group" "existing" {
  count = var.resource_group.type == "existing" ? 1 : 0

  name = var.resource_group.name
}

resource "azurerm_resource_group" "new" {
  count = var.resource_group.type == "new" ? 1 : 0

  name = var.resource_group.name
  location = var.resource_group.location

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_desktop_host_pool" "hp" {
  name                             = "${var.name}-hp"
  resource_group_name              = var.resource_group.name
  location                         = var.location
  type                             = var.type
  load_balancer_type               = var.type == "Personal" ? "Persistent" : var.load_balancer_type
  friendly_name                    = var.friendly_name
  description                      = var.description
  start_vm_on_connect              = var.start_vm_on_connect == null ? (var.type == "Personal" ? true : false) : var.start_vm_on_connect
  custom_rdp_properties            = var.custom_rdp_property
  personal_desktop_assignment_type = var.type == "Personal" ? var.personal_desktop_assignment_type : null
  maximum_sessions_allowed         = var.type == "Personal" ? null : var.maximum_sessions_allowed
  preferred_app_group_type         = var.preferred_app_group_type
  tags                             = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Desktop Application Group - should probably make this more dynamic later
resource "azurerm_virtual_desktop_application_group" "dag" {
  name                = "${var.name}-desktop"
  resource_group_name = azurerm_virtual_desktop_host_pool.hp.resource_group_name
  location            = azurerm_virtual_desktop_host_pool.hp.location
  host_pool_id        = azurerm_virtual_desktop_host_pool.hp.id
  type                = "Desktop"
  description         = var.description
}

# get all desktop users groups from azure ad
data "azuread_group" "groups" {
  for_each = var.desktop_users_group_names
  display_name = each.value
  security_enabled = true
}

# Permissions, should check if this is right or if we need custom roles
resource "azurerm_role_assignment" "desktop_role" {
  for_each = data.azuread_group.groups

  scope                = azurerm_virtual_desktop_application_group.dag.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = data.azuread_group.groups[each.key].id
}

# Time to live for the hostpool registration token
resource "time_rotating" "token_expiration_date" {
  rotation_days = var.token_days_valid == null ? 1 : var.token_days_valid
}
resource "azurerm_virtual_desktop_host_pool_registration_info" "hp_reg" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hp.id
  #expiration_date = var.token_validity == null ? timeadd(timestamp(), "24h") : var.token_validity
  expiration_date = time_rotating.token_expiration_date.rotation_rfc3339
}

output "hostpool_id" {
  value     = azurerm_virtual_desktop_host_pool.hp.id
}

output "hp_token" {
  value = azurerm_virtual_desktop_host_pool_registration_info.hp_reg
  sensitive = true
}

# https://docs.microsoft.com/en-us/troubleshoot/azure/virtual-machines/custom-routes-enable-kms-activation ?