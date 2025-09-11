targetScope = 'subscription'

@description('Location for all resources')
param location string

param dateTime string = utcNow('yyyyMMddHHmmss')

var resourceOgranization = loadYamlContent('settings/resourceOrganization.yaml')

@description('Deploy the monitoring resources')
module monitoring '../src/management/monitor.bicep' = {
  name: 'monitoring-${dateTime}'
  params: {
    location: location
    tags: resourceOgranization.tags
  }
}

@description('Log Analytics Workspace ID output')
output AZURE_LOG_ANALYTICS_WORKSPACE_ID string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_ID

@description('Log Analytics Workspace Name output')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME

@description('Deploy the network resources')
module network '../src/network/network.bicep' = {
  name: 'network-${dateTime}'
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

@description('DDoS Protection Plan ID output')
output DDOS_PROTECTION_PLAN_ID string = network!.outputs.DDOS_PROTECTION_PLAN_ID

@description('DDoS Protection Plan Name output')
output DDOS_PROTECTION_PLAN_NAME string = network!.outputs.DDOS_PROTECTION_PLAN_NAME

@description('Virtual Network Name output')
output AZURE_VIRTUAL_NETWORK_NAME string = network.outputs.AZURE_VIRTUAL_NETWORK_NAME

@description('Virtual Network ID output')
output AZURE_VIRTUAL_NETWORK_ID string = network.outputs.AZURE_VIRTUAL_NETWORK_ID

@description('Azure Firewall Name output')
output AZURE_FIREWALL_NAME string = network!.outputs.AZURE_FIREWALL_NAME

@description('Azure Firewall ID output')
output AZURE_FIREWALL_ID string = network!.outputs.AZURE_FIREWALL_ID

@description('Azure Bastion Host ID output')
output AZURE_BASTION_HOST_ID string = network!.outputs.AZURE_BASTION_HOST_ID

@description('Azure Bastion Host Name output')
output AZURE_BASTION_HOST_NAME string = network!.outputs.AZURE_BASTION_HOST_NAME
