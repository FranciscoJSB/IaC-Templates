param location string

param Redis_p object
param tags object
param landingZone_parameters object

resource redisCache 'Microsoft.Cache/Redis@2022-05-01'  = {
  name: Redis_p.name
  location: location
  tags: tags
  zones: Redis_p.zones

  properties: {
    minimumTlsVersion:'1.2'
    redisVersion: Redis_p.redisVersion
    sku: Redis_p.sku
    enableNonSslPort: false
    
    redisConfiguration: {
      'rdb-backup-enabled': Redis_p.rdbbackupenabled
      'rdb-backup-frequency': Redis_p.rdbbackupfrequency
      'rdb-backup-max-snapshot-count': Redis_p.rdbbackupmaxsnapshotcount
      'rdb-storage-connection-string': 'DefaultEndpointsProtocol=https;AccountName=${Redis_p.storageAccount};BlobEndpoint=https://${Redis_p.storageAccount}.blob.core.windows.net/;AccountKey=${listKeys('/subscriptions/${landingZone_parameters.subscription}/resourceGroups/${landingZone_parameters.rgName}/providers/Microsoft.Storage/storageAccounts/${Redis_p.storageAccount}', '2015-06-15').key1}'
      'preferred-data-persistence-auth-method': 'sas'
      'maxmemory-reserved': Redis_p.maxmemoryreserved
      'maxfragmentationmemory-reserved': Redis_p.maxfragmentationmemoryreserved
      'maxmemory-delta': Redis_p.maxmemorydelta
    }
    publicNetworkAccess: 'Disabled'
  }
}

