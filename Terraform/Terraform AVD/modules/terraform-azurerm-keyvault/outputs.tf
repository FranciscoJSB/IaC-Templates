output "vmpassword" {
  value = azurerm_key_vault_secret.vmpassword.value
}

output "domain_password" {
  value = azurerm_key_vault_secret.domainpassword.value
}

output "id" {
  value = azurerm_key_vault.keyvault.id
}

output "name" {
  value = azurerm_key_vault.keyvault.name
}