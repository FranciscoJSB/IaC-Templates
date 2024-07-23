param logAnalyticsWorkspace_params object
param landingZone_parameters object
param tags object


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {

  name: logAnalyticsWorkspace_params.workspaceName
  location: landingZone_parameters.location

  tags: tags
  properties: {
    sku: {
      name: logAnalyticsWorkspace_params.skuName
    }
    retentionInDays: logAnalyticsWorkspace_params.retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02'={
  name: logAnalyticsWorkspace_params.applicationInsights_name
  location: landingZone_parameters.location
  kind: 'web'
  properties:{
    Application_Type: 'web'
    RetentionInDays: logAnalyticsWorkspace_params.retentionInDays
    WorkspaceResourceId:logAnalyticsWorkspace.id
  }
}

output logAnalyticsWorkspaceID string = logAnalyticsWorkspace.id
output instrumentationKeyInsights string = applicationInsights.properties.InstrumentationKey
output connectionStringInsights string = applicationInsights.properties.ConnectionString
