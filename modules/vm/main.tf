data "azurerm_resource_group" "existing" {
  count = var.resource_group.mode == "existing" ? 1 : 0
  name  = var.resource_group.name
}

resource "azurerm_resource_group" "new" {
  count    = var.resource_group.mode == "new" ? 1 : 0
  name     = var.resource_group.name
  location = var.resource_group.location
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "random_string" "AVD_local_password" {
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}

resource "azurerm_network_interface" "nic" {
  depends_on          = [azurerm_resource_group.new, data.azurerm_resource_group.existing]
  name                = "${var.name}-nic"
  resource_group_name = var.resource_group.name
  location            = var.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  depends_on            = [azurerm_resource_group.new, data.azurerm_resource_group.existing, azurerm_network_interface.nic]
  name                  = var.name
  resource_group_name   = var.resource_group.name
  location              = var.location
  size                  = var.size
  admin_username        = var.local_admin == null ? "localadmin" : var.local_admin.username
  admin_password        = var.local_admin == null ? random_string.AVD_local_password.result : var.local_admin.password
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {
    name                 = "${var.name}-OS"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "office-365"
    #sku       = "win11-24h2-avd-m365"
    sku     = "win11-24h2-m365"
    version = "latest"
  }
  identity {
    type = "SystemAssigned"
  }
  # boot_diagnostics {
  #   storage_account_uri = data.azurerm_storage_account.storage.primary_blob_endpoint
  # }
  lifecycle {
    prevent_destroy = true // For now let's not destroy VMs...
    ignore_changes = [
      tags,
      size, // Lets us change the size of the VM in the portal ++ without terraform complaints
    ]
  }
}

#

# lets wait a bit with all the fancy stuff below. I just added it all to have a reference for later



# data "azuread_group" "users" {
#   display_name     = var.users_group_name
#   security_enabled = true
# }

# data "azuread_group" "admins" {
#   display_name     = var.admins_group_name
#   security_enabled = true
# }

# # Apply the IAM configuration.
# resource "azurerm_role_assignment" "vm_user_role" {
#   scope                = var.resource_group.mode == "new" ? azurerm_resource_group.new.id : data.azurerm_resource_group.existing.id
#   role_definition_name = "Virtual Machine User Login"
#   principal_id         = data.azuread_group.users.id
# }

# resource "azurerm_role_assignment" "vm_administrator_role" {
#   scope                = var.resource_group.mode == "new" ? azurerm_resource_group.new.id : data.azurerm_resource_group.existing.id
#   role_definition_name = "Virtual Machine Administrator Login"
#   principal_id         = data.azuread_group.admins.id
# }


# check if we need all these extensions from https://github.com/rhyspaterson/cloud-native-avd/blob/main/terraform/avd/main.tf

# resource "azurerm_virtual_machine_extension" "aad" {
#   name                       = "ext-AADLoginForWindows"
#   publisher                  = "Microsoft.Azure.ActiveDirectory"
#   type                       = "AADLoginForWindows"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   count                      = var.avd_vm_count
#   settings                   = <<-SETTINGS
#     {
#       "mdmId": "0000000a-0000-0000-c000-000000000000"
#     }
#     SETTINGS
# }
# resource "azurerm_virtual_machine_extension" "monitoring" {
#   count                      = var.avd_vm_count
#   name                       = "ext-MicrosoftMonitoringAgent"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
#   type                       = "MicrosoftMonitoringAgent"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#     {
#         "workspaceId": "${azurerm_log_analytics_workspace.law.workspace_id}"
#     }
#   SETTINGS
#   protected_settings         = <<PROTECTED_SETTINGS
#     {
#       "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
#     }
#   PROTECTED_SETTINGS
# }

# resource "azurerm_virtual_machine_extension" "da" {
#   count                      = var.avd_vm_count
#   name                       = "ext-DependencyAgentWindows"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                       = "DependencyAgentWindows"
#   type_handler_version       = "9.10"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = true
# }
# resource "azurerm_virtual_machine_extension" "guesthealth" {
#   count                      = var.avd_vm_count
#   name                       = "ext-GuestHealth"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.Azure.Monitor.VirtualMachines.GuestHealth"
#   type                       = "GuestHealthWindowsAgent"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = false
# }

# resource "azurerm_virtual_machine_extension" "azuremonitor" {
#   count                      = var.avd_vm_count
#   name                       = "ext-AzureMonitor"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.Azure.Monitor"
#   type                       = "AzureMonitorWindowsAgent"
#   type_handler_version       = "1.4"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = true
# }

# resource "azurerm_virtual_machine_extension" "guestattestation" {
#   count                      = var.avd_vm_count
#   name                       = "ext-GuestAttestation"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.Azure.Security.WindowsAttestation"
#   type                       = "GuestAttestation"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = false
# }

# resource "azurerm_virtual_machine_extension" "guestconfiguration" {
#   count                      = var.avd_vm_count
#   name                       = "ext-GuestConfiguration"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.GuestConfiguration"
#   type                       = "ConfigurationforWindows"
#   type_handler_version       = "1.29"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = true
# }

# resource "azurerm_virtual_machine_extension" "networkwatcher" {
#   count                      = var.avd_vm_count
#   name                       = "ext-NetworkWatcher"
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.Azure.NetworkWatcher"
#   type                       = "NetworkWatcherAgentWindows"
#   type_handler_version       = "1.4"
#   auto_upgrade_minor_version = true
#   automatic_upgrade_enabled  = false
# }

# resource "azurerm_virtual_machine_extension" "domain_join" {
#   count                      = var.rdsh_count
#   name                       = "${var.prefix}-${count.index + 1}-domainJoin"
#   virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "JsonADDomainExtension"
#   type_handler_version       = "1.3"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#       "Name": "${var.domain_name}",
#       "OUPath": "${var.ou_path}",
#       "User": "${var.domain_user_upn}@${var.domain_name}",
#       "Restart": "true",
#       "Options": "3"
#     }
# SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#       "Password": "${var.domain_password}"
#     }
# PROTECTED_SETTINGS

#   lifecycle {
#     ignore_changes = [settings, protected_settings]
#   }

#   depends_on = [
#     azurerm_virtual_network_peering.peer1,
#     azurerm_virtual_network_peering.peer2
#   ]
# }

# resource "azurerm_virtual_machine_extension" "vmext_dsc" {
#   count                      = var.rdsh_count
#   name                       = "${var.prefix}${count.index + 1}-avd_dsc"
#   virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
#   publisher                  = "Microsoft.Powershell"
#   type                       = "DSC"
#   type_handler_version       = "2.73"
#   auto_upgrade_minor_version = true

#   settings = <<-SETTINGS
#     {
#       "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
#       "configurationFunction": "Configuration.ps1\\AddSessionHost",
#       "properties": {
#         "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}"
#       }
#     }
# SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#   {
#     "properties": {
#       "registrationInfoToken": "${local.registration_token}"
#     }
#   }
# PROTECTED_SETTINGS

#   depends_on = [
#     azurerm_virtual_machine_extension.domain_join,
#     azurerm_virtual_desktop_host_pool.hostpool
#   ]
# }
