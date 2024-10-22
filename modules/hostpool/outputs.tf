output "dag_id" {
  value = azurerm_virtual_desktop_application_group.dag.id
}

output "hostpool_id" {
  value = azurerm_virtual_desktop_host_pool.hp.id
}

output "hp_token" {
  value     = azurerm_virtual_desktop_host_pool_registration_info.hp_reg
  sensitive = true
}
