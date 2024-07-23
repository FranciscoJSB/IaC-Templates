param landingZone_parameters object
param tags object
param privateEndpoint_p object

param subnetId string


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = [for i in range(1, length(privateEndpoint_p)):{
  name: privateEndpoint_p['PrivateEndpoint_${i}'].privateEndpointName
  location: landingZone_parameters.location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    ipConfigurations: [for (groupName, j) in privateEndpoint_p['PrivateEndpoint_${i}'].groupName:{
        name: '${privateEndpoint_p['PrivateEndpoint_${i}'].ResourceName}${j+1}.${privateEndpoint_p['PrivateEndpoint_${i}'].privateDnsZone}'
        properties: {
          groupId: privateEndpoint_p['PrivateEndpoint_${i}'].groupId
          memberName: privateEndpoint_p['PrivateEndpoint_${i}'].groupName[j]
          privateIPAddress: privateEndpoint_p['PrivateEndpoint_${i}'].privateIPAddress[j]
        }
    }]
    customNetworkInterfaceName: '${privateEndpoint_p['PrivateEndpoint_${i}'].privateEndpointName}-NIC'
    
    privateLinkServiceConnections: [
      {
        name: privateEndpoint_p['PrivateEndpoint_${i}'].privateEndpointName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.${privateEndpoint_p['PrivateEndpoint_${i}'].resourceType}',privateEndpoint_p['PrivateEndpoint_${i}'].ResourceName)
          groupIds: [
            privateEndpoint_p['PrivateEndpoint_${i}'].groupId
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
  }
}]
