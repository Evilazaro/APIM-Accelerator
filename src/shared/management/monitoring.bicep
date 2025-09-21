import * as Monitoring from '../customtypes/management-types.bicep'

@description('Azure region for monitoring resource deployment, aligned with landing zone regional strategy.')
param location string

@description('Monitoring configuration containing Log Analytics and Application Insights settings for APIM observability.')
param monitoring Monitoring.Settings

@description('Controls public network access to monitoring resources. Disable for zero-trust security compliance.')
param publicNetworkAccess bool

@description('Resource tags for governance, cost management, and operational tracking.')
param tags object

@description('Storage account for monitoring data retention, archival, and compliance requirements.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: 'apimacceleratorstorage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    accessTier: 'Hot'
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    allowBlobPublicAccess: publicNetworkAccess ? true : false
    networkAcls: {
      defaultAction: publicNetworkAccess ? 'Allow' : 'Deny'
      bypass: 'AzureServices'
    }
  }
}

@description('Storage account name for referencing in diagnostic settings and monitoring configurations.')
output AZURE_MONITORING_STORAGE_ACCOUNT_NAME string = storageAccount.name

@description('Diagnostic settings for storage account monitoring and operational observability.')
resource storageAccountDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${storageAccount.name}-diagnostics'
  scope: storageAccount
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: storageAccount.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Central Log Analytics workspace for logs, metrics, and security analytics across APIM Landing Zone.')
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: monitoring.logAnalytics.name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccessForIngestion: publicNetworkAccess ? 'Enabled' : 'Disabled'
    publicNetworkAccessForQuery: publicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

@description('Log Analytics workspace name for referencing in diagnostic settings and monitoring integrations.')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalytics.name

@description('Diagnostic settings for Log Analytics workspace self-monitoring and meta-observability.')
resource logAnalyticsDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${logAnalytics.name}-diagnostics'
  scope: logAnalytics
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: storageAccount.id
    logs: [
      {
        categoryGroup: 'AllLogs'
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

@description('Application Insights for performance monitoring, distributed tracing, and dependency analysis.')
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: monitoring.applicationInsights.name
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: publicNetworkAccess ? 'Enabled' : 'Disabled'
    publicNetworkAccessForQuery: publicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

@description('Application Insights name for telemetry integration across APIM and related services.')
output AZURE_APPLICATION_INSIGHTS_NAME string = appInsights.name

@description('Comprehensive diagnostic settings for Application Insights telemetry and performance monitoring.')
resource appInsightsDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appInsights
  name: '${appInsights.name}-diagnostics'
  properties: {
    workspaceId: logAnalytics.id
    storageAccountId: storageAccount.id
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

output MONITORING_RESOURCE_GROUP_NAME string = resourceGroup().name
