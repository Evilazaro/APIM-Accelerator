targetScope = 'subscription'

@description('Azure region used for all resource group and child resource deployments.')
param location string
@description('Timestamp suffix (UTC, yyyyMMddHHmmss) ensuring unique module deployment names.')
param dateTime string = utcNow('yyyyMMddHHmmss')

var allSettings = loadYamlContent('./settings.yaml')
var identitySettings = allSettings.shared.identity
var monitoringSettings = allSettings.shared.monitoring
var connectivitySettings = allSettings.shared.connectivity
var securitySettings = allSettings.shared.security
var apimCoreSettings = allSettings.core.apiManagement

@description('Resource Group hosting shared identity components (managed identities, role assignments).')
resource identityRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: identitySettings.resourceGroup
  location: location
  tags: allSettings.tags
}

@description('Module deploying user-assigned managed identities and related RBAC assignments.')
module identity '../src/shared/identity/identity.bicep' = {
  scope: identityRG
  name: 'identity-${dateTime}'
  params: {
    identity: identitySettings
    location: location
    tags: allSettings.tags
  }
}

@description('Resource Group hosting monitoring and observability resources (Log Analytics, App Insights, diagnostics).')
resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: monitoringSettings.resourceGroup
  location: location
  tags: allSettings.tags
}

@description('Module deploying monitoring stack: Storage (diagnostics), Log Analytics workspace, Application Insights, and diagnostics settings.')
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

@description('Outputs the name of the monitoring Storage Account for downstream diagnostic module wiring.')
output AZURE_MONITORING_STORAGE_ACCOUNT_NAME string = monitoring.outputs.AZURE_MONITORING_STORAGE_ACCOUNT_NAME
@description('Outputs the Log Analytics workspace name for consumers needing query or diagnostic configuration.')
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.AZURE_LOG_ANALYTICS_WORKSPACE_NAME
@description('Outputs the Application Insights resource name for telemetry instrumentation parameters.')
output AZURE_APPLICATION_INSIGHTS_NAME string = monitoring.outputs.AZURE_APPLICATION_INSIGHTS_NAME

@description('Resource Group hosting core networking assets (VNet, subnets, network diagnostics).')
resource networkingRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: connectivitySettings.resourceGroup
  location: location
  tags: allSettings.tags
}

@description('Module deploying virtual network, subnets, NSG diagnostics, and related network telemetry settings.')
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

@description('Outputs the deployed Virtual Network name for integration modules that require VNet reference.')
output AZURE_VNET_NAME string = networking.outputs.AZURE_VNET_NAME
@description('Outputs the full resource ID of the Virtual Network for role assignments or cross-module references.')
output AZURE_VNET_ID string = networking.outputs.AZURE_VNET_ID
@description('Outputs the API Management subnet full name for APIM module network binding.')
output AZURE_APIM_SUBNET_NAME string = networking.outputs.AZURE_APIM_SUBNET_NAME

@description('Resource Group hosting Key Vault and related secret management assets.')
resource securityRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: securitySettings.resourceGroup
  location: location
  tags: allSettings.tags
}

@description('Module deploying Key Vault for secure secret, key, and certificate storage used by APIM workloads.')
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

@description('Resource Group hosting the API Management service and related configuration artifacts.')
resource apimRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: apimCoreSettings.resourceGroup
  location: location
  tags: allSettings.tags
}

@description('Module deploying the Azure API Management instance with monitoring, networking, identity, and security integrations.')
module apim '../src/core/apim.bicep' = {
  scope: apimRG
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
