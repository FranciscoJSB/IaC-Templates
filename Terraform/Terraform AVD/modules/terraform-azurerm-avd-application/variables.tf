variable "location" {
default     = "eastus"
description = "Location of the resource group."
}

variable "rg_name" {
type        = string
default     = "rg-avd-resources"
description = "Name of the Resource group in which to deploy service objects"
}

variable "hostpool_id" {
  type = string
  description = "ID of the host pool"
}

variable "workspace_id" {
  type = string
  description = "ID value of the AVD workspace"
}

variable "applicationGroups" {
  type = list(object({
    name = string
    type = string
    friendly_name = string
    description = string
  }))
}