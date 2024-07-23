param locationRg string = resourceGroup().location

param tags object
param sqlServer_p object
param sqlDatabase_p object
param sqlAdvisors_list object

module sqlServer 'modules/sqlServer.bicep'={
  name: 'SQLServer'
  params:{
    tags:tags
    location: locationRg
    adminSQLPassword: 'password123Tfc' //change this parameter for the password from the KV

    // Add the line below to retrieve the secret from the keyvault (create existing resource or insert it via Powershell script)

    //adminSQLPassword: keyVault.getSecret('sql-db-admin-password') // change the name of the parameters inside the function to the name of the key created
    sqlAdvisors_list: sqlAdvisors_list
    //KeySQL: keyVault.outputs.keySQL // enable for CMK
    //keyVault: keyVault.outputs.keyVault //enable for CMK and add the output from KV
    sqlServer_p: sqlServer_p
  }
}

module sqlDatabase 'modules/sqlDatabase.bicep'={
  name: 'SQLDatabase'
  params:{
    sqlAdvisors_list: sqlAdvisors_list
    tags:tags
    location: locationRg
    sqlDatabase_p : sqlDatabase_p.sqlDatabase1
    sqlServerName: sqlServer.outputs.sqlServerName
  }
}

