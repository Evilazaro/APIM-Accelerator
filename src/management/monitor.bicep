targetScope = 'subscription'

@description('Location for all resources')
param location string

@description('Tags for all resources')
param tags object

param dateTime string = utcNow('yyyyMMddHHmmss')

var settings = loadYamlContent('../../infra/settings/monitor.yaml')

@description('Resource Group for monitoring resources')
resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.resourceGroup.name
  location: location
}

@description('Deploy the monitoring resources')
module logAnalyticsWorkspace 'modules/logAnalytics-workspace.bicep' = {
  name: 'logAnalytics-${dateTime}'
  scope: monitoringRG
  params: {
    name: settings.logAnalytics.name
    location: location
    tags: tags
  }
}

@description('Log Analytics Workspace ID output')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalyticsWorkspace.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

@description('Log Analytics Workspace Name output')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalyticsWorkspace.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME

@description('Deploy Storage Account for Application Insights diagnostics (if enabled)')
module storageAccount 'modules/storage-account.bicep' = if (settings.storageAccount.enabled) {
  name: 'appInsightsStorage'
  scope: monitoringRG
  params: {
    name: settings.storageAccount.name
    location: location
    sku: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    tags: tags
  }
}

@description('Storage Account ID output')
output AZURE_STORAGE_ACCOUNT_ID string = storageAccount!.outputs.AZURE_STORAGE_ACCOUNT_ID

@description('Storage Account Name output')
output AZURE_STORAGE_ACCOUNT_NAME string = storageAccount!.outputs.AZURE_STORAGE_ACCOUNT_NAME

@description('Deploy Application Insights (if enabled)')
module applicationInsights 'modules/application-insights.bicep' = if (settings.applicationInsights.enabled) {
  name: 'applicationInsights-${dateTime}'
  scope: monitoringRG
  params: {
    name: settings.applicationInsights.name
    location: location
    enableDiagnostics: settings.diagnostics.enabled
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    diagnosticStorageAccountId: storageAccount!.outputs.AZURE_STORAGE_ACCOUNT_ID
    type: 'web'
    requestSource: 'rest'
    tags: tags
  }
}

@description('Application Insights ID output')
output AZURE_APPLICATION_INSIGHTS_ID string = applicationInsights!.outputs.AZURE_APPLICATION_INSIGHTS_ID

@description('Application Insights Name output')
output AZURE_APPLICATION_INSIGHTS_NAME string = applicationInsights!.outputs.AZURE_APPLICATION_INSIGHTS_NAME

@description('Application Insights Instrumentation Key output')
output AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = applicationInsights!.outputs.AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
