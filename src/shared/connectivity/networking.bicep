import * as Networking from '../customtypes/networking-types.bicep'

param location string
param networking Networking.Settings
param logAnalytcsWorkspaceName string
param monitoringStorageAccountName string
param monitoringResourceGroup string
param tags object

var vnetSettings = networking.virtualNetwork

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalytcsWorkspaceName
  scope: resourceGroup(monitoringResourceGroup)
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: monitoringStorageAccountName
  scope: resourceGroup(monitoringResourceGroup)
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetSettings.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vnetSettings.addressPrefixes
    }
  }
}

output AZURE_VNET_NAME string = virtualNetwork.name
output AZURE_VNET_ID string = virtualNetwork.id

module subnets 'subnets.bicep' = {
  name: 'subnets'
  scope: resourceGroup()
  params: {
    location: location
    virtualNetworkName: virtualNetwork.name
    subnets: networking.virtualNetwork.subnets
    logAnalytcsWorkspaceName: logAnalytcsWorkspaceName
    monitoringStorageAccountName: monitoringStorageAccountName
    monitoringResourceGroup: monitoringResourceGroup
    tags: tags
  }
  dependsOn: [
    virtualNetwork
  ]
}
output AZURE_APIM_SUBNET_NAME string = subnets.outputs.AZURE_APIM_SUBNET_NAME

resource vnetDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vnet-diag'
  scope: virtualNetwork
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: storageAccount.id
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

output NETWORKING_RESOURCE_GROUP_NANE string = resourceGroup().name
