param landingZone_parameters object
param tags object
param CosmosDB_p object

var VnetID = '/subscriptions/${landingZone_parameters.subscription}/resourceGroups/${landingZone_parameters.rgVnet}/providers/Microsoft.Network/virtualNetworks/${landingZone_parameters.vnet}/subnets/${landingZone_parameters.subnet}'

///////////////////////////////////////////////////////////////////////////////

module cosmosDB './cosmosDB.bicep' = {
  name: 'cosmosDB'
  params: {
    landingZone_parameters:landingZone_parameters
    CosmosDB_p: CosmosDB_p
    tags: tags
    VnetID:VnetID
    KeyCosmos: keyVault.outputs.keyCosmos
  }
  dependsOn:[
  ]
}


/******** ADD TO KV **************

///// Adding Policy 

accessPolicies: [
      {
        objectId: 'f27cf75b-16d5-46ad-b9dd-fe4d04460be3' //change this value for the Azure Cosmos provided by Azure for each different Tenant
        permissions: {
          keys:[
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]


///// Key for Encryption

resource keyCosmos 'Microsoft.KeyVault/vaults/keys@2022-07-01'={
  parent:keyVault
  name:'${keyVault_parameters.cosmosKey}-EncryptionKey'
  properties:{
    kty:keyVault_parameters.keyType
    keySize:keyVault_parameters.keySize
    rotationPolicy: {
      attributes: {
        expiryTime: 'P180D'
      }
      lifetimeActions:[]
    }
    keyOps: [
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
      'encrypt'
      'decrypt'
    ]
  }
}


output keyCosmos object = {
  keyCosmosUri: keyCosmos.properties.keyUri
  keyCosmosName: keyCosmos.name
}

*/
