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

/*@description('The user name to be used as the Administrator for all VMs created by this deployment')
param vmUsername string*/

/*@description('The password for the Administrator user for all VMs created by this deployment')
@secure()
param vmPassword string*/

/*@description('The CI/CD platform to be used, and for which an agent will be configured for the ASE deployment. Specify \'none\' if no agent needed')
@allowed([
  'github'
  'azuredevops'
  'none'
])
param CICDAgentType string*/

/*@description('The Azure DevOps or GitHub account name to be used when configuring the CI/CD agent, in the format https://dev.azure.com/ORGNAME OR github.com/ORGUSERNAME OR none')
param accountName string*/

/*@description('The Azure DevOps or GitHub personal access token (PAT) used to setup the CI/CD agent')
@secure()
param personalAccessToken string*/

/*@description('The FQDN for the Application Gateway. Example - api.contoso.com.')
param appGatewayFqdn string*/

/*@description('The password for the TLS certificate for the Application Gateway.  The pfx file needs to be copied to deployment/bicep/gateway/certs/appgw.pfx')
@secure()
param certificatePassword string*/

/*@description('Set to selfsigned if self signed certificates should be used for the Application Gateway. Set to custom and copy the pfx file to deployment/bicep/gateway/certs/appgw.pfx if custom certificates are to be used')
param appGatewayCertType string*/

param location string = deployment().location

// Variables
var resourceSuffix = '${workloadName}-${environment}'
var networkingResourceGroupName = 'rg-network-${resourceSuffix}'
var sharedResourceGroupName = 'rg-shared-${resourceSuffix}'


var backendResourceGroupName = 'rg-${resourceSuffix}'

var apimResourceGroupName = 'rg-apim-${resourceSuffix}'

// Resource Names
var apimName = 'apim-${resourceSuffix}'
//var appGatewayName = 'appgw-${resourceSuffix}'


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


module apimModule './apim/apim.bicep'  = {
  name: 'apimDeploy'
  scope: resourceGroup(apimRG.name)
  params: {
    apimName: apimName
    apimSubnetId: '/subscriptions/bfdb94da-a317-41b0-a6f0-e4c7597262d7/resourceGroups/rg-network-solais-dev/providers/Microsoft.Network/virtualNetworks/vnet-apim-cs-solais-dev/subnets/snet-apim-solais-dev'
    location: location
    appInsightsName: 'appi-solais-dev'
    appInsightsId: '311b0160-2f7f-41fd-a76f-13b907102333'
    appInsightsInstrumentationKey: '4a30c646-3e58-4c12-a9aa-5e79e038a966'
  }
}
