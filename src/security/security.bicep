param location string

param networkName string

param subnetName string

param networkResourceGroup string

param storageAccountName string

param monitoringResourceGroup string

param enableDiagnostics bool

@description('Resource identifier of Log Analytics Workspace for collecting VNet diagnostic logs and metrics')
param logAnalyticsWorkspaceId string

@description('Resource identifier of Storage Account for archiving VNet diagnostic data')
param diagnosticStorageAccountId string

param datetime string = utcNow('yyyyMMddHHmmss')

var settings = loadYamlContent('../../infra/settings/security.yaml')

resource privateEndPointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: '${networkName}/${subnetName}'
  scope: resourceGroup(networkResourceGroup)
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: '${settings.keyVault.name}-${uniqueString(subscription().id, resourceGroup().id, settings.keyVault.name)}'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    accessPolicies: []
  }
}

resource keyVaultDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: keyVault
  name: '${keyVault.name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
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
  dependsOn: [
    keyVault
  ]
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: settings.keyVault.name
  location: location
  properties: {
    subnet: {
      id: privateEndPointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${settings.keyVault.name}-plsc'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
  scope: resourceGroup(monitoringResourceGroup)
}

resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: storageAccount.name
  location: location
  properties: {
    subnet: {
      id: privateEndPointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${storageAccount.name}-plsc'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}
