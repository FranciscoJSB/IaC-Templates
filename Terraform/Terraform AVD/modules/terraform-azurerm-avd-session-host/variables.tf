variable "location" {
default     = "eastus"
description = "Location of the resource group."
}

variable "rg_name" {
type        = string
default     = "rg-avd-resources"
description = "Name of the Resource group in which to deploy service objects"
}

variable "subnet_id" {
  type = string
}

variable "hostPoolName" {
  type = string
}

variable "registration_token" {
  type = string
}

variable "number_of_avd_machines" {
  type = number
  description = "Number of AVD machines to deploy"
  default     = 2
}

variable "domain_name" {
  type        = string
  default     = "infra.local"
  description = "Name of the domain to join"
}

variable "domain_user_upn" {
  type        = string
  default     = "domainjoineruser" # do not include domain name as this is appended
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "domain_password" {
  type        = string
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}

variable "vm_size" {
  type = string
  description = "Size of the machine to deploy"
  default     = "Standard_DS2_v2"
}

variable "ou_path" {
  default = ""
}

variable "admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "vmpassword" {
  type        = string
  description = "local admin password"
  sensitive   = true
}