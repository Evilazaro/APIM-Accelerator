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

resource monStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
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
  name: 'subnets'
  scope: resourceGroup()
  params: {
    location: location
    virtualNetworkName: apimVnet.name
    subnets: networking.virtualNetwork.subnets
    logAnalytcsWorkspaceName: logAnalytcsWorkspaceName
    monitoringStorageAccountName: monitoringStorageAccountName
    monitoringResourceGroup: monitoringResourceGroup
    tags: tags
  }
  dependsOn: [
    apimVnet
  ]
}
output AZURE_APIM_SUBNET_NAME string = apimSubnets.outputs.AZURE_APIM_SUBNET_NAME

resource vnetDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'vnet-diag'
  scope: apimVnet
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: monStorageAccount.id
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
