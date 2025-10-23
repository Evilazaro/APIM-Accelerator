param solutionName string
param location string
param tags object

var settings = loadYamlContent('../../../../infra/monitoring.yaml')

var logAnalyticsName = (empty(settings.logAnalytics.name))
  ? '${solutionName}-${uniqueString(subscription().id, resourceGroup().id, resourceGroup().name, solutionName,location)}-law'
  : settings.logAnalytics.name

module operationsManagement 'log-analytics-workspace-resource.bicep' = {
  name: 'deploy-log-analytics'
  scope: resourceGroup()
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = operationsManagement.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = operationsManagement.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME

var appInsightsName = (empty(settings.applicationInsights.name))
  ? '${solutionName}-${uniqueString(subscription().id, resourceGroup().id, resourceGroup().name, solutionName,location)}-appi'
  : settings.applicationInsights.name

module insights 'app-insights.bicep' = {
  name: 'deploy-application-insights'
  scope: resourceGroup()
  params: {
    name: appInsightsName
    location: location
    workspaceResourceId: operationsManagement.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    tags: tags
  }
}

output AZURE_APPLICATION_INSIGHTS_ID string = insights.outputs.AZURE_APPLICATION_INSIGHTS_ID
output AZURE_APPLICATION_INSIGHTS_NAME string = insights.outputs.AZURE_APPLICATION_INSIGHTS_NAME
output AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = insights.outputs.AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
