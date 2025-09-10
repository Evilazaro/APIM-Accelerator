targetScope = 'subscription'

@description('Location for the network resources')
param location string

var settings = loadYamlContent('./settings.yaml')

@description('Conditionally create a new resource group or use an existing one.')
resource networkRGCreate 'Microsoft.Resources/resourceGroups@2025-04-01' = if (settings.resourceGroup.createNew) {
  name: settings.resourceGroup.name
  location: settings.resourceGroup.location
}

@description('Conditionally reference an existing resource group.')
resource existingNetworkRG 'Microsoft.Resources/resourceGroups@2025-04-01' existing = if (!settings.resourceGroup.createNew) {
  name: settings.resourceGroup.name
}

@description('The name of the resource group to deploy the virtual network into.')
var resourceGroupName = settings.resourceGroup.createNew ? networkRGCreate.name : existingNetworkRG.name

@description('Module to create Virtual Network')
module virtualNetwork 'modules/vitual-network.bicep' = {
  scope: resourceGroup(resourceGroupName)
  params: {
    name: settings.name
    location: location
    addressPrefixes: settings.ipAddresses.addressSpaces
    subnets: settings.ipAddresses.subnets
  }
}

@description('Virtual Network Name output')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_NAME

@description('Virtual Network ID output')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.outputs.AZURE_VIRTUAL_NETWORK_ID
