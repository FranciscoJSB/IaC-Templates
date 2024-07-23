param tags object
param sqlDatabase_p object
param KeySQL string

param location string
@secure()
param adminSQLPassword string
param managedIdentity string 

resource sqlServer 'Microsoft.Sql/servers@2021-11-01'={
  name: sqlDatabase_p.sqlDatabase.servername
  location: location
  tags:tags
  identity:{
    type:'UserAssigned'
    userAssignedIdentities:{
      '${managedIdentity}': {}
    }
  }
  properties:{
    publicNetworkAccess:'Disabled'
    keyId:KeySQL
    primaryUserAssignedIdentityId:managedIdentity
    administrators:{
      administratorType:'ActiveDirectory'
      principalType:'Group'
      login:sqlDatabase_p.sqlDatabase.ADAdmins
      azureADOnlyAuthentication:false
      tenantId:subscription().tenantId
      sid: sqlDatabase_p.sqlDatabase.serverAdminID
    }
    administratorLogin:sqlDatabase_p.sqlDatabase.name
    administratorLoginPassword:adminSQLPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01'={
  name: sqlDatabase_p.sqlDatabase.name
  parent: sqlServer
  location: location
  tags:tags
  sku:sqlDatabase_p.sqlDatabase.sku
  identity:{
    type:'UserAssigned'
    userAssignedIdentities:{
      '${managedIdentity}': {}
    }
  }
  properties:{ 
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 64424509439
    zoneRedundant: sqlDatabase_p.sqlDatabase.zoneRedundant
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    highAvailabilityReplicaCount: 0
    minCapacity: '0.5'
    autoPauseDelay:60
    isLedgerOn: false
  }
}

resource sqlBackup 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-11-01'={
  name:'default'
  parent:sqlDatabase
  properties:{
    retentionDays:sqlDatabase_p.sqlDatabase.retentionDays
  }
}

output sqlServer string = sqlServer.id

