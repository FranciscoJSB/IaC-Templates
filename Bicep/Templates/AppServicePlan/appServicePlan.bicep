param location string
param appServicePlan_p object
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlan_p.name
  location: location
  kind: appServicePlan_p.kind
  tags: tags
  properties: {
     elasticScaleEnabled: false
     zoneRedundant: false
     reserved:true

  }
  sku:{
    tier: appServicePlan_p.sku.tier
    name: appServicePlan_p.sku.name
  }
}

output appServicePlanId string = appServicePlan.id
