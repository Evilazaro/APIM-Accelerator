param virtualNetworkName string
param subnets SubnetSettings
param tags object

type Subnet = {
  name: string
  addressPrefix: string
  networkSecurityGroup: NetworkSecurityGroup
}

type NetworkSecurityGroup = {
  name: string
}

type SubnetSettings = {
  privateEndpoint: Subnet
  apiManagement: Subnet
  applicationGateway: Subnet
  azureFirewall: Subnet
}

resource nsgPrivateEndpoint 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.privateEndpoint.networkSecurityGroup.name
  tags: tags
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.privateEndpoint.name}'
  properties: {
    addressPrefix: subnets.privateEndpoint.addressPrefix
    networkSecurityGroup: {
      id: nsgPrivateEndpoint.id
    }
  }
}

resource nsgApiManagement 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.apiManagement.networkSecurityGroup.name
  tags: tags
}

resource apiManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.apiManagement.name}'
  properties: {
    addressPrefix: subnets.apiManagement.addressPrefix
    networkSecurityGroup: {
      id: nsgApiManagement.id
    }
  }
}

resource nsgApplicationGateway 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.applicationGateway.networkSecurityGroup.name
  tags: tags
}

resource applicationGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.applicationGateway.name}'
  properties: {
    addressPrefix: subnets.applicationGateway.addressPrefix
    networkSecurityGroup: {
      id: nsgApplicationGateway.id
    }
  }
}

resource azureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.azureFirewall.name}'
  properties: {
    addressPrefix: subnets.azureFirewall.addressPrefix
  }
}
