param landingZone_parameters object
param applicationGateway_parameters object
param publicIP_Id string
param firewallPolicie_Id string

var subnetRef = resourceId(landingZone_parameters.vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', landingZone_parameters.vnetName, landingZone_parameters.subnets[0])

resource applicationGateway 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: applicationGateway_parameters.name
  location: landingZone_parameters.location
  zones: applicationGateway_parameters.zones
  properties: {
    sku: applicationGateway_parameters.sku
    gatewayIPConfigurations: [
      {
        name: applicationGateway_parameters.gatewayIPConfigurations.name
        properties: {
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    sslCertificates: []
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: applicationGateway_parameters.frontendIPConfigurationsPublic.name
        properties: {
          privateIPAllocationMethod: applicationGateway_parameters.frontendIPConfigurationsPublic.privateIPAllocationMethod
          publicIPAddress: {
            id: publicIP_Id
          }
        }
      }
      {
        name: applicationGateway_parameters.frontendIPConfigurationsPrivate.name
        properties: {
          privateIPAddress: applicationGateway_parameters.frontendIPConfigurationsPrivate.privateIPAddress
          privateIPAllocationMethod: applicationGateway_parameters.frontendIPConfigurationsPrivate.privateIPAllocationMethod
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: applicationGateway_parameters.frontendPortsPrivate.name
        properties: {
          port: applicationGateway_parameters.frontendPortsPrivate.port
        }
      }
    ]
    backendAddressPools: [
      {
        name: applicationGateway_parameters.backendAddressPoolsPrivate.name
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: applicationGateway_parameters.backendHttpSettingsCollectionPrivate.name
        properties: {
          port: applicationGateway_parameters.backendHttpSettingsCollectionPrivate.port
          protocol: applicationGateway_parameters.backendHttpSettingsCollectionPrivate.protocol
          cookieBasedAffinity: applicationGateway_parameters.backendHttpSettingsCollectionPrivate.cookieBasedAffinity
          pickHostNameFromBackendAddress: applicationGateway_parameters.backendHttpSettingsCollectionPrivate.pickHostNameFromBackendAddress
          requestTimeout: applicationGateway_parameters.backendHttpSettingsCollectionPrivate.requestTimeout
        }
      }
    ]
    httpListeners: [
      {
        name: applicationGateway_parameters.httpListenersPrivate.name
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateway_parameters.name, '${applicationGateway_parameters.frontendIPConfigurationsPrivate.name}')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateway_parameters.name, '${applicationGateway_parameters.frontendPortsPrivate.name}')
          }
          protocol: applicationGateway_parameters.httpListenersPrivate.protocol
          hostNames: []
        }
      }

    ]
    listeners: []
    requestRoutingRules: [
      {
        name: applicationGateway_parameters.requestRoutingRulesPrivate.name
        properties: {
          ruleType: applicationGateway_parameters.requestRoutingRulesPrivate.ruleType
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateway_parameters.name, '${applicationGateway_parameters.httpListenersPrivate.name}')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateway_parameters.name, '${applicationGateway_parameters.backendAddressPoolsPrivate.name}')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateway_parameters.name, '${applicationGateway_parameters.backendHttpSettingsCollectionPrivate.name}')
          }
          priority: 1
        }
      }
    ]
    backendSettingsCollection: []
    routingRules: []
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    firewallPolicy: {
      id: firewallPolicie_Id
    }
  }
}
