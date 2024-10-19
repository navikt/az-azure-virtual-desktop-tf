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

variable "vnet" {
  type = object({
    mode          = string
    name          = string
    location      = optional(string)
    address_space = optional(list(string))
  })
  validation {
    condition     = var.vnet.mode == "new" || var.vnet.mode == "existing"
    error_message = "Mode must be 'new' or 'existing'"
  }
  validation {
    condition     = var.vnet.mode == "existing" || (var.vnet.mode == "new" && var.vnet.location != null && var.vnet.address_space != null)
    error_message = "New vnets must have a location and address_space specified"
  }
}

variable "subnet" {
  type = object({
    mode             = string
    name             = string
    address_prefixes = optional(list(string))
  })
  validation {
    condition     = var.subnet.mode == "new" || var.subnet.mode == "existing"
    error_message = "Mode must be 'new' or 'existing'"
  }
  validation {
    condition     = var.subnet.mode == "existing" || (var.subnet.mode == "new" && var.subnet.address_prefixes != null)
    error_message = "New subnets must have address_prefixes specified"
  }
}
