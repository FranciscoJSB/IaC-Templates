
# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  #quantity of host pools
  resource_group_name   = var.rg_name
  location              = var.location

  name                  = var.host_pool_group.name #"AVD-TF-HP"
  friendly_name         = var.host_pool_group.name
  validate_environment  = var.host_pool_group.validate_environment#true
  custom_rdp_properties = var.host_pool_group.custom_rdp_properties#"audiocapturemode:i:1;audiomode:i:0;"
  description           = var.host_pool_group.description#"${var.prefix} Terraform HostPool"

  type                     = var.host_pool_group.type#"Pooled"
  maximum_sessions_allowed = var.host_pool_group.maximum_sessions_allowed#16
  load_balancer_type       = var.host_pool_group.load_balancer_type#"DepthFirst" #[BreadthFirst DepthFirst]
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.rfc3339
}
