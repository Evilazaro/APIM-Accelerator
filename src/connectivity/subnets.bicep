import * as SubnetSettings from '../shared/network-types.bicep'

param location string
param virtualNetworkName string
param apimAppGwPipName string
param subnets SubnetSettings.Subnets
param tags object

resource apimAppGwPip 'Microsoft.Network/publicIPAddresses@2024-07-01' existing = {
  name: apimAppGwPipName
  scope: resourceGroup()
}

resource privateEndPointNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.privateEndpoint.networkSecurityGroup.name
  location: location
  tags: tags
  dependsOn: [
    apimAppGwPip
  ]
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.privateEndpoint.name}'
  properties: {
    addressPrefix: subnets.privateEndpoint.addressPrefix
    networkSecurityGroup: {
      id: privateEndPointNsg.id
    }
  }
  dependsOn: [
    apimAppGwPip
  ]
}

output AZURE_PRIVATE_ENDPOINT_SUBNET_ID string = privateEndpointSubnet.id
output AZURE_PRIVATE_ENDPOINT_SUBNET_NAME string = privateEndpointSubnet.name

resource apimNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.apiManagement.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowApimManagement'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'ApiManagement'
          protocol: 'Tcp'
          destinationPortRange: '3443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureLoadBalancer'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'AzureLoadBalancer'
          protocol: 'Tcp'
          destinationPortRange: '6390'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowAzureTrafficManager'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'AzureTrafficManager'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
      {
        name: 'AllowStorage'
        properties: {
          priority: 2000
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'Storage'
        }
      }
      {
        name: 'AllowSql'
        properties: {
          priority: 2010
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '1433'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'SQL'
        }
      }
      {
        name: 'AllowKeyVault'
        properties: {
          priority: 2020
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRange: '443'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureKeyVault'
        }
      }
      {
        name: 'AllowMonitor'
        properties: {
          priority: 2030
          sourceAddressPrefix: 'VirtualNetwork'
          protocol: 'Tcp'
          destinationPortRanges: ['1886', '443']
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: 'AzureMonitor'
        }
      }
    ]
  }
  dependsOn: [
    apimAppGwPip
  ]
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.apiManagement.name}'
  properties: {
    addressPrefix: subnets.apiManagement.addressPrefix
    networkSecurityGroup: {
      id: apimNsg.id
    }
  }
  dependsOn: [
    apimAppGwPip
  ]
}

output AZURE_API_MANAGEMENT_SUBNET_ID string = apimSubnet.id
output AZURE_API_MANAGEMENT_SUBNET_NAME string = apimSubnet.name

resource appGwNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.applicationGateway.networkSecurityGroup.name
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHealthProbes'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowClientTrafficToSubnet'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: subnets.applicationGateway.addressPrefix
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowClientTrafficToFrontendIP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '${apimAppGwPip.properties.ipAddress}/32'
          access: 'Allow'
          priority: 111
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancer'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
  dependsOn: [
    apimAppGwPip
  ]
}

resource azureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.azureFirewall.name}'
  properties: {
    addressPrefix: subnets.azureFirewall.addressPrefix
  }
  dependsOn: [
    apimAppGwPip
  ]
}

output AZURE_AZURE_FIREWALL_SUBNET_ID string = azureFirewallSubnet.id
output AZURE_AZURE_FIREWALL_SUBNET_NAME string = azureFirewallSubnet.name

resource appGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.applicationGateway.name}'
  properties: {
    addressPrefix: subnets.applicationGateway.addressPrefix
    networkSecurityGroup: {
      id: appGwNsg.id
    }
  }
  dependsOn: [
    apimAppGwPip
    appGwNsg
  ]
}

output AZURE_APPLICATION_GATEWAY_SUBNET_ID string = appGwSubnet.id
output AZURE_APPLICATION_GATEWAY_SUBNET_NAME string = appGwSubnet.name
