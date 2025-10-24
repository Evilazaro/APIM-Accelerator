metadata name = 'Log Analytics Workspaces'
metadata description = 'This module deploys a Log Analytics Workspace with comprehensive diagnostic settings following Azure monitoring best practices.'

param name string

param location string

param storageAccountId string

param tags object

@allowed([
  'Free'
  'Standard'
  'Premium'
  'PerNode'
  'PerGB2018'
  'Standalone'
  'CapacityReservation'
])
param sku string = 'PerGB2018'

@minValue(7)
@maxValue(730)
param retentionInDays int = 90

@minValue(-1)
param dailyQuotaGb int = -1

param publicNetworkAccessForQuery string = 'Enabled'

param publicNetworkAccessForIngestion string = 'Enabled'

param diagnosticSettingsName string = 'diagnostic-settings'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    workspaceCapping: dailyQuotaGb != -1
      ? {
          dailyQuotaGb: dailyQuotaGb
        }
      : null
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: logAnalyticsWorkspace
  properties: {
    storageAccountId: storageAccountId

    workspaceId: logAnalyticsWorkspace.id

    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]

    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        timeGrain: null
      }
    ]
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.name
