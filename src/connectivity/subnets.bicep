import * as SubnetSettings from '../shared/networking-types.bicep'

param location string
param virtualNetworkName string
param apimAppGwPipName string
param subnets SubnetSettings.Subnets
param logAnalytcsWorkspaceName string
param monitoringStorageAccountName string
param monitoringResourceGroup string
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalytcsWorkspaceName
  scope: resourceGroup(monitoringResourceGroup)
}

resource monitoringStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: monitoringStorageAccountName
  scope: resourceGroup(monitoringResourceGroup)
}

resource apimAppGwPip 'Microsoft.Network/publicIPAddresses@2024-07-01' existing = {
  name: apimAppGwPipName
  scope: resourceGroup()
}

resource privateEndPointNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.privateEndpoint.networkSecurityGroup.name
  location: location
  tags: tags
}

resource privateEndPointDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'privateEndpoint-nsg-diag'
  scope: privateEndPointNsg
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: monitoringStorageAccount.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.privateEndpoint.name}'
  properties: {
    addressPrefix: subnets.privateEndpoint.addressPrefix
    networkSecurityGroup: {
      id: privateEndPointNsg.id
    }
  }
}

output AZURE_PRIVATE_ENDPOINT_SUBNET_ID string = privateEndpointSubnet.id
output AZURE_PRIVATE_ENDPOINT_SUBNET_NAME string = privateEndpointSubnet.name

resource apimNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.apiManagement.networkSecurityGroup.name
  location: location
  tags: tags
}

resource apimNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'apim-nsg-diag'
  scope: apimNsg
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: monitoringStorageAccount.id
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
      id: apimNsg.id
    }
  }
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
}

resource appGwNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'appGw-nsg-diag'
  scope: appGwNsg
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: monitoringStorageAccount.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource azureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: '${virtualNetworkName}/${subnets.azureFirewall.name}'
  properties: {
    addressPrefix: subnets.azureFirewall.addressPrefix
  }
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
}

output AZURE_APPLICATION_GATEWAY_SUBNET_ID string = appGwSubnet.id
output AZURE_APPLICATION_GATEWAY_SUBNET_NAME string = appGwSubnet.name
