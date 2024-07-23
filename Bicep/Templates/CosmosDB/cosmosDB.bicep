param landingZone_parameters object
param tags object
param CosmosDB_p object
param KeyCosmos object

param VnetID string

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = {
  name: CosmosDB_p.name
  location: landingZone_parameters.location
  kind: CosmosDB_p.kind
  identity: {
    type:'SystemAssigned'
  }
  tags: tags
  properties: {
    keyVaultKeyUri:KeyCosmos.keyCosmosUri
    publicNetworkAccess: 'Disabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: true
    virtualNetworkRules: [
      {
        id: VnetID
        ignoreMissingVNetServiceEndpoint: true
      }
    ]
    disableKeyBasedMetadataWriteAccess: false
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'FullFidelity'
    }
    databaseAccountOfferType: 'Standard'
    defaultIdentity: 'FirstPartyIdentity'
    networkAclBypass: 'None'
    disableLocalAuth: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    apiProperties: {
      serverVersion: '4.2'
    }
    enableFreeTier: false
    capacity: {
      totalThroughputLimit: 4000
    }
    locations: [
      {
        locationName: 'East US 2'
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    cors: []
    capabilities: [
      {
        name: 'EnableMongo'
      }
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
    backupPolicy:{
      type: 'Periodic'
      periodicModeProperties: {
         backupIntervalInMinutes: 1440
         backupRetentionIntervalInHours: 168
         backupStorageRedundancy: 'Local'
      }
    }
    networkAclBypassResourceIds: []
    
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2022-11-15' = {
  parent: account
  name: CosmosDB_p.database.name
  tags:tags
  properties: {
    options:{
      throughput:CosmosDB_p.database.throughput
    }
    resource:{
      id: CosmosDB_p.database.name
    }
  }
}



