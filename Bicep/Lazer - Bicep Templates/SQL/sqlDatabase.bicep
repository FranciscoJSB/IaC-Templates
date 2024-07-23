param sqlDatabase_p object
param tags object
param sqlAdvisors_list object

param sqlServerName string
param location string

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview'={
  name: '${sqlServerName}/${sqlDatabase_p.name}'
  location: location
  tags:tags
  sku:sqlDatabase_p.sku
  properties:{ 
    collation: sqlDatabase_p.collation
    maxSizeBytes: sqlDatabase_p.sizeBytes
    catalogCollation: sqlDatabase_p.collation
    zoneRedundant: sqlDatabase_p.zoneRedundant
    licenseType: sqlDatabase_p.licenseType
    readScale: sqlDatabase_p.readScale
    requestedBackupStorageRedundancy: sqlDatabase_p.requestedBackupStorageRedundancy
    maintenanceConfigurationId: '/subscriptions/c1f80e15-40e6-49ea-a4b7-25436cf91f63/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: sqlDatabase_p.ledge
    availabilityZone: 'NoPreference'
  }
}

resource sqlServerAdvisors 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = [for i in range(1,length(sqlAdvisors_list)): {
  parent: sqlDatabase
  name: sqlAdvisors_list['advisors${i}'].name
  properties:{
    autoExecuteValue: sqlAdvisors_list['advisors${i}'].state
  }

}]

resource sqlServerDatabasesBackupLongTermRetentionPolicies 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2023-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    makeBackupsImmutable: false
    backupStorageAccessTier: 'Hot'
    weeklyRetention: 'PT0S'
    monthlyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
    weekOfYear: 1
  }
}

resource sqlDatabasesBackupShortTermRetentionPolicies 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2023-05-01-preview' = {
  parent: sqlDatabase
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 24
  }
}

resource sqlServersDatabasesGeoBackupPolicies 'Microsoft.Sql/servers/databases/geoBackupPolicies@2023-05-01-preview' = {
  parent: sqlDatabase
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource sqlServersDatabasesVulnerabilityAssessments 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2023-05-01-preview' = {
  parent: sqlDatabase
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
}
