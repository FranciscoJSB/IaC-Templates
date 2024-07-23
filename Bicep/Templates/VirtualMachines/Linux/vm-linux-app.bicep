param tags object
param virtualMachine_parameters object
param landingZone_parameters object
param dataDisk_list object

@secure()
param sshPublicKey string

param needAvailabilitySet bool

param availabilitySetName string
param diskEncryptionDiskID string
param networkInterfaceName string
param networkSecurityGroupVM string
param VnetID string

var aadLoginExtensionName = 'AADSSHLoginForLinux'
var aadExtension = false

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: networkInterfaceName
  location: landingZone_parameters.location
  tags:tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: VnetID
          }
          privateIPAddress: virtualMachine_parameters.privateIP
        }
      }
    ]
    enableAcceleratedNetworking: true
    networkSecurityGroup: {
      id: networkSecurityGroupVM
      properties:{
      }
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachine_parameters.name
  location: landingZone_parameters.location
  tags: tags
  identity:{
    type:'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: virtualMachine_parameters.size
    }
  
    availabilitySet:{
      id:availabilitySet.id
    }
    storageProfile: {
      osDisk: {
        osType:'Linux'
        createOption: 'fromImage'
        name: '${virtualMachine_parameters.name}_DSK01'
        caching: 'ReadWrite'
        diskSizeGB:virtualMachine_parameters.osDiskSize
        managedDisk: {
          storageAccountType: virtualMachine_parameters.osDiskType
          diskEncryptionSet:{
            id:diskEncryptionDiskID
          }
        }
        deleteOption:'Delete'
      }
      imageReference: {
        publisher: virtualMachine_parameters.publisher 
        offer: virtualMachine_parameters.imageOffer
        sku: virtualMachine_parameters.sku
        version: 'latest'
      }
      dataDisks:[for i in range(1,length(dataDisk_list)): {
        
        name: '${virtualMachine_parameters.name}_DSK0${i+1}'
        createOption: 'Empty'
        caching: 'ReadOnly'
        writeAcceleratorEnabled: false
        diskSizeGB: dataDisk_list['dataDisk${i}'].size
        lun: i
        managedDisk:{
          diskEncryptionSet:{
            id: diskEncryptionDiskID
          }
          storageAccountType: 'Premium_LRS'
        }
    }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachine_parameters.name
      adminUsername: virtualMachine_parameters.adminUsername
      
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${virtualMachine_parameters.adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2019-07-01' = if(needAvailabilitySet==true) {
  name: availabilitySetName
  location: landingZone_parameters.location
  properties: {
    platformFaultDomainCount: virtualMachine_parameters.availabilitySetPlatformFaultDomainCount
    platformUpdateDomainCount: virtualMachine_parameters.availabilitySetPlatformUpdateDomainCount
  }
  sku: {
    name: 'Aligned'
  }
}

////////////////////////////////////
/////////// EXTENSIONS ////////////
//////////////////////////////////

// Azure Active Directory Login

@description('adding Azure Active Directory Login Extension')

resource virtualMachineName_aadLoginExtension 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = if (aadExtension) {
  parent: virtualMachine
  name: aadLoginExtensionName
  location: landingZone_parameters.location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: aadLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      mdmId: ''
    }
  }
  tags: tags
}

/////////// outputs

output vmappName string =  virtualMachine.name
output adminUsername string = virtualMachine_parameters.adminUsername
output identity string = virtualMachine.identity.principalId
output vmID string = virtualMachine.id
