import { Shared } from 'common-types.bicep'

param solutionName string
param location string
param sharedSettings Shared

var monitoringSettings = sharedSettings.monitoring

module monitoring 'monitoring/main.bicep' = {
  name: 'deploy-monitoring-resources'
  params: {
    location: location
    tags: union(sharedSettings.tags, monitoringSettings.tags)
    solutionName: solutionName
    monitoringSettings: monitoringSettings
  }
}

output AZURE_STORAGE_ACCOUNT_ID string = monitoring.outputs.AZURE_STORAGE_ACCOUNT_ID
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
output APPLICATION_INSIGHTS_RESOURCE_ID string = monitoring.outputs.APPLICATION_INSIGHTS_RESOURCE_ID
output APPLICATION_INSIGHTS_NAME string = monitoring.outputs.APPLICATION_INSIGHTS_NAME
output APPLICATION_INSIGHTS_INSTRUMENTATION_KEY string = monitoring.outputs.APPLICATION_INSIGHTS_INSTRUMENTATION_KEY

var inventorySettings = sharedSettings.inventory

module inventory 'inventory/main.bicep' = {
  name: 'deploy-inventory-components'
  scope: resourceGroup()
  params: {
    solutionName: solutionName
    tags: union(sharedSettings.tags, inventorySettings.tags)
    inventorySettings: inventorySettings
  }
}
