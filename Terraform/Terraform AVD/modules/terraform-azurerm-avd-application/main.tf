# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name = var.rg_name
  host_pool_id        = var.hostpool_id
  location            = var.location
  type                = var.applicationGroups.type#"Desktop"
  name                = "${var.applicationGroups.name}-dag" #var.prefix
  friendly_name       = var.applicationGroups.friendly_name#"Desktop AppGroup"
  description         = var.applicationGroups.description#"AVD application group"
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = var.workspace_id
}