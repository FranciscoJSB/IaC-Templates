param location string
param VnetID string
param appServicePlanId string
param keyVaultName string

param tags object
param appService_list object
param function_p object

param endpointList array
//param managedIdentity array

resource functionApp 'Microsoft.Web/sites@2021-03-01' = [for i in range(1,length(appService_list)): {
  name: appService_list['Function_Storage${i}'].functionName
  location: location
  tags: tags
  kind: function_p.kind
  identity:{
    type:'SystemAssigned'
    // type:'UserAssigned'
    // userAssignedIdentities:{
    //   '${managedIdentity[i-1].managedIdentityId}': {}
    // }
  }
  properties: {
    
    clientAffinityEnabled: false
    virtualNetworkSubnetId: VnetID
    httpsOnly: true
    enabled: true
    serverFarmId: appServicePlanId
    
    siteConfig: {
      vnetRouteAllEnabled: true
      linuxFxVersion:appService_list['Function_Storage${i}'].framework
      publicNetworkAccess: 'Disabled'
      numberOfWorkers: 1
      netFrameworkVersion: 'v4.0'
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: endpointList[i-1].name
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: '${appService_list['Function_Storage${i}'].framework}'!='JAVA|11' ? 'node' : 'java'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
    keyVaultReferenceIdentity: 'SystemAssigned'
    
  }
}]

module accessPoliciesFunctions 'keyVaultAccessPolicies.bicep' = [for i in range(0, length(appService_list)): {
  name: appService_list['Function_Storage${i}'].functionName
  params: {
    keyVaultName: keyVaultName
    identity_objectId:functionApp[i].id
  }
}]
