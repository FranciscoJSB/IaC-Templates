param tags object
param sqlServer_p object
param sqlAdvisors_list object

//param KeySQL string //used for CMK

param location string
@secure()
param adminSQLPassword string

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview'={
  name: sqlServer_p.name
  location: location
  tags:tags
  properties:{
    publicNetworkAccess:sqlServer_p.publicAccess
    //keyId:KeySQL  //used for CMK
    administrators:{
      administratorType:sqlServer_p.adminType
      principalType:sqlServer_p.principalType
      login:sqlServer_p.ServerAdmin
      azureADOnlyAuthentication:sqlServer_p.ADOauthentication
      tenantId:subscription().tenantId
      sid: sqlServer_p.serverAdminID
    }
    administratorLogin:sqlServer_p.adminLogin
    administratorLoginPassword:adminSQLPassword
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
    minimalTlsVersion: '1.2'
  }
}

resource sqlServerActiveDirectory 'Microsoft.Sql/servers/administrators@2023-05-01-preview' = {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties:{
    administratorType: 'ActiveDirectory'
    login: sqlServer_p.ServerAdmin
    sid: sqlServer_p.serverAdminID
    tenantId: subscription().tenantId
  }
}

resource sqlServerAdvancedThreatProtection 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2023-05-01-preview' = {
  parent: sqlServer
  name: 'Default'
  properties:{
    state: 'Enabled'
  }
}

resource sqlServerAdvisors 'Microsoft.Sql/servers/advisors@2014-04-01' = [for i in range(1,length(sqlAdvisors_list)): {
  parent: sqlServer
  name: sqlAdvisors_list['advisors${i}'].name
  properties:{
    autoExecuteValue: sqlAdvisors_list['advisors${i}'].state
  }
}]

output sqlServerName string = sqlServer.name
