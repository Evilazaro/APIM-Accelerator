targetScope = 'subscription'

param envName string
param location string

var settings = loadYamlContent('settings.yaml')
var corePlatformSettings = settings.core
var sharedSettings = settings.shared
var inventorySettings = settings.inventory

var envTags = {
  environment: envName
}

var commonTags = union(settings.shared.tags, envTags)

var rgName = '${settings.solutionName}-${envName}-${location}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
  tags: commonTags
}

module shared '../src/shared/main.bicep' = {
  name: 'deploy-shared-components'
  scope: rg
  params: {
    solutionName: settings.solutionName
    location: location
    sharedSettings: sharedSettings
  }
}

output APPLICATION_INSIGHTS_RESOURCE_ID string = shared.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
output APPLICATION_INSIGHTS_NAME string = shared.outputs.APPLICATION_INSIGHTS_NAME
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = shared.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY
output AZURE_STORAGE_ACCOUNT_ID string = shared.outputs.AZURE_STORAGE_ACCOUNT_ID

module core '../src/core/main.bicep' = {
  name: 'deploy-core-platform'
  scope: resourceGroup(rgName)
  params: {
    solutionName: settings.solutionName
    location: location
    tags: union(commonTags, corePlatformSettings.tags)
    logAnalyticsWorkspaceId: shared.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    storageAccountResourceId: shared.outputs.AZURE_STORAGE_ACCOUNT_ID
    ApplicationInsightsResourceId: shared.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
    apiManagementSettings: corePlatformSettings.apiManagement
  }
  dependsOn: [
    shared
  ]
}

module inventory '../src/inventory/main.bicep' = {
  name: 'deploy-inventory-components'
  scope: resourceGroup(rgName)
  params: {
    solutionName: settings.solutionName
    inventorySettings: inventorySettings
    apiManagementName: core.outputs.API_MANAGEMENT_NAME
    apiManagementResourceId: core.outputs.API_MANAGEMENT_RESOURCE_ID
    tags: sharedSettings.tags
  }
  dependsOn: [
    core
  ]
}
