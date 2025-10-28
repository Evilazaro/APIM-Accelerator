targetScope = 'subscription'

param envName string
param location string

// Optimized: Configuration constants
var settingsFile = 'settings.yaml'
var resourceGroupSuffix = 'rg'
var managedByValue = 'bicep'

var settings = loadYamlContent(settingsFile)

// Optimized: Consolidated tag creation with environment metadata
var commonTags = union(settings.shared.tags, {
  environment: envName
  managedBy: managedByValue
})

// Optimized: Consistent naming pattern for resource group
var rgName = '${settings.solutionName}-${envName}-${location}-${resourceGroupSuffix}'

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
    sharedSettings: settings.shared
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
    tags: union(commonTags, settings.core.tags)
    logAnalyticsWorkspaceId: shared.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    storageAccountResourceId: shared.outputs.AZURE_STORAGE_ACCOUNT_ID
    applicationInsIghtsResourceId: shared.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
    apiManagementSettings: settings.core.apiManagement
  }
}

module inventory '../src/inventory/main.bicep' = {
  name: 'deploy-inventory-components'
  scope: resourceGroup(rgName)
  params: {
    solutionName: settings.solutionName
    inventorySettings: settings.inventory
    apiManagementName: core.outputs.API_MANAGEMENT_NAME
    apiManagementResourceId: core.outputs.API_MANAGEMENT_RESOURCE_ID
    tags: settings.shared.tags
  }
}
