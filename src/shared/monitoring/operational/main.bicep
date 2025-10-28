import { generateStorageAccountName } from '../../constants.bicep'

param name string
param location string
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param skuName string = 'PerGB2018'

@allowed([
  'SystemAssigned'
  'UserAssigned'
  'None'
])
param identityType string

param userAssignedIdentities array

param tags object

// Optimized: Use centralized function for storage account naming
var storageAccountName = generateStorageAccountName(name, uniqueString(resourceGroup().id))

// Optimized: Constants for reusable values
var storageSkuName = 'Standard_LRS'
var storageKind = 'StorageV2'
var diagnosticSettingsSuffix = '-diag'
var allLogsCategory = 'allLogs'
var allMetricsCategory = 'allMetrics'

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName
  }
  kind: storageKind
  tags: tags
}

output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  identity: (identityType != 'None')
    ? {
        type: identityType
        userAssignedIdentities: (identityType == 'UserAssigned' && !empty(userAssignedIdentities))
          ? toObject(userAssignedIdentities, id => id, id => {})
          : null
      }
    : null
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${logAnalyticsWorkspace.name}${diagnosticSettingsSuffix}'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccount.id
    logs: [
      {
        enabled: true
        categoryGroup: allLogsCategory
      }
    ]
    metrics: [
      {
        enabled: true
        category: allMetricsCategory
      }
    ]
  }
}
