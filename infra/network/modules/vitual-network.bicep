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
@description('Enable Virtual network encryption')
param enableEncryption bool

@description('Virtual Network Resource')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
    encryption: (enableEncryption)
      ? {
          enabled: enableEncryption
          enforcement: 'AllowUnencrypted'
        }
      : null
  }
}

@description('Virtual Network Name output')
output AZURE_VIRTUAL_NETWORK_NAME string = virtualNetwork.name

@description('Virtual Network ID output')
output AZURE_VIRTUAL_NETWORK_ID string = virtualNetwork.id

@description('Virtual Network Subnets output')
output AZURE_VIRTUAL_NETWORK_SUBNETS object[] = [
  for (item, index) in subnets: {
    name: item.name
    id: virtualNetwork.properties.subnets[index].id
  }
]
