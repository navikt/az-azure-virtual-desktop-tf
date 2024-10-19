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

variable "workspace" {
  type = object({
    mode     = string
    name     = string
    location = optional(string)
  })
  validation {
    condition     = var.workspace.mode == "new" || var.workspace.mode == "existing"
    error_message = "Mode must be 'new' or 'existing'"
  }
  validation {
    condition     = var.workspace.mode == "existing" || (var.workspace.mode == "new" && var.workspace.location != null)
    error_message = "New workspaces must have a location specified"
  }
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
