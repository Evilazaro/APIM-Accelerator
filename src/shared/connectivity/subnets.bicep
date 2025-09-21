import * as SubnetSettings from '../customtypes/networking-types.bicep'

param location string
param virtualNetworkName string
param subnets SubnetSettings.Settings.virtualNetwork.subnets
param logAnalytcsWorkspaceName string
param monitoringStorageAccountName string
param monitoringResourceGroup string
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalytcsWorkspaceName
  scope: resourceGroup(monitoringResourceGroup)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: monitoringStorageAccountName
  scope: resourceGroup(monitoringResourceGroup)
}

resource apimSubnetNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
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
}

resource apimSubnetNsgDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'apim-nsg-diag'
  scope: apimSubnetNsg
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: storageAccount.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.apiManagement.name}'
  properties: {
    addressPrefix: subnets.apiManagement.addressPrefix
    networkSecurityGroup: {
      id: apimSubnetNsg.id
    }
  }
  dependsOn: [
    apimSubnetNsg
    apimSubnetNsgDiag
  ]
}

output AZURE_APIM_SUBNET_NAME string = apimSubnet.name

resource appGatewayNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.applicationGateway.networkSecurityGroup.name
  location: location
  tags: tags
}

resource appGwSubnetNsgDia 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appgw-nsg-diag'
  scope: appGatewayNsg
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: storageAccount.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource appGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.applicationGateway.name}'
  properties: {
    addressPrefix: subnets.applicationGateway.addressPrefix
    networkSecurityGroup: {
      id: appGatewayNsg.id
    }
  }
}
