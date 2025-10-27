targetScope = 'subscription'

param envName string
param location string

var settings = loadYamlContent('settings.yaml')
var corePlatformSettings = settings.core
var sharedSettings = settings.shared

var envTags = {
  environment: envName
}

var commonTags = union( settings.shared.tags, envTags)

var rgName = '${settings.solutionName}-${envName}-${location}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
  tags: commonTags
}

module sharedComponents '../src/shared/main.bicep' = {
  name: 'deploy-shared-components'
  scope: rg
  params: {
    solutionName: settings.solutionName
    location: location
    sharedSettings: sharedSettings
  }
}

output APPLICATION_INSIGHTS_RESOURCE_ID string = sharedComponents.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
output APPLICATION_INSIGHTS_NAME string = sharedComponents.outputs.APPLICATION_INSIGHTS_NAME
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = sharedComponents.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY

module corePlatform '../src/core/main.bicep' = {
  name: 'deploy-core-platform'
  scope: rg
  params: {
    solutionName: settings.solutionName
    location: location
    tags: union(commonTags, corePlatformSettings.tags)
    logAnalyticsWorkspaceId: sharedComponents.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    ApplicationInsightsResourceId: sharedComponents.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
    apiManagementSettings: corePlatformSettings.apiManagement
  }
  dependsOn: [
    sharedComponents
  ]
}
