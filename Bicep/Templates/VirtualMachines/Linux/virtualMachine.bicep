param tags object
param virtualMachine_parameters object
param landingZone_parameters object
param diskEncryptionSet_parameters object
param dataDisk_list object

param VnetID string
param networkSecurityGroupVM string

param keyVaultEncryptionName string
param keyUriWithVersion string
param keyVaultEncryptionID string

@secure()
param sshPublicKeyVM1 string


resource diskEncryptionSetApp 'Microsoft.Compute/diskEncryptionSets@2022-07-02'={

  name:diskEncryptionSet_parameters.setApp
  location:landingZone_parameters.location
  tags:tags
  identity:{
    type:diskEncryptionSet_parameters.type
  }
  properties:{
    activeKey:{
      sourceVault:{
        id:keyVaultEncryptionID
      }
      keyUrl:keyUriWithVersion
      }
    encryptionType:diskEncryptionSet_parameters.encryptionType
    rotationToLatestKeyVersionEnabled: diskEncryptionSet_parameters.rotationToLatestKeyVersionEnabled
  }
}

@description('Access Policy for the Disk Encryption Set')
resource keyVaultAccessPolicy'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01'={
  name: '${keyVaultEncryptionName}/add'
  properties: {
    accessPolicies:[
      {
        objectId: diskEncryptionSetApp.identity.principalId
        
        permissions: {
          secrets:[
            'get'
          ]
          keys:[
            'Get'
            'WrapKey'
            'UnwrapKey'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]  
  }
}

module virtualMachine1 'vm-linux-app.bicep' = {
  name: '${virtualMachine_parameters.vm1.name}-VM1'
  params: {
    needAvailabilitySet:virtualMachine_parameters.vm1.needAvailabilitySet
    networkInterfaceName:virtualMachine_parameters.vm1.networkInterfaceName
    virtualMachine_parameters:virtualMachine_parameters.vm1
    landingZone_parameters:landingZone_parameters
    availabilitySetName:virtualMachine_parameters.vm1.availabilitySetName
    dataDisk_list:dataDisk_list
    tags:tags
    diskEncryptionDiskID:diskEncryptionSetApp.id
    networkSecurityGroupVM : networkSecurityGroupVM
    sshPublicKey:sshPublicKeyVM1
    VnetID:VnetID
  }
}

output virtualMachine1 string =  virtualMachine1.outputs.vmappName

