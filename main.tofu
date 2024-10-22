locals {
  module_path = "./modules"
  prefix      = var.prefix
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location.primary

  lifecycle {
    ignore_changes = [tags]
  }
}

module "hostpool" {
  depends_on = [azurerm_resource_group.rg]
  for_each   = var.hostpools
  source     = "${local.module_path}/hostpool"

  name                = "${local.prefix}-${each.key}"
  location            = each.value.location == null ? var.location.secondary : each.value.location
  type                = "Personal"
  friendly_name       = each.value.friendly_name
  description         = each.value.description
  start_vm_on_connect = each.value.start_vm_on_connect
  custom_rdp_property = each.value.custom_rdp_property
  resource_group = {
    mode = "existing"
    name = azurerm_resource_group.rg.name
  }
}

module "workspace" {
  depends_on = [module.hostpool]
  source     = "${local.module_path}/workspace"

  friendly_name = local.prefix
  # description         = module.hostpool[each.key].description
  dag_ids = [for dag in module.hostpool : dag.dag_id]
  resource_group = {
    mode = "existing"
    name = azurerm_resource_group.rg.name
  }
  workspace = {
    mode     = "new"
    name     = "${local.prefix}-ws"
    location = var.location.secondary
  }
}

module "network" {
  source     = "${local.module_path}/network"
  depends_on = [azurerm_resource_group.rg]

  resource_group = {
    mode = "existing"
    name = azurerm_resource_group.rg.name
  }
  vnet = {
    mode          = "new"
    name          = "${local.prefix}-vnet"
    location      = var.location.primary
    address_space = ["10.2.0.0/16"]
  }
  subnet = {
    mode             = "new"
    name             = "${local.prefix}-subnet1"
    address_prefixes = ["10.2.0.0/24"]
  }
}

module "vm" {
  depends_on = [module.hostpool, module.network]
  source     = "${local.module_path}/vm"
  for_each   = var.hostpools

  resource_group = {
    mode     = "new"
    name     = "${local.prefix}-${each.key}-vm-rg"
    location = var.location.primary
  }

  name      = "${each.key}-vm"
  location  = var.location.primary
  size      = "Standard_D2s_v4"
  subnet_id = module.network.subnet_id
}
