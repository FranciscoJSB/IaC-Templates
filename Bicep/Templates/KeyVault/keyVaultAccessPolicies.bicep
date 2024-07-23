param keyVaultName string
param identity_objectId string

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: identity_objectId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'Get'
            'List'
          ]
          certificates: [
            'Get'
            'List'
          ]
          keys: [
            'Get'
            'List'
            'UnwrapKey'
            'WrapKey'

          ]
        }
      }
    ]
  }
}
