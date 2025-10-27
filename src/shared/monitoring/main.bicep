import { Monitoring } from '../common-types.bicep'

param solutionName string
param location string
param monitoringSettings Monitoring
param tags object

var logAnalyticsSettings = monitoringSettings.logAnalytics

var logAnalyticsWorkspaceName = (!empty(logAnalyticsSettings.name))
  ? logAnalyticsSettings.name
  : '${solutionName}-${uniqueString(subscription().id, resourceGroup().id,resourceGroup().name, solutionName, location)}-law'

module operational 'operational/main.bicep' = {
  name: 'deploy-operational-insights'
  scope: resourceGroup()
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    identityType: logAnalyticsSettings.identity.type
    userAssignedIdentities: logAnalyticsSettings.identity.userAssignedIdentities
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

var applicationInsightsSettings = monitoringSettings.applicationInsights

var appInsightsName = (!empty(applicationInsightsSettings.name))
  ? applicationInsightsSettings.name
  : '${solutionName}-${uniqueString(subscription().id, resourceGroup().id,resourceGroup().name, solutionName, location)}-ai'

module insights 'insights/main.bicep' = {
  name: 'deploy-application-insights'
  scope: resourceGroup()
  params: {
    name: appInsightsName
    location: location
    tags: tags
    logAnalyticsWorkspaceResourceId: operational.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    storageAccountResourceId: operational.outputs.AZURE_STORAGE_ACCOUNT_ID
  }
}

output APPLICATION_INSIGHTS_RESOURCE_ID string = insights.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
output APPLICATION_INSIGHTS_NAME string = insights.outputs.APPLICATION_INSIGHTS_NAME
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = insights.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
