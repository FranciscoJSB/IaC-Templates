param landingZone_parameters object
param containerRegistry_parameters object
param KeyACR string
param managedIdentityId string 
param managedIdentityIdClient string 
@description('Enable system identity forContainer Registry (sys: SystemAssigned   usr:UserAssigned  non:None)')
param enableSystemIdentity string = 'usr'
param tags object

param logAnalyticsWorkspaceID string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: containerRegistry_parameters.name
  location: landingZone_parameters.location
  sku: containerRegistry_parameters.sku
  tags: tags
  identity: {
    type: enableSystemIdentity == 'sys' ? 'SystemAssigned' : enableSystemIdentity == 'usr' ? 'UserAssigned' : 'None'
    userAssignedIdentities: (enableSystemIdentity == 'usr') ? {
      '${managedIdentityId}': {}
    } : null
  }
  properties: {
    adminUserEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: 'Disabled'
    encryption: {
      status: 'enabled'
      keyVaultProperties: {
        identity: managedIdentityIdClient
        keyIdentifier: KeyACR
      }
    }
  }
}

resource containerRegistryDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'containerRegistryDiagnosticSettings'
  scope: acrResource
  properties:{
    workspaceId: logAnalyticsWorkspaceID
    logs: [
      {
        categoryGroup:'audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
      }
    ]
  }
}

@description('Output the login server property for later use')
output id string = acrResource.id
output name string = acrResource.name
output loginServer string = acrResource.properties.loginServer

