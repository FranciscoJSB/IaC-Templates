param network_parameters array
param tags object

param nsgId string
param locationRg string

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2020-06-01' = [for vnet in network_parameters:{
  name: vnet.name
  location: locationRg
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [vnet.address]
    }

    subnets: [for subnet in vnet.subnets:{
        name: subnet.subnet_name
        properties: {
          addressPrefix: subnet.subnet_address
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }]
    enableDdosProtection: false
  }

}]

