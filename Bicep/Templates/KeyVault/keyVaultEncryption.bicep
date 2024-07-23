param landingZone_parameters object
param keyVault_parameters object 
param tags object

param devOpsAgentPrincipalID string
param VnetID string

@description('Key Vault For Disk Encryption')
resource keyVaultEncryptionDisk 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name:keyVault_parameters.keyVaultDiskEncryption.name
  location:landingZone_parameters.location
  tags:tags
  properties:{
    sku: keyVault_parameters.keyVaultDiskEncryption.sku
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules:[
        {
          id:VnetID
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
    accessPolicies: [
      {
        //giving access to the devOps Agent via its ID
        objectId: devOpsAgentPrincipalID
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    enablePurgeProtection: true
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2022-07-01'={
  parent:keyVaultEncryptionDisk
  name:keyVault_parameters.keyVaultDiskEncryption.keyEncryptionName
  properties:{
    kty:keyVault_parameters.keyVaultDiskEncryption.keyType
    keySize:keyVault_parameters.keyVaultDiskEncryption.keySize
    rotationPolicy: {
      attributes: {
        expiryTime: 'P180D'
      }
      lifetimeActions:[]
    }
    keyOps: [
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
      'encrypt'
      'decrypt'
    ]
  }
}

output keyvaultEncryptionName string = keyVaultEncryptionDisk.name
output keyvaultEncryptionID string = keyVaultEncryptionDisk.id
output keyVaultKeyUriWithVersion string = reference(key.id, '2022-07-01', 'Full').properties.keyUriWithVersion
