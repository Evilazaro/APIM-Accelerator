targetScope = 'subscription'

param solutionName string
param environmentName string
param location string
param tags object 

var settings = loadYamlContent('../../../../infra/monitoring-settings.yaml')

resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = if (settings.provisionNew) {
  name: '${solutionName}-monitoring-${environmentName}-${location}-rg'
  location: location
  tags: tags
}

var resourceGroupName = (settings.provisionNew) ? monitoringRG.name : settings.resourceGroup.name
var logAnalyticsName = (settings.provisionNew)
  ? '${solutionName}-${uniqueString(subscription().id,resourceGroupName,environmentName,location)}-law'
  : settings.logAnalytics.name

module logAnalytics 'workspace/log-analytics-workspace-resource.bicep' = {
  name: 'deploy-log-analytics'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
  dependsOn: [
    monitoringRG
  ]
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = logAnalytics.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = logAnalytics.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
