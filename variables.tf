variable "prefix" {
  type        = string
  description = "Prefix used for all resources"
}

variable "hostpools" {
  type = map(object({
    location            = optional(string)
    friendly_name       = optional(string)
    description         = optional(string)
    start_vm_on_connect = optional(bool)
    custom_rdp_property = optional(string)
  }))
  description = "Map of hostpools and their information"
}

# more will be specified here later, like networks, etc.
variable "environments" {
  type = map(object({
    subscriptionId = string
  }))
  description = "Map of environments and their information"
}

variable "location" {
  type = map(string)
  description = "primary and secondary location for the solution. Any resources not supported by the primary location will be created in the secondary location"
  default = {
    primary   = "norwayeast"
    secondary = "westeurope"
  }
}
