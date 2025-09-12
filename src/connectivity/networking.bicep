param location string
param virtualNetwork VirtualNetworkSettings
param tags object

type VirtualNetworkSettings = {
  name: string
  addressPrefixes: string[]
  subnets: object
}

resource apimVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: virtualNetwork.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetwork.addressPrefixes
    }
  }
}

module apimSubnets 'subnets.bicep' = {
  name: 'apimSubnets'
  scope: resourceGroup()
  params: {
    subnets: virtualNetwork.subnets
    virtualNetworkName: apimVirtualNetwork.name
    tags: tags
  }
}
