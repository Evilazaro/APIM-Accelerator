param name string
param location string
param tags object
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnet.id
    }
    
  }
}
