param location string
param networkSecurityGroup object
param tags object

resource networkSecurityGroupPrivateEndpoint 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowApplicationSecurityGroupHTTPSInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description:'Default'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '443'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

output nsgId string = networkSecurityGroup.id
