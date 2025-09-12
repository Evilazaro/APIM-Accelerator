param location string
param virtualNetworkName string
param networkResourceGroup string
param apimSubnetName string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  name: '${virtualNetworkName}/${apimSubnetName}'
  scope: resourceGroup(networkResourceGroup)
}

var apimSettings = loadYamlContent('../../infra/settings/apim.yaml')

resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apimSettings.name
  location: location
  sku: {
    capacity: apimSettings.sku.capacity
    name: apimSettings.sku.name
  }
  identity: {
    type: apimSettings.identity.type
  }
  properties: {
    virtualNetworkType: 'Internal'
    publisherEmail: apimSettings.publisherEmail
    publisherName: apimSettings.publisherName
    virtualNetworkConfiguration: {
      subnetResourceId: subnet.id
    }
  }
}
