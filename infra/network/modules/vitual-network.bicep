@description('Name of the Virtual Network')
@minLength(3)
@maxLength(80)
param name string

@description('Location for all resources.')
param location string

@description('The address prefixes for the virtual network.')
param addressPrefixes array

@description('The subnets for the virtual network.')
param subnets array

@description('Virtual Network Resource')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: name
  location: location
  extendedLocation: {}
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

@description('Virtual Network Name output')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.name

@description('Virtual Network ID output')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.id
