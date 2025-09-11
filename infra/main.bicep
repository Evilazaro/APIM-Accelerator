targetScope = 'subscription'

@description('Location for all resources')
param location string

param dateTime string = utcNow('yyyyMMddHHmmss')

var resourceOgranization = loadYamlContent('settings/resourceOrganization.yaml')

@description('Resource Group for monitoring resources')
resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceOgranization.resourceGroups.monitoring
  location: location
  tags: resourceOgranization.tags
}

@description('Resource group for network infrastructure resources loaded from external YAML configuration')
resource networkRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceOgranization.resourceGroups.networking
  location: location
  tags: resourceOgranization.tags
}

@description('Deploy the monitoring resources')
module monitoring '../src/management/monitoring.bicep' = {
  name: 'monitoring-${dateTime}'
  scope: monitoringRG
  params: {
    location: location
    tags: resourceOgranization.tags
  }
}

@description('Deploy the network resources')
module networking '../src/network/networking.bicep' = {
  name: 'network-${dateTime}'
  scope: networkRG
  params: {
    location: location
    logAnalyticsWorkspaceId: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID
    diagnosticStorageAccountId: monitoring!.outputs.AZURE_STORAGE_ACCOUNT_ID
    tags: resourceOgranization.tags
  }
  dependsOn: [
    monitoring
  ]
}
