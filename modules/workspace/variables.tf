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
    condition     = var.resource_group.mode == "new" || var.resource_group.location == null
    error_message = "New resource groups must have a location specified"
  }
}

variable "workspace" {
  type = object({
    mode     = string
    name     = string
    location = optional(string)
  })
  validation {
    condition     = var.vnet.mode == "new" || var.vnet.mode == "existing"
    error_message = "Type må være 'new' eller 'existing'"
  }
    validation {
    condition     = var.vnet.mode == "existing" || (var.vnet.mode == "new" && var.vnet.location != null && var.vnet.address_space != null)
    error_message = "Nye vnet må ha lokasjon og address_space spesifisert"
  }
}

variable "name" {
  description = "The name of the workspace"
  type        = string
}

variable "location" {
  description = "The location of the workspace"
  type        = string
}

variable "friendly_name" {
  description = "The name of the workspace that the user sees"
  type        = string
}

variable "description" {
  description = "The description of the workspace"
  type        = string
  default     = null
}

variable "dag_ids" {
  description = "The IDs of the desktop application groups to associate with the workspace"
  type        = list(string)
}
