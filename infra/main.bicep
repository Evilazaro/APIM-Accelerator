targetScope = 'subscription'

param location string
param dateTime string = utcNow('yyyyMMddHHmmss')

var allSettings = loadYamlContent('./settings.yaml')
var identitySettings = allSettings.shared.identity
var monitoringSettings = allSettings.shared.monitoring
var connectivitySettings = allSettings.shared.connectivity
var securitySettings = allSettings.shared.security
var apimCoreSettings = allSettings.core.apiManagement

resource identityRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: identitySettings.resourceGroup
  location: location
  tags: allSettings.tags
}

module identity '../src/shared/identity/identity.bicep' = {
  scope: identityRG
  name: 'identity-${dateTime}'
  params: {
    identity: identitySettings
    location: location
    tags: allSettings.tags
  }
}

resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: monitoringSettings.resourceGroup
  location: location
  tags: allSettings.tags
}

module monitoring '../src/shared/management/monitoring.bicep' = {
  name: 'monitoring-${dateTime}'
  scope: monitoringRG
  params: {
    location: location
    monitoring: monitoringSettings
    publicNetworkAccess: connectivitySettings.publicNetworkAccess
    tags: allSettings.tags
  }
}

output AZURE_MONITORING_STORAGE_ACCOUNT_NAME string = monitoring.outputs.AZURE_MONITORING_STORAGE_ACCOUNT_NAME
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
output AZURE_APPLICATION_INSIGHTS_NAME string = monitoring.outputs.AZURE_APPLICATION_INSIGHTS_NAME

resource networkingRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: connectivitySettings.resourceGroup
  location: location
  tags: allSettings.tags
}

module networking '../src/shared/connectivity/networking.bicep' = {
  name: 'networking-${dateTime}'
  scope: networkingRG
  params: {
    location: location
    tags: allSettings.tags
    networking: connectivitySettings
    logAnalytcsWorkspaceName: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
    monitoringStorageAccountName: monitoring.outputs.AZURE_MONITORING_STORAGE_ACCOUNT_NAME
    monitoringResourceGroup: monitoring.outputs.MONITORING_RESOURCE_GROUP_NAME
  }
  dependsOn: [
    monitoring
  ]
}

output AZURE_VNET_NAME string = networking.outputs.AZURE_VNET_NAME
output AZURE_VNET_ID string = networking.outputs.AZURE_VNET_ID
output AZURE_APIM_SUBNET_NAME string = networking.outputs.AZURE_APIM_SUBNET_NAME

resource securityRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: securitySettings.resourceGroup
  location: location
  tags: allSettings.tags
}

module security '../src/shared/security/security.bicep' = {
  name: 'security-${dateTime}'
  scope: securityRG
  params: {
    location: location
    publicNetworkAccess: connectivitySettings.publicNetworkAccess
    tags: allSettings.tags
    keyVault: securitySettings.keyVault
  }
  dependsOn: [
    networking
  ]
}

resource workloadRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: apimCoreSettings.resourceGroup
  location: location
  tags: allSettings.tags
}

module workload '../src/core/apim.bicep' = {
  scope: workloadRG
  name: 'workload-${dateTime}'
  params: {
    location: location
    tags: allSettings.tags
    apiManagement: apimCoreSettings
    appInsightsName: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_NAME
    logAnalyticsWorkspaceName: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
    monitoringResourceGroupName: monitoring.outputs.MONITORING_RESOURCE_GROUP_NAME
    publicNetworkAccess: connectivitySettings.publicNetworkAccess
    subnetName: networking.outputs.AZURE_APIM_SUBNET_NAME
    virtualNetworkResourceGroup: networking.outputs.NETWORKING_RESOURCE_GROUP_NANE
  }
  dependsOn: [
    identity
  ]
}
