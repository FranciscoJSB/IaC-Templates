variable "location" {
default     = "eastus"
description = "Location of the resource group."
}

variable "rg_name" {
type        = string
default     = "rg-avd-resources"
description = "Name of the Resource group in which to deploy service objects"
}

variable "workspaceName" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default     = "AVD TF Workspace"
}

variable "prefix" {
type        = string
default     = "avdtf"
description = "Prefix of the name of the AVD machine(s)"
}