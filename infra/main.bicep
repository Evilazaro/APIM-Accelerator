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
    virtualNetwork: {
      name: settings.connectivity.virtualNetwork.name
      addressPrefixes: settings.connectivity.virtualNetwork.addressPrefixes
      subnets: settings.connectivity.virtualNetwork.subnets
    }
  }
  dependsOn: [
    monitoring
  ]
}
