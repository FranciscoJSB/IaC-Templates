param tags object
param networkSecurityGroup_parameters object
param resourceGroup_parameter object
param logAnalyticsWorkspace_params object
param keyVault_parameters object
param storageAccount_p object
param hub_parameters array
param network_parameters array

module virtualNetworks 'modules/networks.bicep'={
  name:'VirtualNetworks'
  scope: resourceGroup(resourceGroup_parameter.networkRG.name)
  params:{
    tags: tags
    locationRg: resourceGroup_parameter.networkRG.location
    network_parameters: network_parameters
    nsgId: networkSecurityGroup.outputs.nsgId
  }
  dependsOn:[
    hubNetwork
  ]
}

module hubNetwork 'modules/networks.bicep'={
  name:'hubNetwork'
  scope: resourceGroup(resourceGroup_parameter.networkRG.name)
  params:{
    tags: tags
    locationRg: resourceGroup_parameter.networkRG.location
    network_parameters: hub_parameters
    nsgId: networkSecurityGroup.outputs.nsgId
  } 
}

module networkSecurityGroup 'modules/networkSecurityGroup.bicep'={
  name: 'networkSecurityGroup'
  scope: resourceGroup(resourceGroup_parameter.networkRG.name)
  params:{
    tags: tags
    location: resourceGroup_parameter.networkRG.location
    networkSecurityGroup: networkSecurityGroup_parameters
  }
}

module virtualNetworkPeering 'modules/networkPeering.bicep'={
  name: 'peerings'
  params: {
    hub_parameters:hub_parameters
    network_parameters:network_parameters
  }
  dependsOn:[
    virtualNetworks, hubNetwork
  ]
}

@description('Create KeyVault for keys & Secrets')
module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    location: resourceGroup_parameter.networkRG.location
    keyVault_parameters: keyVault_parameters
    tags: tags
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    location: resourceGroup_parameter.networkRG.location
    storageAccount_p: storageAccount_p
    tags: tags
  }
}

module logAnalytics 'modules/logAnalytics.bicep'={
  name: 'logAnalytics'
  params:{
    location: resourceGroup_parameter.networkRG.location
    logAnalyticsWorkspace_params: logAnalyticsWorkspace_params
    tags: tags   
  }
}
