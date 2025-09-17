import * as SubnetSettings from '../shared/networking-types.bicep'

param location string
param virtualNetworkName string
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
  dependsOn: [
    apimNsg
    apimNsgDiagnostics
  ]
}

output AZURE_API_MANAGEMENT_SUBNET_ID string = apimSubnet.id
output AZURE_API_MANAGEMENT_SUBNET_NAME string = apimSubnet.name

resource appGwNsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: subnets.applicationGateway.networkSecurityGroup.name
  location: location
  tags: tags
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
