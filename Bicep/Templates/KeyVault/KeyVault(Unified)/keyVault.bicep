param landingZone_parameters object
param keyVault_parameters object 
param tags object
param storageAccount_list object

param VnetID string
param agent_objectId string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name:keyVault_parameters.name
  location:landingZone_parameters.location
  tags:tags
  properties:{
    sku: keyVault_parameters.sku
    tenantId: subscription().tenantId
    networkAcls: {
      bypass:'AzureServices'
      defaultAction:'Deny'
      ipRules:[]
      virtualNetworkRules:[
        {
          id:VnetID
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
    accessPolicies: [
      {
        objectId: 'f27cf75b-16d5-46ad-b9dd-fe4d04460be3'
        permissions: {
          keys:[
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
        tenantId: subscription().tenantId
      }
      {
        objectId: agent_objectId
        permissions: {
          secrets:[
            'all'
          ]
          certificates:[
            'all'
          ]
          keys:[
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
    publicNetworkAccess: 'Disabled'
  }
}


@description('assigning CMK keys to array of storage accounts')
resource key 'Microsoft.KeyVault/vaults/keys@2022-07-01'= [ for i in range(1,length(storageAccount_list)):{
  parent:keyVault
  name:'${storageAccount_list['Storage_Account_${i}'].storageName}-EncryptionKey'
  properties:{
    kty:keyVault_parameters.keyType
    keySize:keyVault_parameters.keySize
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
}]

resource keyCosmos 'Microsoft.KeyVault/vaults/keys@2022-07-01'={
  parent:keyVault
  name:'${keyVault_parameters.cosmosKey}-EncryptionKey'
  properties:{
    kty:keyVault_parameters.keyType
    keySize:keyVault_parameters.keySize
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


output keyvaulturi string = keyVault.properties.vaultUri
output keyVaultname string = keyVault.name
output keyCosmos object = {
  keyCosmosUri: keyCosmos.properties.keyUri
  keyCosmosName: keyCosmos.name
}

output key array = [for i in range(0, length(storageAccount_list)): {
  keyName:key[i].name
  keyUri:key[i].properties.keyUri
}]

