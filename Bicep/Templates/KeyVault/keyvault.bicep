param landingZone_parameters object
param keyVault_parameters object
param virtualMachine_parameters object 
param tags object

param agent_objectId string
param VnetID string

@description('key vault')
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVault_parameters.keyVault.name
  location: landingZone_parameters.location
  tags:tags
  properties: {
    sku: keyVault_parameters.keyVault.sku
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
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization:false                    
    enablePurgeProtection: true
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Disabled'

  }
}

resource secretVM 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [ for i in range(1,length(virtualMachine_parameters)):{
  name: 'vm${i}AdminPassword'
  parent: keyVault
  properties: {
    value: passwordvm.properties.outputs.password
  }
}]

resource passwordvm 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'password-generate'
  location: landingZone_parameters.location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.0' 
    retentionInterval: 'P1D'
    //scriptContent: loadTextContent('../scripts/random-password-generator.ps1')
  }
}


output keyvaultname string = keyVault.name
output keyvaultID string = keyVault.id
