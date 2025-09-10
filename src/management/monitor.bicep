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
