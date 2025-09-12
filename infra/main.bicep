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
    tags: settings.tags
  }
}
