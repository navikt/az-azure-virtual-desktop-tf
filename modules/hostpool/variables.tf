variable "resource_group" {
  type = object({
    mode     = string
    name     = string
    location = optional(string)
  })
  validation {
    condition     = var.resource_group.mode == "new" || var.resource_group.mode == "existing"
    error_message = "Mode must be 'new' or 'existing'"
  }
  validation {
    condition     = var.resource_group.mode == "existing" || (var.resource_group.mode == "new" && var.resource_group.location != null)
    error_message = "New resource groups must have a location specified"
  }
}

variable "name" {
  description = "Name of the hostpool"
  type        = string
}

variable "location" {
  description = "Location of the hostpool, NB: VMs can be in different locations"
  type        = string
}

variable "type" {
  description = "Type of hostpool. 'Personal' or 'Pooled'"
  type        = string
  validation {
    condition     = var.type == "Personal" || var.type == "Pooled"
    error_message = "Type must be 'Personal' or 'Pooled'"
  }
}

variable "load_balancer_type" {
  description = "Load balancing mode, 'BreadthFirst' or 'DepthFirst' - Only used if hostpool type is 'Pooled'"
  type        = string
  default     = null
  validation {
    condition     = var.load_balancer_type == "BreadthFirst" || var.load_balancer_type == "DepthFirst" || var.load_balancer_type == null
    error_message = "Must be 'BreadthFirst' or 'DepthFirst', or not set if hostpool type is 'Personal'"
  }
}

variable "friendly_name" {
  description = "Friendly name of the hostpool"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the hostpool"
  type        = string
  default     = null
}

# variable "validate_hostpool" {
#   description = "Validation hostpool"
#   type        = bool
#   default     = false
# }

variable "start_vm_on_connect" {
  description = "Automatically turn on VM when user connects if VM is turned off"
  type        = bool
  default     = null
}

variable "custom_rdp_property" {
  description = "Custom RDP properties"
  type        = string
  default     = null
}

variable "personal_desktop_assignment_type" {
  description = "Assignment type for personal hostpool, 'Automatic' or 'Direct' - PS: If you change this after creation, the resources will be recreated."
  type        = string
  default     = "Automatic"
  validation {
    condition     = var.personal_desktop_assignment_type == null || var.personal_desktop_assignment_type == "Automatic" || var.personal_desktop_assignment_type == "Direct"
    error_message = "Must be 'Automatic' or 'Direct'"
  }
}

variable "public_network_access" {
  description = "Disable public network access for your Azure Virtual Desktop hostpool session hosts, but allow public access for end users. This allows users to stil access AVD service while ensuring the session host is only accessible through private routes. Learn more at: https://aka.ms/avdprivatelink"
  type        = string
  default     = "EnabledForClientsOnly"
  validation {
    condition     = var.public_network_access == "Enabled" || var.public_network_access == "Disabled" || var.public_network_access == "EnabledForClientsOnly" || var.public_network_access == "EnabledForSessionHostsOnly"
    error_message = "Must be 'Enabled', 'Disabled', 'EnabledForClientsOnly' or 'EnabledForSessionHostsOnly'"
  }
}

variable "maximum_sessions_allowed" {
  description = "Maximum number of concurrent sessions (users) allowed for pooled hostpools"
  type        = number
  default     = 22
}

variable "preferred_app_group_type" {
  description = "Foretrukne applikasjonsgruppe typer"
  type        = string
  default     = "Desktop"
  validation {
    # None, Desktop or RailApplications
    condition     = var.preferred_app_group_type == "None" || var.preferred_app_group_type == "Desktop" || var.preferred_app_group_type == "RailApplications"
    error_message = "Must be 'None', 'Desktop' or 'RailApplications'"
  }
}

variable "scheeduled_agent_updates" {
  description = "Scheduled agent updates"
  type        = string
  default     = null
}

variable "tags" {
  description = "Initial tags for all hostpool resources"
  type        = map(string)
  default     = {}
}

variable "desktop_users_group_names" {
  description = "Desktop Virtualization Users"
  type        = list(string)
  default     = null
}

variable "token_days_valid" {
  description = "How many days the token is valid for before it needs to be rotated"
  type        = number
  default     = 30
}
