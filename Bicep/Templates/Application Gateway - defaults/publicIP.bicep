param landingZone_parameters object
param publicIP_patrameters object
param tags object

resource publicIPAddresses 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIP_patrameters.name
  tags: tags
  location: landingZone_parameters.location
  sku: publicIP_patrameters.sku
  zones: publicIP_patrameters.zones
  properties: {
    ipAddress: publicIP_patrameters.ipAddress
    publicIPAddressVersion: publicIP_patrameters.publicIPAddressVersion
    publicIPAllocationMethod: publicIP_patrameters.publicIPAllocationMethod
    idleTimeoutInMinutes: publicIP_patrameters.idleTimeoutInMinutes
  }
}

output id string = publicIPAddresses.id
