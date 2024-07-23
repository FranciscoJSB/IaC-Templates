param landingZone_parameters object
param directiveWAF_parameters object
param tags object

resource firewallPolicie 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2022-07-01' = {
  name: directiveWAF_parameters.name
  tags: tags
  location: landingZone_parameters.location
  properties: {
    customRules: []
    policySettings: {
      requestBodyCheck: directiveWAF_parameters.requestBodyCheck
      maxRequestBodySizeInKb: directiveWAF_parameters.maxRequestBodySizeInKb
      fileUploadLimitInMb: directiveWAF_parameters.fileUploadLimitInMb
      state: directiveWAF_parameters.state
      mode: directiveWAF_parameters.mode
    }
    managedRules: {
      managedRuleSets: directiveWAF_parameters.managedRuleSets
      exclusions: []
    }
  }
}

output id string = firewallPolicie.id
