targetScope='subscription'

// Parameters
@description('A short name for the workload being deployed alphanumberic only')
@maxLength(8)
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('The FQDN for the Application Gateway. Example - api.contoso.com.')
param appGatewayFqdn string

@description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
@secure()
param certificatePassword string

@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string

param location string = deployment().location

// Variables
var resourceSuffix = '${workloadName}-${environment}'
var networkingResourceGroupName = 'rg-network-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'


var backendResourceGroupName = 'rg-${resourceSuffix}'

var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
var appGatewayName = 'appgw-${resourceSuffix}'


resource networkingRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: networkingResourceGroupName
  location: location
}

resource backendRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: backendResourceGroupName
  location: location
}

resource sharedRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: sharedResourceGroupName
  location: location
}

resource apimRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: apimResourceGroupName
  location: location
}

//Creation of private DNS zones
module dnsZoneModule './shared/dnszone.bicep'  = {
  name: 'apimDnsZoneDeploy'
  scope: resourceGroup(sharedRG.name)
  params: {
    vnetName: 'vnet-apim-cs-solais-dev'
    vnetRG: networkingRG.name
    apimName: apimName
    apimRG: apimRG.name
  }
}

module appgwModule './gateway/appgw.bicep' = {
  name: 'appgwDeploy'
  scope: resourceGroup(apimRG.name)
  dependsOn: [
    dnsZoneModule
  ]
  params: {
    appGatewayName:                 appGatewayName
    appGatewayFQDN:                 appGatewayFqdn
    location:                       location
    appGatewaySubnetId:             '/subscriptions/bfdb94da-a317-41b0-a6f0-e4c7597262d7/resourceGroups/rg-network-solais-dev/providers/Microsoft.Network/virtualNetworks/vnet-apim-cs-solais-dev/subnets/snet-apgw-solais-dev'
    primaryBackendEndFQDN:          '${apimName}.azure-api.net'
    keyVaultName:                   'kv-solais-dev'
    keyVaultResourceGroupName:      sharedRG.name
    appGatewayCertType:             appGatewayCertType
    certPassword:                   certificatePassword
  }
}
