variable "location" {
default     = "eastus"
description = "Location of the resource group."
}

variable "rg_name" {
type        = string
default     = "rg-avd-resources"
description = "Name of the Resource group in which to deploy service objects"
}

variable "rfc3339" {
type        = string
default     = "2022-03-30T12:43:13Z"
description = "Registration token expiration"
}

variable "host_pool_group" {
  type = list(object({
    name = string
    validate_environment = bool
    custom_rdp_properties = optional(string)
    description = optional (string)
    personal_desktop_assignment_type = optional (string)
    type = string
    maximum_sessions_allowed = number
    load_balancer_type = string

  }))
}