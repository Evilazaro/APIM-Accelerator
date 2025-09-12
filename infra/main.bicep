targetScope = 'subscription'

@description('Azure region where all resources will be deployed (e.g., eastus, westus2)')
param location string

@description('Timestamp used to ensure uniqueness of deployment names')
param dateTime string = utcNow('yyyyMMddHHmmss')

var resourceOgranization = loadYamlContent('settings/resourceOrganization.yaml')

@description('Resource group that will contain monitoring and observability resources such as Log Analytics workspace and storage accounts')
resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceOgranization.resourceGroups.monitoring
  location: location
  tags: resourceOgranization.tags
}

@description('Resource group that will contain network infrastructure resources such as virtual networks, subnets, and network security groups')
resource networkRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceOgranization.resourceGroups.networking
  location: location
  tags: resourceOgranization.tags
}

@description('Deploys monitoring and observability infrastructure including Log Analytics workspace, diagnostic storage account, and related monitoring resources')
module monitoring '../src/management/monitoring.bicep' = {
  name: 'monitoring-${dateTime}'
  scope: monitoringRG
  params: {
    location: location
    tags: resourceOgranization.tags
  }
}

@description('Deploys network infrastructure including virtual networks, subnets, NSGs, and configures diagnostic logging integration with monitoring resources')
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
