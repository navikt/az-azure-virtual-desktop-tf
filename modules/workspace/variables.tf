variable "resource_group" {
  type = object({
    type     = string
    name     = string
    location = optional(string)
  })
  validation {
    condition     = var.resource_group.type == "new" || var.resource_group.type == "existing"
    error_message = "Type must be 'new' or 'existing'"
  }
  validation {
    condition     = var.resource_group.type == "new" || var.resource_group.location == null
    error_message = "New resource groups must have a location specified"
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
