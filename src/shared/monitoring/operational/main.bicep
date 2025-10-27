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

param storageAccountResourceId string

param tags object

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
  name: '${logAnalyticsWorkspace.name}-diag'
  scope: logAnalyticsWorkspace
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    storageAccountId: storageAccountResourceId
    logs: [
      {
        enabled: true
        categoryGroup: 'allLogs'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'allMetrics'
      }
    ]
  }
}
