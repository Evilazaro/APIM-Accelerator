import * as IdentityTypes from '../shared/identity-types.bicep'

param location string
param logAnalytics LogAnalyticsSettings
param appInsights AppInsightsSettings
param publicNetworkAccess bool
param tags object

type LogAnalyticsSettings = {
  name: string
  identity: IdentityTypes.Identity
}

type AppInsightsSettings = {
  name: string
}

resource apimStorageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'apimacceleratorstorage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: publicNetworkAccess ? 'Disabled' : 'Enabled'
    allowBlobPublicAccess: publicNetworkAccess ? false : true
  }
}

resource apimLogAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalytics.name
  location: location
  tags: tags
  identity: {
    type: logAnalytics.identity.type
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = apimLogAnalytics.name

resource apimAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights.name
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: apimLogAnalytics.id
  }
}

output AZURE_APPLICATION_INSIGHTS_NAME string = apimAppInsights.name

resource apiAppInsightsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apimAppInsights
  name: '${apimAppInsights.name}-diagnostics'
  properties: {
    workspaceId: apimLogAnalytics.id
    storageAccountId: apimStorageAccount.id
    logs: [
      {
        category: 'AppRequests'
        enabled: true
      }
      {
        category: 'AppDependencies'
        enabled: true
      }
      {
        category: 'AppExceptions'
        enabled: true
      }
      {
        category: 'AppPageViews'
        enabled: true
      }
      {
        category: 'AppPerformanceCounters'
        enabled: true
      }
      {
        category: 'AppAvailabilityResults'
        enabled: true
      }
      {
        category: 'AppTraces'
        enabled: true
      }
      {
        category: 'AppEvents'
        enabled: true
      }
      {
        category: 'AppMetrics'
        enabled: true
      }
      {
        category: 'AppBrowserTimings'
        enabled: true
      }
      {
        category: 'AppSystemEvents'
        enabled: true
      }
      {
        category: 'OTelResources'
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
