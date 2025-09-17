import * as Networking from '../shared/networking-types.bicep'

param location string
param networking Networking.Settings
param logAnalytcsWorkspaceName string
param monitoringStorageAccountName string
param monitoringResourceGroup string
param tags object

var vnetSettings = networking.virtualNetwork

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalytcsWorkspaceName
  scope: resourceGroup(monitoringResourceGroup)
}

resource monitoringStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: monitoringStorageAccountName
  scope: resourceGroup(monitoringResourceGroup)
}

resource apimVnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetSettings.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetSettings.addressPrefixes
    }
  }
}

output AZURE_VNET_NAME string = apimVnet.name
output AZURE_VNET_ID string = apimVnet.id

module apimSubnets 'subnets.bicep' = {
  name: 'Subnets'
  scope: resourceGroup()
  params: {
    location: location
    subnets: vnetSettings.subnets
    virtualNetworkName: apimVnet.name
    logAnalytcsWorkspaceName: logAnalytcsWorkspaceName
    monitoringStorageAccountName: monitoringStorageAccountName
    monitoringResourceGroup: monitoringResourceGroup
    tags: tags
  }
  dependsOn: [
    apimVnet
  ]
}

output AZURE_API_MANAGEMENT_SUBNET_ID string = apimSubnets.outputs.AZURE_API_MANAGEMENT_SUBNET_ID
output AZURE_API_MANAGEMENT_SUBNET_NAME string = apimSubnets.outputs.AZURE_API_MANAGEMENT_SUBNET_NAME

resource vnetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vnet-diag'
  scope: apimVnet
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: monitoringStorageAccount.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
