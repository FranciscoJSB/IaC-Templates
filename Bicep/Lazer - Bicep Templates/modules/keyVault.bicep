@description('Location Resource group')
param location string

@description('KeyVault Parameters')
param keyVault_parameters object

@description('Tags parameter object')
param tags object

@description('URI for KeyVault')
var vaultUri = 'https://${keyVault_parameters.name}${environment().suffixes.keyvaultDns}'

@description('Variable del Identificador de CosmosDB')
var cosmosDBId = 'f27cf75b-16d5-46ad-b9dd-fe4d04460be3'

@description('Create KeyVault Resource')
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVault_parameters.name
  location: location
  tags: tags
  properties: {
    enabledForDeployment: keyVault_parameters.enabledForDeployment
    enabledForDiskEncryption: keyVault_parameters.enabledForDiskEncryption
    enabledForTemplateDeployment: keyVault_parameters.enabledForTemplateDeployment
    enableSoftDelete: keyVault_parameters.enableSoftDelete
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: keyVault_parameters.enableRbacAuthorization
    enablePurgeProtection: keyVault_parameters.enablePurgeProtection
    vaultUri: vaultUri
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    sku: keyVault_parameters.sku
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: cosmosDBId
        tenantId: subscription().tenantId
        permissions: {
          keys: [
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }

      }
    ]
  }
}

@description('Output KeyVault ID')
output keyVaultId string = keyVault.id

@description('Output KeyVault URI')
output keyvaulturi string = keyVault.properties.vaultUri

@description('Output KeyVault Name')
output keyVname string = keyVault.name
