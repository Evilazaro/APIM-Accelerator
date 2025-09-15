import * as Network from '../shared/network-types.bicep'
param location string
param virtualNetwork Network.VirtualNetwork
param tags object

resource apimPublicIp 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'apim-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  zones: ['1', '2', '3']
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource apimVnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: virtualNetwork.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetwork.addressPrefixes
    }
  }
  dependsOn: [
    apimPublicIp
  ]
}

output AZURE_VNET_NAME string = apimVnet.name
output AZURE_VNET_ID string = apimVnet.id

module apimSubnets 'subnets.bicep' = {
  name: 'Subnets'
  scope: resourceGroup()
  params: {
    location: location
    subnets: virtualNetwork.subnets
    virtualNetworkName: apimVnet.name
    apimAppGwPipName: apimPublicIp.name
    tags: tags
  }
  dependsOn: [
    apimVnet
  ]
}

output AZURE_PRIVATE_ENDPOINT_SUBNET_ID string = apimSubnets.outputs.AZURE_PRIVATE_ENDPOINT_SUBNET_ID
output AZURE_PRIVATE_ENDPOINT_SUBNET_NAME string = apimSubnets.outputs.AZURE_PRIVATE_ENDPOINT_SUBNET_NAME

output AZURE_API_MANAGEMENT_SUBNET_ID string = apimSubnets.outputs.AZURE_API_MANAGEMENT_SUBNET_ID
output AZURE_API_MANAGEMENT_SUBNET_NAME string = apimSubnets.outputs.AZURE_API_MANAGEMENT_SUBNET_NAME

resource apimFirewall 'Microsoft.Network/azureFirewalls@2024-07-01' = {
  name: 'azfw'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: apimSubnets.outputs.AZURE_AZURE_FIREWALL_SUBNET_ID
          }
          publicIPAddress: {
            id: apimPublicIp.id
          }
        }
      }
    ]
  }
  dependsOn: [
    apimVnet
    apimSubnets
  ]
}
