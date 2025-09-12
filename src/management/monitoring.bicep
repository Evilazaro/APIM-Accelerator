@description('Azure region where monitoring resources (Log Analytics, Storage, Application Insights) will be deployed')
param location string

@description('Resource tags to be applied to all monitoring infrastructure resources for organization and cost tracking')
param tags object

@description('Timestamp used to ensure uniqueness of resource deployments')
param dateTime string = utcNow('yyyyMMddHHmmss')

var settings = loadYamlContent('../../infra/settings/monitor.yaml')

@description('Log Analytics workspace for centralized logging, monitoring, and analytics across all APIM and related infrastructure')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: settings.logAnalytics.name
  location: location
  tags: tags
}

@description('Resource ID of the Log Analytics workspace for use in diagnostic settings and monitoring configurations')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

@description('Name of the Log Analytics workspace for reference in monitoring configurations')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.name

@description('Storage account for diagnostic logs, audit logs, and long-term retention of monitoring data with private network access')
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: settings.storageAccount.name
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

@description('Resource ID of the diagnostic storage account for use in audit logging and long-term data retention')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id

@description('Name of the diagnostic storage account for reference in storage configurations')
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.name

@description('Application Insights for application performance monitoring, request tracking, and telemetry collection integrated with Log Analytics')
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: settings.applicationInsights.name
  location: location
  tags: tags
  kind: 'other'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

@description('Diagnostic settings to route Application Insights logs and metrics to Log Analytics workspace and storage account for centralized monitoring')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (settings.diagnostics.enable) {
  scope: appInsights
  name: '${settings.applicationInsights.name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspace.id) ? null : logAnalyticsWorkspace.id
    storageAccountId: empty(storageAccount.id) ? null : storageAccount.id
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
