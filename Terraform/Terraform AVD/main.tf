data "azurerm_client_config" "current" {}

module "keyvault" {
  source = "./modules/terraform-azurerm-keyvault"

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  rg_name  = var.rg_name
  location = var.location
}

#################################################################
######################      AVD              ####################
#################################################################

module "avd-workspace" {
  source        = "./modules/terraform-azurerm-avd-workspace"
  prefix        = var.prefix
  workspaceName = var.workspaceName

  resource_group_location = var.location
  rg_name                 = var.rg_name

}

#hostpool

module "avd-hostpool" {
  source          = "./modules/terraform-azurerm-avd-host-pool"
  rfc3339         = var.tokenExpirationDate
  host_pool_group = var.host_pool_group

  rg_name  = var.rg_name
  location = var.location
}

# application groups

module "avd-applicationGroups-01" {
  source            = "./modules/terraform-azurerm-avd-application"
  applicationGroups = var.applicationGroups
  hostpool_id       = module.avd-hostpool.id
  workspace_id      = module.avd-workspace.id

  rg_name  = var.rg_name
  location = var.location
}

#################################################################
######################      Session Host     ####################
#################################################################

locals {
  registration_token = module.avd-hostpool.azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}

module "avd-sessionhost" {
  source                 = "./modules/terraform-azurerm-avd-session-host"
  admin_username         = var.admin_username
  domain_name            = var.domain_name
  domain_user_upn        = var.domain_user_upn
  number_of_avd_machines = var.number_of_avd_machines
  ou_path                = var.ou_path
  registration_token     = local.registration_token
  vm_size                = var.vm_size

  hostPoolName    = module.avd-hostpool.name
  domain_password = module.keyvault.domain_password
  vmpassword      = module.keyvault.vmpassword
  #subnet_id = 

  rg_name  = var.rg_name
  location = var.location
}

############################################
############# RBAC Roles  ##################
############################################


data "azuread_user" "aad_user" {
  for_each            = toset(var.avd_users)
  user_principal_name = format("%s", each.key)
}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

resource "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

resource "azuread_group_member" "aad_group_member" {
  for_each         = data.azuread_user.aad_user
  group_object_id  = azuread_group.aad_group.id
  member_object_id = each.value["id"]
}

resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = azuread_group.aad_group.id
}

#####################################
################# Networks ##########
#####################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNet"
  address_space       = var.vnet_range
  dns_servers         = var.dns_servers
  location            = var.deploy_location
  resource_group_name = var.rg_name
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_range
  depends_on           = [azurerm_resource_group.rg]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-NSG"
  location            = var.deploy_location
  resource_group_name = var.rg_name
  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

data "azurerm_virtual_network" "ad_vnet_data" {
  name                = var.ad_vnet
  resource_group_name = var.ad_rg
}

resource "azurerm_virtual_network_peering" "peer1" {
  name                      = "peer_avdspoke_ad"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.ad_vnet_data.id
}
resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peer_ad_avdspoke"
  resource_group_name       = var.ad_rg
  virtual_network_name      = var.ad_vnet
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

####################################################
####################### Storage ####################
####################################################

## Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.deploy_location
  name     = var.rg_stor
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
## Create a File Storage Account 
resource "azurerm_storage_account" "storage" {
  name                     = "stor${random_string.random.id}"
  resource_group_name      = azurerm_resource_group.rg_storage.name
  location                 = azurerm_resource_group.rg_storage.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

}

resource "azurerm_storage_share" "FSShare" {
  name                 = "fslogix"
  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]
}

## Azure built-in roles
## https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

resource "azurerm_role_assignment" "af_role" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = azuread_group.aad_group.id
}

####################### Compute Gallery

resource "azurerm_resource_group" "sigrg" {
  location = var.deploy_location
  name     = var.rg_shared_name
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "rando" {
  length  = 4
  upper   = false
  special = false
}


# Creates Shared Image Gallery
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery
resource "azurerm_shared_image_gallery" "sig" {
  name                = "sig${random_string.random.id}"
  resource_group_name = azurerm_resource_group.sigrg.name
  location            = azurerm_resource_group.sigrg.location
  description         = "Shared images"

  tags = {
    Environment = "Demo"
    Tech        = "Terraform"
  }
}

#Creates image definition
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image
resource "azurerm_shared_image" "example" {
  name                = "avd-image"
  gallery_name        = azurerm_shared_image_gallery.sig.name
  resource_group_name = azurerm_resource_group.sigrg.name
  location            = azurerm_resource_group.sigrg.location
  os_type             = "Windows"

  identifier {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "20h2-evd-o365pp"
  }
}
