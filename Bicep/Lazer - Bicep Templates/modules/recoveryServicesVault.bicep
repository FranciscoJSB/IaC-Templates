param tags object
param location string
param recoveryServices_parameters object


@description('Enable cross region restore')
param enablecrossRegionRestore bool = false

resource vault 'Microsoft.RecoveryServices/vaults@2022-09-30-preview' = {
  name: recoveryServices_parameters.name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: recoveryServices_parameters.publicAccess
  }
  tags: tags
  sku: recoveryServices_parameters.sku
}

resource vaultConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2021-04-01' = {
  name: 'vaultstorageconfig'
  parent:vault
  tags: tags
  properties: {
    crossRegionRestoreFlag: enablecrossRegionRestore
    storageType: recoveryServices_parameters.storageType
  }
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-03-01' = {
  parent: vault
  name: recoveryServices_parameters.policyName
  tags: tags
  properties: {
    backupManagementType: 'AzureIaasVM'
    schedulePolicy: {
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: recoveryServices_parameters.scheduleRunTimes
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      dailySchedule: {
        retentionTimes: recoveryServices_parameters.scheduleRunTimes
        retentionDuration: {
          count: recoveryServices_parameters.count
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: recoveryServices_parameters.daysOfTheWeek
        retentionTimes: recoveryServices_parameters.scheduleRunTimes
        retentionDuration: {
          count: recoveryServices_parameters.weeklyRetentionDurationCount
          durationType: 'Weeks'
        }
      }
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
  }
}


output vault_Id string = vault.id
output vault_Name string = vault.name
