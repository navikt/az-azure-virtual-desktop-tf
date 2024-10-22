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
  description = "Name of the VM"
  type        = string
  validation {
    condition     = length(var.name) <= 15
    error_message = "Name can be at most 15 characters"
  }
}

variable "location" {
  description = "Location for the VM"
  type        = string
}

variable "size" {
  description = "Size of the VM"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID that the NIC will use"
  type        = string
}

variable "local_admin" {
  description = "The initial local administrator account"
  type = object({
    username = string
    password = string
  })
  default   = null
  sensitive = true
}

variable "users_group_name" {
  description = "Users that can login as regular users"
  type        = set(string)
  default     = []
}

variable "admins_group_name" {
  description = "Users that can login as local administrators"
  type        = set(string)
  default     = []
}

# variable "join_type" {
#   description = "How the VM should be joined and managed"
#   type        = string
#   validation {
#     condition     = var.join_type == "Intune" || var.join_type == "Hybrid"
#     error_message = "Må være 'Intune' eller 'Hybrid'"
#   }
# }
