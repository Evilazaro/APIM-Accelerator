targetScope = 'subscription'

param location string
param dateTime string = utcNow('yyyyMMddHHmmss')

var allSettings = loadYamlContent('./settings.yaml')
var identitySettings = allSettings.shared.identity
var managementSettings = allSettings.shared.management
var connectivitySettings = allSettings.shared.connectivity
var securitySettings = allSettings.shared.security
var workloadSettings = allSettings.workload

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

// resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
//   name: managementSettings.monitoring.resourceGroup
//   location: location
//   tags: allSettings.tags
// }

// module monitoring '../src/shared/management/monitoring.bicep' = {
//   name: 'monitoring-${dateTime}'
//   scope: monitoringRG
//   params: {
//     location: location
//     monitoring: managementSettings.monitoring
//     publicNetworkAccess: connectivitySettings.publicNetworkAccess
//     tags: allSettings.tags
//   }
// }

// resource networkingRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
//   name: connectivitySettings.resourceGroup
//   location: location
//   tags: allSettings.tags
// }

// module networking '../src/shared/connectivity/networking.bicep' = {
//   name: 'networking-${dateTime}'
//   scope: networkingRG
//   params: {
//     location: location
//     tags: allSettings.tags
//     networking: connectivitySettings
//     logAnalytcsWorkspaceName: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
//     monitoringStorageAccountName: monitoring.outputs.AZURE_MONITORING_STORAGE_ACCOUNT_NAME
//     monitoringResourceGroup: monitoringRG.name
//   }
//   dependsOn: [
//     monitoring
//   ]
// }

// resource securityRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
//   name: securitySettings.resourceGroup
//   location: location
//   tags: allSettings.tags
// }

// module security '../src/shared/security/security.bicep' = {
//   name: 'security-${dateTime}'
//   scope: securityRG
//   params: {
//     location: location
//     publicNetworkAccess: connectivitySettings.publicNetworkAccess
//     tags: allSettings.tags
//     keyVault: securitySettings.keyVault
//   }
//   dependsOn: [
//     networking
//   ]
// }

// resource workloadRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
//   name: workloadSettings.apiManagement.resourceGroup
//   location: location
//   tags: allSettings.tags
// }

// module workload '../src/shared/workload/apim.bicep' = {
//   scope: workloadRG
//   name: 'workload-${dateTime}'
//   params: {
//     location: location
//     tags: allSettings.tags
//     apiManagement: workloadSettings.apiManagement
//     appInsightsName: monitoring.outputs.AZURE_APPLICATION_INSIGHTS_NAME
//     logAnalyticsWorkspaceName: monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
//     monitoringResourceGroupName: monitoringRG.name
//     publicNetworkAccess: connectivitySettings.publicNetworkAccess
//     subnetName: networking.outputs.AZURE_API_MANAGEMENT_SUBNET_NAME
//     virtualNetworkResourceGroup: connectivitySettings.resourceGroup
//   }
// }
