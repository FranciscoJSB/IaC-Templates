output "azurerm_virtual_desktop_workspace" {
  description = "Name of the Azure Virtual Desktop workspace"
  value       = azurerm_virtual_desktop_workspace.workspace.name
}

output "id" {
  value = azurerm_virtual_desktop_workspace.workspace.id
}