targetScope = 'subscription'

param location string
param dateTime string = utcNow('yyyyMMddHHmmss')

var settings = loadYamlContent('./settings.yaml')

resource monitoringRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.management.monitoring.resourceGroup
  location: location
}

module monitoring '../src/management/monitoring.bicep' = {
  name: 'monitoring-${dateTime}'
  scope: monitoringRG
  params: {
    location: location
    logAnalytics: settings.management.monitoring.logAnalytics
    appInsights: settings.management.monitoring.applicationInsights
    privateConnection: settings.connectivity.private
    tags: settings.tags
  }
}

resource networkingRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.connectivity.resourceGroup
  location: location
}

module networking '../src/connectivity/networking.bicep' = {
  name: 'networking-${dateTime}'
  scope: networkingRG
  params: {
    location: location
    tags: settings.tags
    virtualNetwork: settings.connectivity.virtualNetwork
  }
  dependsOn: [
    monitoring
  ]
}

resource securityRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: settings.security.resourceGroup
  location: location
}

module security '../src/security/security.bicep' = {
  name: 'security-${dateTime}'
  scope: securityRG
  params: {
    location: location
    virtualNetworkName: networking.outputs.AZURE_VNET_NAME
    virtualNetworkResourceGroup: securityRG.name
    subnetName: (settings.connectivity.private)
      ? networking.outputs.AZURE_PRIVATE_ENDPOINT_SUBNET_NAME
      : networking.outputs.AZURE_API_MANAGEMENT_SUBNET_NAME
    privateConnection: settings.connectivity.private
    tags: settings.tags
    keyVault: settings.security.keyVault
  }
  dependsOn: [
    networking
  ]
}
