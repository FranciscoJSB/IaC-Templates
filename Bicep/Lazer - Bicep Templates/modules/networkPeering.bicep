param hub_parameters array
param network_parameters array

resource hub_vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing ={
  name: hub_parameters[0].name
  scope: resourceGroup()
}

resource spoke_vnets 'Microsoft.Network/virtualNetworks@2020-06-01' existing = [for i in network_parameters:{
  name: i.name
  scope: resourceGroup()
}]

resource sourceToDestinationPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = [for vnet in network_parameters:{
  name: '${vnet.name}-To-${hub_parameters[0].name}'
  parent:hub_vnet
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteAddressSpace:{
      addressPrefixes:[hub_parameters[0].address]
    }
    remoteVirtualNetworkAddressSpace:{
      addressPrefixes:[vnet.address]
    }
    remoteVirtualNetwork:{
      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${vnet.name}'
    }
  }
}]

resource destinationToSourcePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = [for vnet in range(0,length(network_parameters)):{
  name: '${hub_parameters[0].name}-To-${network_parameters[vnet].name}'
  parent: spoke_vnets[vnet]
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    remoteAddressSpace:{
      addressPrefixes:[network_parameters[vnet].address]
    }

    remoteVirtualNetworkAddressSpace:{
      addressPrefixes:[hub_parameters[0].address]
    }
    remoteVirtualNetwork:{
      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/${hub_parameters[0].name}'
    }
  }
}]
