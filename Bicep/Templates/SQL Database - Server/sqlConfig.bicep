param sqlDatabase_p object
param landingZone_parameters object
param tags object
param keyVault object

param managedIdentity string
param KeySQL string

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVault.keyvaultname
  scope: resourceGroup(subscription().subscriptionId, resourceGroup().name)
}

module sql 'sqlDatabase.bicep' = {
  name: 'deploySQL'
  params: {
    KeySQL:KeySQL
    adminSQLPassword: kv.getSecret('sql-db-admin-password')
    location:landingZone_parameters.location
    tags: tags
    sqlDatabase_p:sqlDatabase_p
    managedIdentity:managedIdentity
  }
}

output sqlServer string = sql.outputs.sqlServer
