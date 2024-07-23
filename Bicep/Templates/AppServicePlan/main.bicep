param locationRg string = resourceGroup().location
param appServicePlan_p object
param tags object

module appServicePlan './appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: locationRg
    appServicePlan_p: appServicePlan_p
    tags: tags
  }
}
