param location string
param logAnalytics LogAnalyticsSettings
param appInsights AppInsightsSettings
param tags object

type LogAnalyticsSettings = {
  name: string
  identity: {
    type: 'SystemAssigned' | 'UserAssigned' | 'None'
    userAssignedIdentities: UserAssignedIdentity[]
  }
}

type UserAssignedIdentity = {
  name: string
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
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: 'Disabled'
  }
  tags: tags
}

resource apimLogAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalytics.name
  location: location
  tags: tags
  identity: {
    type: logAnalytics.identity.type
  }
}

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
