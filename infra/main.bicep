targetScope = 'subscription'
param environmentName string
param location string

var settings = loadYamlContent('./settings.yaml')

var resourceGroupName = (empty(settings.resourceGroup.name))
  ? '${settings.solutionName}-${environmentName}-${location}-rg'
  : settings.resourceGroup.name

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: settings.tags
}

module monitoring '../src/shared/resources/monitoring/monitoring.bicep' = {
  name: 'deploy-monitoring'
  scope: resourceGroup
  params: {
    solutionName: settings.solutionName
    location: location
    tags: settings.tags
  }
}

output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
output AZURE_APPLICATION_INSIGHTS_ID string = monitoring.outputs.AZURE_APPLICATION_INSIGHTS_ID
output AZURE_APPLICATION_INSIGHTS_NAME string = monitoring.outputs.AZURE_APPLICATION_INSIGHTS_NAME

module core '../src/core/core.bicep' = {
  name: 'deploy-core'
  scope: resourceGroup
  params: {
    solutionName: settings.solutionName
    location: location
    appInsightsInstrumentationKey: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
    appInsightsResourceId: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_ID
    appInsightsConnectionString: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_CONNECTION_STRING
    logAnalyticsWorkspaceId: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    tags: settings.tags
  }
}

// output AZURE_API_MANAGEMENT_ID string = core.outputs.AZURE_API_MANAGEMENT_ID
// output AZURE_API_MANAGEMENT_NAME string = core.outputs.AZURE_API_MANAGEMENT_NAME
// output AZURE_API_CENTER_ID string = core.outputs.AZURE_API_CENTER_ID
// output AZURE_API_CENTER_NAME string = core.outputs.AZURE_API_CENTER_NAME

// var providersSettings = loadYamlContent('./providers.yaml')

// module provider '../src/providers/provider.bicep' = {
//   name: 'deploy-providers'
//   scope: resourceGroup
//   params: {
//     apiManagementName: core.outputs.AZURE_API_MANAGEMENT_NAME
//     providersSettings: providersSettings
//   }
// }

// module developerPortal '../src/providers/apim-developer-portal.bicep' = {
//   name: 'deploy-developer-portal'
//   scope: resourceGroup
//   params: {
//     apiManagementName: core.outputs.AZURE_API_MANAGEMENT_NAME
//   }
// }
