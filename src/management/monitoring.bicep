@description('Location for all resources')
param location string

@description('Tags for all resources')
param tags object

param dateTime string = utcNow('yyyyMMddHHmmss')

var settings = loadYamlContent('../../infra/settings/monitor.yaml')

@description('Log Analytics Workspace resource')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: settings.logAnalytics.name
  location: location
  tags: tags
}

@description('Log Analytics Workspace ID output')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.id

@description('Log Analytics Workspace Name output')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.name

@description('Storage Account Resource')
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = if (settings.storageAccount.enabled) {
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

@description('Storage Account ID output')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount.id

@description('Storage Account Name output')
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount.name

@description('Application Insights resource')
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

@description('Diagnostics settings for the Application Insights resource')
resource diagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (settings.diagnostics.enabled) {
  scope: appInsights
  name: '${settings.applicationInsights.name}-diagnostics'
  properties: {
    workspaceId: empty(logAnalyticsWorkspace.id) ? null : logAnalyticsWorkspace.id
    storageAccountId: empty(storageAccount.id) ? null : storageAccount.id
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
    appInsights
  ]
}
